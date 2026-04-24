import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 自选股状态管理Provider
/// 管理用户自选股列表和操作
class WatchlistProvider extends ChangeNotifier {
  final StockService _stockService;
  
  /// 自选股代码列表
  List<String> _watchlist = [];
  
  /// 自选股详情列表
  List<Stock> _watchlistStocks = [];
  
  /// 加载状态
  bool _isLoading = false;
  
  /// 错误信息
  String? _error;

  WatchlistProvider(this._stockService);
  
  // ==================== Getter ====================
  
  List<String> get watchlist => _watchlist;
  List<Stock> get watchlistStocks => _watchlistStocks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ==================== 初始化 ====================
  
  /// 加载自选股列表
  Future<void> loadWatchlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 从本地存储加载
      final prefs = await SharedPreferences.getInstance();
      _watchlist = prefs.getStringList('watchlist') ?? [];
      
      // 如果本地有数据，尝试从API获取完整信息
      if (_watchlist.isNotEmpty) {
        await _refreshWatchlistDetails();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 刷新自选股详情
  Future<void> _refreshWatchlistDetails() async {
    try {
      final quotes = await _stockService.getQuotes(_watchlist);
      _watchlistStocks = quotes.map((q) => Stock(
        code: q.stockCode,
        name: q.stockName,
        exchange: q.stockCode.startsWith('6') ? 'SH' : 'SZ',
        currentPrice: q.currentPrice,
        change: q.change,
        changePercent: q.changePercent,
        openPrice: q.openPrice,
        highPrice: q.highPrice,
        lowPrice: q.lowPrice,
        volume: q.volume,
        amount: q.amount,
        turnoverRate: q.turnoverRate,
        pe: q.pe,
        pb: q.pb,
        totalMarketValue: q.totalMarketValue,
        flowMarketValue: q.flowMarketValue,
        high52Week: q.high52Week,
        low52Week: q.low52Week,
        updateTime: q.updateTime,
      )).toList();
    } catch (e) {
      // 静默处理，使用缓存数据
    }
  }
  
  // ==================== 操作方法 ====================
  
  /// 添加自选股
  Future<bool> addToWatchlist(String code) async {
    if (_watchlist.contains(code)) {
      return true; // 已存在
    }
    
    try {
      // 添加到服务器
      await _stockService.addToWatchlist(code);
      
      // 添加到本地列表
      _watchlist.add(code);
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('watchlist', _watchlist);
      
      // 刷新详情
      await _refreshWatchlistDetails();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// 删除自选股
  Future<bool> removeFromWatchlist(String code) async {
    try {
      // 从服务器删除
      await _stockService.removeFromWatchlist(code);
      
      // 从本地列表删除
      _watchlist.remove(code);
      _watchlistStocks.removeWhere((s) => s.code == code);
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('watchlist', _watchlist);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// 检查是否在自选股中
  bool isInWatchlist(String code) {
    return _watchlist.contains(code);
  }
  
  /// 移动自选股位置
  Future<void> reorderWatchlist(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final code = _watchlist.removeAt(oldIndex);
    _watchlist.insert(newIndex, code);
    
    // 保存到本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('watchlist', _watchlist);
    
    notifyListeners();
  }
  
  /// 刷新行情数据
  Future<void> refreshQuotes() async {
    if (_watchlist.isEmpty) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _refreshWatchlistDetails();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}

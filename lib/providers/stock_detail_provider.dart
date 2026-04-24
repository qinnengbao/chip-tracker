import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 股票详情状态管理Provider
/// 管理当前查看的股票详情数据
class StockDetailProvider extends ChangeNotifier {
  final StockService _stockService;
  
  /// 当前选中的股票代码
  String? _currentCode;
  
  /// 股票基础信息
  Stock? _stock;
  
  /// 实时行情
  Quote? _quote;
  
  /// 筹码分布数据
  ChipDistribution? _chipDistribution;
  
  /// 股东户数数据
  HolderNumber? _holderNumber;
  
  /// 龙虎榜数据
  DragonTiger? _dragonTiger;
  
  /// 加载状态
  bool _isLoading = false;
  
  /// 错误信息
  String? _error;

  StockDetailProvider(this._stockService);
  
  // ==================== Getter ====================
  
  String? get currentCode => _currentCode;
  Stock? get stock => _stock;
  Quote? get quote => _quote;
  ChipDistribution? get chipDistribution => _chipDistribution;
  HolderNumber? get holderNumber => _holderNumber;
  DragonTiger? get dragonTiger => _dragonTiger;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ==================== 加载数据 ====================
  
  /// 加载股票完整详情
  Future<void> loadStockDetail(String code) async {
    _currentCode = code;
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 并行加载所有数据
      await Future.wait([
        _loadStockInfo(code),
        _loadQuote(code),
        _loadChipDistribution(code),
        _loadHolderNumber(code),
        _loadDragonTiger(code),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 加载股票基础信息
  Future<void> _loadStockInfo(String code) async {
    try {
      _stock = await _stockService.getStockDetail(code);
    } catch (e) {
      // 静默处理
    }
  }
  
  /// 加载实时行情
  Future<void> _loadQuote(String code) async {
    try {
      final quotes = await _stockService.getQuotes([code]);
      if (quotes.isNotEmpty) {
        _quote = quotes.first;
      }
    } catch (e) {
      // 静默处理
    }
  }
  
  /// 加载筹码分布
  Future<void> _loadChipDistribution(String code) async {
    try {
      _chipDistribution = await _stockService.getChipDistribution(code);
    } catch (e) {
      // 静默处理
    }
  }
  
  /// 加载股东户数
  Future<void> _loadHolderNumber(String code) async {
    try {
      _holderNumber = await _stockService.getHolderNumber(code);
    } catch (e) {
      // 静默处理
    }
  }
  
  /// 加载龙虎榜
  Future<void> _loadDragonTiger(String code) async {
    try {
      _dragonTiger = await _stockService.getDragonTiger(code);
    } catch (e) {
      // 静默处理
    }
  }
  
  // ==================== 刷新数据 ====================
  
  /// 刷新实时行情
  Future<void> refreshQuote() async {
    if (_currentCode == null) return;
    
    try {
      await _loadQuote(_currentCode!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 刷新筹码分布
  Future<void> refreshChipDistribution() async {
    if (_currentCode == null) return;
    
    try {
      await _loadChipDistribution(_currentCode!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 刷新股东户数
  Future<void> refreshHolderNumber() async {
    if (_currentCode == null) return;
    
    try {
      await _loadHolderNumber(_currentCode!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // ==================== 清理数据 ====================
  
  /// 清空当前数据
  void clear() {
    _currentCode = null;
    _stock = null;
    _quote = null;
    _chipDistribution = null;
    _holderNumber = null;
    _dragonTiger = null;
    _error = null;
    notifyListeners();
  }
}

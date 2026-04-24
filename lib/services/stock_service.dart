import 'dart:math';
import 'package:dio/dio.dart';
import '../models/models.dart';
import 'api_config.dart';

/// 股票API服务
/// 封装所有股票相关的API请求
class StockService {
  late final Dio _dio;
  
  StockService() {
    _dio = ApiConfig.createDio();
  }
  
  // ==================== 股票基础接口 ====================
  
  /// 搜索股票
  /// [keyword] 搜索关键词（代码或名称）
  Future<List<Stock>> searchStocks(String keyword) async {
    try {
      final response = await _dio.get(
        ApiConfig.stockSearch,
        queryParameters: {'keyword': keyword},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => Stock.fromJson(e)).toList();
    } on DioException {
      // 网络请求失败时返回Mock数据
      return _getMockSearchResults(keyword);
    }
  }
  
  /// 获取股票详情
  /// [code] 股票代码
  Future<Stock?> getStockDetail(String code) async {
    try {
      final url = ApiConfig.stockDetail.replaceAll('{code}', code);
      final response = await _dio.get(url);
      return Stock.fromJson(response.data['data']);
    } on DioException {
      return _getMockStockDetail(code);
    }
  }
  
  /// 批量获取股票报价
  /// [codes] 股票代码列表
  Future<List<Quote>> getQuotes(List<String> codes) async {
    try {
      final response = await _dio.post(
        '/quotes/batch',
        data: {'codes': codes},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => Quote.fromJson(e)).toList();
    } on DioException {
      return codes.map((code) => _getMockQuote(code)).toList();
    }
  }
  
  // ==================== 筹码分布接口 ====================
  
  /// 获取筹码分布数据
  /// [code] 股票代码
  Future<ChipDistribution?> getChipDistribution(String code) async {
    try {
      final url = ApiConfig.chipDistribution.replaceAll('{code}', code);
      final response = await _dio.get(url);
      return ChipDistribution.fromJson(response.data['data']);
    } on DioException {
      return _getMockChipDistribution(code);
    }
  }
  
  /// 获取筹码分布历史
  /// [code] 股票代码
  /// [days] 历史天数
  Future<List<ChipDistribution>> getChipHistory(String code, {int days = 30}) async {
    try {
      final url = ApiConfig.chipHistory.replaceAll('{code}', code);
      final response = await _dio.get(
        url,
        queryParameters: {'days': days},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => ChipDistribution.fromJson(e)).toList();
    } on DioException {
      return _getMockChipHistory(code, days);
    }
  }
  
  // ==================== 股东户数接口 ====================
  
  /// 获取股东户数数据
  /// [code] 股票代码
  Future<HolderNumber?> getHolderNumber(String code) async {
    try {
      final url = ApiConfig.holderNumber.replaceAll('{code}', code);
      final response = await _dio.get(url);
      return HolderNumber.fromJson(response.data['data']);
    } on DioException {
      return _getMockHolderNumber(code);
    }
  }
  
  /// 获取股东户数历史
  /// [code] 股票代码
  Future<List<HolderData>> getHolderHistory(String code, {int periods = 12}) async {
    try {
      final url = ApiConfig.holderHistory.replaceAll('{code}', code);
      final response = await _dio.get(
        url,
        queryParameters: {'periods': periods},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => HolderData.fromJson(e)).toList();
    } on DioException {
      return _getMockHolderHistory(code, periods);
    }
  }
  
  // ==================== 龙虎榜接口 ====================
  
  /// 获取龙虎榜数据
  /// [code] 股票代码
  Future<DragonTiger?> getDragonTiger(String code) async {
    try {
      final url = ApiConfig.dragonTiger.replaceAll('{code}', code);
      final response = await _dio.get(url);
      return DragonTiger.fromJson(response.data['data']);
    } on DioException {
      return _getMockDragonTiger(code);
    }
  }
  
  // ==================== 自选股接口 ====================
  
  /// 获取自选股列表
  Future<List<String>> getWatchlist() async {
    try {
      final response = await _dio.get(ApiConfig.watchlist);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<String>();
    } on DioException {
      return ['000001', '600519', '000858', '601318', '600036'];
    }
  }
  
  /// 添加自选股
  /// [code] 股票代码
  Future<bool> addToWatchlist(String code) async {
    try {
      await _dio.post(
        ApiConfig.watchlist,
        data: {'code': code},
      );
      return true;
    } on DioException {
      return true; // Mock成功
    }
  }
  
  /// 删除自选股
  /// [code] 股票代码
  Future<bool> removeFromWatchlist(String code) async {
    try {
      await _dio.delete('${ApiConfig.watchlist}/$code');
      return true;
    } on DioException {
      return true; // Mock成功
    }
  }
  
  // ==================== Mock数据生成 ====================
  
  /// 生成Mock搜索结果
  List<Stock> _getMockSearchResults(String keyword) {
    final mockStocks = [
      {'code': '000001', 'name': '平安银行', 'exchange': 'SZ'},
      {'code': '600519', 'name': '贵州茅台', 'exchange': 'SH'},
      {'code': '000858', 'name': '五粮液', 'exchange': 'SZ'},
      {'code': '601318', 'name': '中国平安', 'exchange': 'SH'},
      {'code': '600036', 'name': '招商银行', 'exchange': 'SH'},
      {'code': '000002', 'name': '万科A', 'exchange': 'SZ'},
      {'code': '600276', 'name': '恒瑞医药', 'exchange': 'SH'},
      {'code': '002594', 'name': '比亚迪', 'exchange': 'SZ'},
      {'code': '300750', 'name': '宁德时代', 'exchange': 'SZ'},
      {'code': '600900', 'name': '长江电力', 'exchange': 'SH'},
    ];
    
    final results = mockStocks.where((s) =>
      s['code']!.contains(keyword) || 
      s['name']!.contains(keyword)
    ).map((s) => _getMockStockDetail(s['code']!)!).toList();
    
    return results.isEmpty ? mockStocks.map((s) => _getMockStockDetail(s['code']!)!).toList() : results;
  }
  
  /// 生成Mock股票详情
  Stock? _getMockStockDetail(String code) {
    final random = Random(code.hashCode);
    final prices = {
      '000001': {'name': '平安银行', 'price': 12.58},
      '600519': {'name': '贵州茅台', 'price': 1688.00},
      '000858': {'name': '五粮液', 'price': 148.56},
      '601318': {'name': '中国平安', 'price': 45.32},
      '600036': {'name': '招商银行', 'price': 35.67},
    };
    
    final stockInfo = prices[code] ?? {'name': '股票$code', 'price': 10.0 + random.nextDouble() * 50};
    final change = (random.nextDouble() - 0.5) * 2;
    final changePercent = change / (stockInfo['price'] as double) * 100;
    
    return Stock(
      code: code,
      name: stockInfo['name'] as String,
      exchange: code.startsWith('6') ? 'SH' : 'SZ',
      currentPrice: stockInfo['price'] as double,
      change: change,
      changePercent: changePercent,
      openPrice: (stockInfo['price'] as double) - change * 0.5,
      highPrice: (stockInfo['price'] as double) + random.nextDouble() * 2,
      lowPrice: (stockInfo['price'] as double) - random.nextDouble() * 2,
      volume: random.nextInt(100000000),
      amount: random.nextDouble() * 10000000000,
      turnoverRate: random.nextDouble() * 5,
      pe: 10 + random.nextDouble() * 30,
      pb: 1 + random.nextDouble() * 5,
      totalMarketValue: random.nextDouble() * 1000000000000,
      flowMarketValue: random.nextDouble() * 500000000000,
      high52Week: (stockInfo['price'] as double) * 1.3,
      low52Week: (stockInfo['price'] as double) * 0.7,
      updateTime: DateTime.now(),
    );
  }
  
  /// 生成Mock行情数据
  Quote _getMockQuote(String code) {
    final stock = _getMockStockDetail(code);
    if (stock == null) {
      return Quote(
        stockCode: code,
        stockName: '股票$code',
        currentPrice: 10.0,
        change: 0,
        changePercent: 0,
        openPrice: 10.0,
        lastClosePrice: 10.0,
        highPrice: 10.0,
        lowPrice: 10.0,
        volume: 0,
        amount: 0,
        turnoverRate: 0,
        pe: 0,
        pb: 0,
        totalMarketValue: 0,
        flowMarketValue: 0,
        high52Week: 12.0,
        low52Week: 8.0,
        volumeRatio: 1.0,
        amplitude: 0,
        limitUpPrice: 11.0,
        limitDownPrice: 9.0,
        externalDisk: 0,
        internalDisk: 0,
        updateTime: DateTime.now(),
      );
    }
    
    return Quote(
      stockCode: stock.code,
      stockName: stock.name,
      currentPrice: stock.currentPrice,
      change: stock.change,
      changePercent: stock.changePercent,
      openPrice: stock.openPrice,
      lastClosePrice: stock.currentPrice - stock.change,
      highPrice: stock.highPrice,
      lowPrice: stock.lowPrice,
      volume: stock.volume,
      amount: stock.amount,
      turnoverRate: stock.turnoverRate,
      pe: stock.pe,
      pb: stock.pb,
      totalMarketValue: stock.totalMarketValue,
      flowMarketValue: stock.flowMarketValue,
      high52Week: stock.high52Week,
      low52Week: stock.low52Week,
      volumeRatio: 1.0 + Random().nextDouble() - 0.5,
      amplitude: ((stock.highPrice - stock.lowPrice) / stock.currentPrice * 100),
      limitUpPrice: (stock.currentPrice * 1.1).floorToDouble(),
      limitDownPrice: (stock.currentPrice * 0.9).floorToDouble(),
      externalDisk: (stock.volume * 0.5).toInt(),
      internalDisk: (stock.volume * 0.5).toInt(),
      updateTime: DateTime.now(),
    );
  }
  
  /// 生成Mock筹码分布数据
  ChipDistribution _getMockChipDistribution(String code) {
    final random = Random(code.hashCode);
    final stock = _getMockStockDetail(code);
    final currentPrice = stock?.currentPrice ?? 10.0;
    
    // 生成筹码分布数据
    final chips = <ChipData>[];
    final chipCount = 20;
    final priceRange = currentPrice * 0.5;
    final minPrice = currentPrice - priceRange / 2;
    
    for (int i = 0; i < chipCount; i++) {
      final priceLow = minPrice + (priceRange / chipCount) * i;
      final priceHigh = priceLow + (priceRange / chipCount);
      final ratio = random.nextDouble() * 15 + 2;
      final isProfit = priceLow >= currentPrice * 0.95;
      
      chips.add(ChipData(
        priceLow: priceLow,
        priceHigh: priceHigh,
        shares: (ratio * 1000000).toInt(),
        ratio: ratio,
        type: isProfit ? 'profit' : 'loss',
        profitRatio: isProfit ? ratio : 0,
      ));
    }
    
    // 计算平均成本（加权平均）
    double totalValue = 0;
    double totalShares = 0;
    for (final chip in chips) {
      totalValue += chip.priceMid * chip.shares;
      totalShares += chip.shares;
    }
    final avgCost = totalShares > 0 ? totalValue / totalShares : currentPrice;
    
    return ChipDistribution(
      stockCode: code,
      chips: chips,
      avgCost: avgCost,
      concentration: 30 + random.nextDouble() * 40,
      mainForceRatio: 40 + random.nextDouble() * 30,
      supportLevel: currentPrice * 0.9,
      resistanceLevel: currentPrice * 1.1,
      minCost: minPrice,
      maxCost: minPrice + priceRange,
      date: DateTime.now(),
    );
  }
  
  /// 生成Mock筹码分布历史
  List<ChipDistribution> _getMockChipHistory(String code, int days) {
    return List.generate(days, (index) => _getMockChipDistribution(code));
  }
  
  /// 生成Mock股东户数数据
  HolderNumber _getMockHolderNumber(String code) {
    final random = Random(code.hashCode);
    final latestCount = 50000 + random.nextInt(100000);
    
    return HolderNumber(
      stockCode: code,
      history: _getMockHolderHistory(code, 12),
      latestCount: latestCount,
      changeCount: (random.nextDouble() - 0.5) * 10000,
      changePercent: (random.nextDouble() - 0.5) * 10,
      avgSharesPerHolder: 10000 + random.nextDouble() * 10000,
      avgMarketValuePerHolder: 100000 + random.nextDouble() * 500000,
    );
  }
  
  /// 生成Mock股东户数历史
  List<HolderData> _getMockHolderHistory(String code, int periods) {
    final random = Random(code.hashCode);
    return List.generate(periods, (index) {
      final date = DateTime.now().subtract(Duration(days: (periods - index) * 30));
      final count = 50000 + random.nextInt(100000) - index * 2000;
      return HolderData(
        date: date,
        count: count > 30000 ? count : 30000,
        change: (random.nextDouble() - 0.5) * 5000,
        changePercent: (random.nextDouble() - 0.5) * 5,
        avgSharesPerHolder: 10000 + random.nextDouble() * 5000,
      );
    });
  }
  
  /// 生成Mock龙虎榜数据
  DragonTiger _getMockDragonTiger(String code) {
    final random = Random(code.hashCode);
    final records = List.generate(random.nextInt(5) + 1, (index) {
      final buyBrokers = List.generate(5, (i) => BrokerInfo(
        name: '机构专用${i + 1}',
        buyAmount: random.nextDouble() * 100000000,
        sellAmount: random.nextDouble() * 50000000,
        netAmount: (random.nextDouble() - 0.3) * 100000000,
        buyRatio: random.nextDouble() * 10,
        sellRatio: random.nextDouble() * 8,
      ));
      
      final sellBrokers = List.generate(5, (i) => BrokerInfo(
        name: '营业部${i + 1}',
        buyAmount: random.nextDouble() * 50000000,
        sellAmount: random.nextDouble() * 100000000,
        netAmount: (random.nextDouble() - 0.7) * 100000000,
        buyRatio: random.nextDouble() * 8,
        sellRatio: random.nextDouble() * 10,
      ));
      
      return DragonTigerRecord(
        date: DateTime.now().subtract(Duration(days: index * 7)),
        reason: ['日涨幅偏离值达7%', '日跌幅偏离值达7%', '日振幅值达15%', '连续三个交易日内涨跌幅偏离值累计达20%'][random.nextInt(4)],
        changePercent: (random.nextDouble() - 0.5) * 20,
        volume: random.nextInt(100000000),
        amount: random.nextDouble() * 10000000000,
        buyBrokers: buyBrokers,
        sellBrokers: sellBrokers,
        netAmount: (random.nextDouble() - 0.5) * 200000000,
        dataSource: '上海证券交易所',
      );
    });
    
    return DragonTiger(
      stockCode: code,
      records: records,
      appearCount: records.length,
      totalNetAmount: records.fold(0.0, (sum, r) => sum + r.netAmount),
    );
  }
}

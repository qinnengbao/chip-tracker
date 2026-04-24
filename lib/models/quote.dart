/// 实时行情数据模型
/// 用于存储股票的实时交易行情
class Quote {
  /// 股票代码
  final String stockCode;
  
  /// 股票名称
  final String stockName;
  
  /// 当前价格
  final double currentPrice;
  
  /// 涨跌额
  final double change;
  
  /// 涨跌幅（百分比）
  final double changePercent;
  
  /// 开盘价
  final double openPrice;
  
  /// 昨收价
  final double lastClosePrice;
  
  /// 最高价
  final double highPrice;
  
  /// 最低价
  final double lowPrice;
  
  /// 成交量（股）
  final int volume;
  
  /// 成交额（元）
  final double amount;
  
  /// 换手率（百分比）
  final double turnoverRate;
  
  /// 市盈率
  final double pe;
  
  /// 市净率
  final double pb;
  
  /// 总市值（元）
  final double totalMarketValue;
  
  /// 流通市值（元）
  final double flowMarketValue;
  
  /// 52周最高
  final double high52Week;
  
  /// 52周最低
  final double low52Week;
  
  /// 量比
  final double volumeRatio;
  
  /// 振幅（百分比）
  final double amplitude;
  
  /// 涨停价
  final double limitUpPrice;
  
  /// 跌停价
  final double limitDownPrice;
  
  /// 外盘（主动买盘）
  final int externalDisk;
  
  /// 内盘（主动卖盘）
  final int internalDisk;
  
  /// 更新时间
  final DateTime updateTime;

  Quote({
    required this.stockCode,
    required this.stockName,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.openPrice,
    required this.lastClosePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.amount,
    required this.turnoverRate,
    required this.pe,
    required this.pb,
    required this.totalMarketValue,
    required this.flowMarketValue,
    required this.high52Week,
    required this.low52Week,
    required this.volumeRatio,
    required this.amplitude,
    required this.limitUpPrice,
    required this.limitDownPrice,
    required this.externalDisk,
    required this.internalDisk,
    required this.updateTime,
  });

  /// 从JSON解析
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      openPrice: (json['openPrice'] ?? 0).toDouble(),
      lastClosePrice: (json['lastClosePrice'] ?? 0).toDouble(),
      highPrice: (json['highPrice'] ?? 0).toDouble(),
      lowPrice: (json['lowPrice'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      turnoverRate: (json['turnoverRate'] ?? 0).toDouble(),
      pe: (json['pe'] ?? 0).toDouble(),
      pb: (json['pb'] ?? 0).toDouble(),
      totalMarketValue: (json['totalMarketValue'] ?? 0).toDouble(),
      flowMarketValue: (json['flowMarketValue'] ?? 0).toDouble(),
      high52Week: (json['high52Week'] ?? 0).toDouble(),
      low52Week: (json['low52Week'] ?? 0).toDouble(),
      volumeRatio: (json['volumeRatio'] ?? 0).toDouble(),
      amplitude: (json['amplitude'] ?? 0).toDouble(),
      limitUpPrice: (json['limitUpPrice'] ?? 0).toDouble(),
      limitDownPrice: (json['limitDownPrice'] ?? 0).toDouble(),
      externalDisk: json['externalDisk'] ?? 0,
      internalDisk: json['internalDisk'] ?? 0,
      updateTime: json['updateTime'] != null 
          ? DateTime.parse(json['updateTime']) 
          : DateTime.now(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'stockName': stockName,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'openPrice': openPrice,
      'lastClosePrice': lastClosePrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'volume': volume,
      'amount': amount,
      'turnoverRate': turnoverRate,
      'pe': pe,
      'pb': pb,
      'totalMarketValue': totalMarketValue,
      'flowMarketValue': flowMarketValue,
      'high52Week': high52Week,
      'low52Week': low52Week,
      'volumeRatio': volumeRatio,
      'amplitude': amplitude,
      'limitUpPrice': limitUpPrice,
      'limitDownPrice': limitDownPrice,
      'externalDisk': externalDisk,
      'internalDisk': internalDisk,
      'updateTime': updateTime.toIso8601String(),
    };
  }
  
  /// 判断是否上涨
  bool get isUp => change > 0;
  
  /// 判断是否下跌
  bool get isDown => change < 0;
  
  /// 判断是否涨停
  bool get isLimitUp => currentPrice >= limitUpPrice && limitUpPrice > 0;
  
  /// 判断是否跌停
  bool get isLimitDown => currentPrice <= limitDownPrice && limitDownPrice > 0;
  
  /// 获取完整代码
  String get fullCode => stockCode;
  
  /// 获取委买委卖比
  double get diskRatio {
    if (externalDisk + internalDisk == 0) return 1.0;
    return externalDisk / (externalDisk + internalDisk);
  }
}

/// 股票基础信息数据模型
/// 包含股票的基本交易信息
class Stock {
  /// 股票代码（6位数字）
  final String code;
  
  /// 股票名称
  final String name;
  
  /// 交易所前缀 (SH/SZ/BJ)
  final String exchange;
  
  /// 当前价格
  final double currentPrice;
  
  /// 涨跌额
  final double change;
  
  /// 涨跌幅（百分比）
  final double changePercent;
  
  /// 开盘价
  final double openPrice;
  
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
  
  /// 更新时间
  final DateTime updateTime;

  Stock({
    required this.code,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.openPrice,
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
    required this.updateTime,
  });

  /// 从JSON解析
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      openPrice: (json['openPrice'] ?? 0).toDouble(),
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
      updateTime: json['updateTime'] != null 
          ? DateTime.parse(json['updateTime']) 
          : DateTime.now(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'exchange': exchange,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'openPrice': openPrice,
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
      'updateTime': updateTime.toIso8601String(),
    };
  }

  /// 获取完整代码（带交易所前缀）
  String get fullCode => '$exchange$code';
  
  /// 判断是否上涨
  bool get isUp => change > 0;
  
  /// 判断是否下跌
  bool get isDown => change < 0;

  @override
  String toString() {
    return 'Stock($fullCode $name)';
  }
}

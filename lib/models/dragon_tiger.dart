/// 龙虎榜数据模型
/// 用于存储股票的龙虎榜交易信息
class DragonTiger {
  /// 股票代码
  final String stockCode;
  
  /// 龙虎榜记录列表
  final List<DragonTigerRecord> records;
  
  /// 上榜次数
  final int appearCount;
  
  /// 累计买卖净额（元）
  final double totalNetAmount;

  DragonTiger({
    required this.stockCode,
    required this.records,
    required this.appearCount,
    required this.totalNetAmount,
  });

  /// 从JSON解析
  factory DragonTiger.fromJson(Map<String, dynamic> json) {
    return DragonTiger(
      stockCode: json['stockCode'] ?? '',
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => DragonTigerRecord.fromJson(e))
          .toList() ?? [],
      appearCount: json['appearCount'] ?? 0,
      totalNetAmount: (json['totalNetAmount'] ?? 0).toDouble(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'records': records.map((e) => e.toJson()).toList(),
      'appearCount': appearCount,
      'totalNetAmount': totalNetAmount,
    };
  }
}

/// 龙虎榜单条记录
class DragonTigerRecord {
  /// 上榜日期
  final DateTime date;
  
  /// 上榜原因
  final String reason;
  
  /// 涨跌幅（百分比）
  final double changePercent;
  
  /// 成交量（股）
  final int volume;
  
  /// 成交额（元）
  final double amount;
  
  /// 买方营业部列表
  final List<BrokerInfo> buyBrokers;
  
  /// 卖方营业部列表
  final List<BrokerInfo> sellBrokers;
  
  /// 营业部净买入额（元）
  final double netAmount;
  
  /// 数据来源
  final String dataSource;

  DragonTigerRecord({
    required this.date,
    required this.reason,
    required this.changePercent,
    required this.volume,
    required this.amount,
    required this.buyBrokers,
    required this.sellBrokers,
    required this.netAmount,
    required this.dataSource,
  });

  /// 从JSON解析
  factory DragonTigerRecord.fromJson(Map<String, dynamic> json) {
    return DragonTigerRecord(
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      reason: json['reason'] ?? '',
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      buyBrokers: (json['buyBrokers'] as List<dynamic>?)
          ?.map((e) => BrokerInfo.fromJson(e))
          .toList() ?? [],
      sellBrokers: (json['sellBrokers'] as List<dynamic>?)
          ?.map((e) => BrokerInfo.fromJson(e))
          .toList() ?? [],
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      dataSource: json['dataSource'] ?? '',
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reason': reason,
      'changePercent': changePercent,
      'volume': volume,
      'amount': amount,
      'buyBrokers': buyBrokers.map((e) => e.toJson()).toList(),
      'sellBrokers': sellBrokers.map((e) => e.toJson()).toList(),
      'netAmount': netAmount,
      'dataSource': dataSource,
    };
  }
}

/// 营业部信息
class BrokerInfo {
  /// 营业部名称
  final String name;
  
  /// 买入金额（元）
  final double buyAmount;
  
  /// 卖出金额（元）
  final double sellAmount;
  
  /// 净买入额（元）
  final double netAmount;
  
  /// 买入占比（百分比）
  final double buyRatio;
  
  /// 卖出占比（百分比）
  final double sellRatio;

  BrokerInfo({
    required this.name,
    required this.buyAmount,
    required this.sellAmount,
    required this.netAmount,
    required this.buyRatio,
    required this.sellRatio,
  });

  /// 从JSON解析
  factory BrokerInfo.fromJson(Map<String, dynamic> json) {
    return BrokerInfo(
      name: json['name'] ?? '',
      buyAmount: (json['buyAmount'] ?? 0).toDouble(),
      sellAmount: (json['sellAmount'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      buyRatio: (json['buyRatio'] ?? 0).toDouble(),
      sellRatio: (json['sellRatio'] ?? 0).toDouble(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'buyAmount': buyAmount,
      'sellAmount': sellAmount,
      'netAmount': netAmount,
      'buyRatio': buyRatio,
      'sellRatio': sellRatio,
    };
  }
}

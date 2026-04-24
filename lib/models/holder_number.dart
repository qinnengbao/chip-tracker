/// 股东户数数据模型
/// 用于存储股票的股东户数变化信息
class HolderNumber {
  /// 股票代码
  final String stockCode;
  
  /// 股东户数变化列表
  final List<HolderData> history;
  
  /// 最新股东户数
  final int latestCount;
  
  /// 较上期变化数量
  final int changeCount;
  
  /// 较上期变化比例（百分比）
  final double changePercent;
  
  /// 户均持股数
  final double avgSharesPerHolder;
  
  /// 户均市值（元）
  final double avgMarketValuePerHolder;

  HolderNumber({
    required this.stockCode,
    required this.history,
    required this.latestCount,
    required this.changeCount,
    required this.changePercent,
    required this.avgSharesPerHolder,
    required this.avgMarketValuePerHolder,
  });

  /// 从JSON解析
  factory HolderNumber.fromJson(Map<String, dynamic> json) {
    return HolderNumber(
      stockCode: json['stockCode'] ?? '',
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => HolderData.fromJson(e))
          .toList() ?? [],
      latestCount: json['latestCount'] ?? 0,
      changeCount: json['changeCount'] ?? 0,
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      avgSharesPerHolder: (json['avgSharesPerHolder'] ?? 0).toDouble(),
      avgMarketValuePerHolder: (json['avgMarketValuePerHolder'] ?? 0).toDouble(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'history': history.map((e) => e.toJson()).toList(),
      'latestCount': latestCount,
      'changeCount': changeCount,
      'changePercent': changePercent,
      'avgSharesPerHolder': avgSharesPerHolder,
      'avgMarketValuePerHolder': avgMarketValuePerHolder,
    };
  }
  
  /// 判断股东户数是增加还是减少
  /// 增加意味着筹码分散，减少意味着筹码集中
  bool get isIncreasing => changeCount > 0;
}

/// 单条股东户数记录
class HolderData {
  /// 统计日期
  final DateTime date;
  
  /// 股东户数
  final int count;
  
  /// 较上期变化
  final int change;
  
  /// 较上期变化比例（百分比）
  final double changePercent;
  
  /// 户均持股数
  final double avgSharesPerHolder;

  HolderData({
    required this.date,
    required this.count,
    required this.change,
    required this.changePercent,
    required this.avgSharesPerHolder,
  });

  /// 从JSON解析
  factory HolderData.fromJson(Map<String, dynamic> json) {
    return HolderData(
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      count: json['count'] ?? 0,
      change: json['change'] ?? 0,
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      avgSharesPerHolder: (json['avgSharesPerHolder'] ?? 0).toDouble(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'change': change,
      'changePercent': changePercent,
      'avgSharesPerHolder': avgSharesPerHolder,
    };
  }
}

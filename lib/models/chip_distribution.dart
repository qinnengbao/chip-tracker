/// 筹码分布数据模型
/// 用于存储股票的筹码分布信息
class ChipDistribution {
  /// 股票代码
  final String stockCode;
  
  /// 筹码分布数据列表
  final List<ChipData> chips;
  
  /// 平均成本
  final double avgCost;
  
  /// 筹码集中度 (0-100%)
  final double concentration;
  
  /// 主力持仓比例 (0-100%)
  final double mainForceRatio;
  
  /// 支撑位
  final double supportLevel;
  
  /// 压力位
  final double resistanceLevel;
  
  /// 成本区间最低价
  final double minCost;
  
  /// 成本区间最高价
  final double maxCost;
  
  /// 数据日期
  final DateTime date;

  ChipDistribution({
    required this.stockCode,
    required this.chips,
    required this.avgCost,
    required this.concentration,
    required this.mainForceRatio,
    required this.supportLevel,
    required this.resistanceLevel,
    required this.minCost,
    required this.maxCost,
    required this.date,
  });

  /// 从JSON解析
  factory ChipDistribution.fromJson(Map<String, dynamic> json) {
    return ChipDistribution(
      stockCode: json['stockCode'] ?? '',
      chips: (json['chips'] as List<dynamic>?)
          ?.map((e) => ChipData.fromJson(e))
          .toList() ?? [],
      avgCost: (json['avgCost'] ?? 0).toDouble(),
      concentration: (json['concentration'] ?? 0).toDouble(),
      mainForceRatio: (json['mainForceRatio'] ?? 0).toDouble(),
      supportLevel: (json['supportLevel'] ?? 0).toDouble(),
      resistanceLevel: (json['resistanceLevel'] ?? 0).toDouble(),
      minCost: (json['minCost'] ?? 0).toDouble(),
      maxCost: (json['maxCost'] ?? 0).toDouble(),
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'chips': chips.map((e) => e.toJson()).toList(),
      'avgCost': avgCost,
      'concentration': concentration,
      'mainForceRatio': mainForceRatio,
      'supportLevel': supportLevel,
      'resistanceLevel': resistanceLevel,
      'minCost': minCost,
      'maxCost': maxCost,
      'date': date.toIso8601String(),
    };
  }
}

/// 单个价格区间的筹码数据
class ChipData {
  /// 价格下限
  final double priceLow;
  
  /// 价格上限
  final double priceHigh;
  
  /// 筹码数量（持股数）
  final int shares;
  
  /// 筹码占比（百分比）
  final double ratio;
  
  /// 筹码类型：profit(盈利)/loss(亏损)/flat(持平)
  final String type;
  
  /// 获利盘比例
  final double profitRatio;

  ChipData({
    required this.priceLow,
    required this.priceHigh,
    required this.shares,
    required this.ratio,
    required this.type,
    required this.profitRatio,
  });

  /// 获取价格区间中值
  double get priceMid => (priceLow + priceHigh) / 2;
  
  /// 获取格式化价格区间字符串
  String get priceRange => '${priceLow.toStringAsFixed(2)}-${priceHigh.toStringAsFixed(2)}';

  /// 从JSON解析
  factory ChipData.fromJson(Map<String, dynamic> json) {
    return ChipData(
      priceLow: (json['priceLow'] ?? 0).toDouble(),
      priceHigh: (json['priceHigh'] ?? 0).toDouble(),
      shares: json['shares'] ?? 0,
      ratio: (json['ratio'] ?? 0).toDouble(),
      type: json['type'] ?? 'flat',
      profitRatio: (json['profitRatio'] ?? 0).toDouble(),
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'priceLow': priceLow,
      'priceHigh': priceHigh,
      'shares': shares,
      'ratio': ratio,
      'type': type,
      'profitRatio': profitRatio,
    };
  }
}

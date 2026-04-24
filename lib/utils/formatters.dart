import 'package:intl/intl.dart';

/// 格式化工具类
/// 提供各种数据格式化方法
class Formatters {
  // ==================== 数字格式化 ====================
  
  /// 格式化价格
  /// [price] 价格值
  /// [decimals] 小数位数，默认2位
  static String formatPrice(double price, {int decimals = 2}) {
    return price.toStringAsFixed(decimals);
  }
  
  /// 格式化涨跌幅
  /// [change] 涨跌幅百分比
  /// 带颜色标记前缀
  static String formatChangePercent(double change) {
    if (change > 0) {
      return '+${change.toStringAsFixed(2)}%';
    } else if (change < 0) {
      return '${change.toStringAsFixed(2)}%';
    } else {
      return '0.00%';
    }
  }
  
  /// 格式化涨跌额
  /// [change] 涨跌额
  static String formatChange(double change) {
    if (change > 0) {
      return '+${change.toStringAsFixed(2)}';
    } else {
      return change.toStringAsFixed(2);
    }
  }
  
  /// 格式化成交量
  /// [volume] 成交量（股）
  static String formatVolume(int volume) {
    if (volume >= 100000000) {
      return '${(volume / 100000000).toStringAsFixed(2)}亿';
    } else if (volume >= 10000) {
      return '${(volume / 10000).toStringAsFixed(2)}万';
    } else {
      return volume.toString();
    }
  }
  
  /// 格式化成交额
  /// [amount] 成交额（元）
  static String formatAmount(double amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(2)}亿';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    } else {
      return '${amount.toStringAsFixed(2)}元';
    }
  }
  
  /// 格式化市值
  /// [marketValue] 市值（元）
  static String formatMarketValue(double marketValue) {
    if (marketValue >= 1000000000000) {
      return '${(marketValue / 1000000000000).toStringAsFixed(2)}万亿';
    } else if (marketValue >= 100000000) {
      return '${(marketValue / 100000000).toStringAsFixed(2)}亿';
    } else if (marketValue >= 10000) {
      return '${(marketValue / 10000).toStringAsFixed(2)}万';
    } else {
      return '${marketValue.toStringAsFixed(2)}元';
    }
  }
  
  /// 格式化股东户数
  /// [count] 户数
  static String formatHolderCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(2)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(2)}万';
    } else {
      return NumberFormat('#,###').format(count);
    }
  }
  
  /// 格式化百分比
  /// [value] 数值（0-100）
  static String formatPercent(double value) {
    return '${value.toStringAsFixed(2)}%';
  }
  
  /// 格式化市盈率/市净率
  /// [value] 数值
  static String formatRatio(double value) {
    if (value <= 0 || value.isInfinite || value.isNaN) {
      return '-';
    }
    return value.toStringAsFixed(2);
  }
  
  // ==================== 时间格式化 ====================
  
  /// 格式化日期
  /// [date] 日期
  /// [format] 格式，默认 yyyy-MM-dd
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }
  
  /// 格式化日期时间
  /// [dateTime] 日期时间
  /// [format] 格式，默认 yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }
  
  /// 格式化时间
  /// [dateTime] 日期时间
  /// [format] 格式，默认 HH:mm:ss
  static String formatTime(DateTime dateTime, {String format = 'HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }
  
  /// 格式化相对时间
  /// [dateTime] 日期时间
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }
  
  // ==================== 股票代码格式化 ====================
  
  /// 格式化股票代码（添加交易所前缀）
  /// [code] 股票代码
  static String formatStockCode(String code) {
    if (code.startsWith('6') || code.startsWith('9')) {
      return 'SH$code'; // 上海
    } else if (code.startsWith('0') || code.startsWith('2') || code.startsWith('3')) {
      return 'SZ$code'; // 深圳
    } else if (code.startsWith('4') || code.startsWith('8')) {
      return 'BJ$code'; // 北交所
    }
    return code;
  }
  
  /// 提取纯股票代码
  /// [fullCode] 带前缀的代码
  static String extractStockCode(String fullCode) {
    if (fullCode.length > 2) {
      return fullCode.substring(2);
    }
    return fullCode;
  }
  
  // ==================== 金额格式化 ====================
  
  /// 格式化金额（添加千分位）
  /// [amount] 金额
  static String formatMoney(double amount) {
    return NumberFormat('#,###.00').format(amount);
  }
  
  /// 格式化大额金额（带单位）
  /// [amount] 金额
  static String formatLargeMoney(double amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(2)}亿';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    } else {
      return formatMoney(amount);
    }
  }
}

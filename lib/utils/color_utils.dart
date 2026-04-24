import 'package:flutter/material.dart';

/// 颜色工具类
/// 提供颜色相关的工具方法
class ColorUtils {
  // ==================== 涨跌颜色 ====================
  
  /// 根据涨跌值获取颜色
  /// [change] 涨跌额或涨跌幅
  /// [isPercent] 是否为百分比，默认false
  static Color getChangeColor(double change) {
    if (change > 0) {
      return const Color(0xFFEF5350); // 红色（上涨）
    } else if (change < 0) {
      return const Color(0xFF26A69A); // 绿色（下跌）
    } else {
      return const Color(0xFF9E9E9E); // 灰色（平盘）
    }
  }
  
  /// 获取上涨颜色
  static Color get upColor => const Color(0xFFEF5350);
  
  /// 获取下跌颜色
  static Color get downColor => const Color(0xFF26A69A);
  
  /// 获取平盘颜色
  static Color get flatColor => const Color(0xFF9E9E9E);
  
  // ==================== 筹码颜色 ====================
  
  /// 盈利筹码颜色
  static Color get profitColor => const Color(0xFF4CAF50);
  
  /// 亏损筹码颜色
  static Color get lossColor => const Color(0xFFFF5722);
  
  /// 根据当前价格和成本判断筹码颜色
  /// [price] 当前价格
  /// [cost] 成本价
  static Color getChipColor(double price, double cost) {
    if (price >= cost) {
      return profitColor;
    } else {
      return lossColor;
    }
  }
  
  // ==================== 颜色转换 ====================
  
  /// 将十六进制颜色字符串转换为Color
  /// [hex] 十六进制颜色字符串，如 '#FF000000' 或 '0xFF000000'
  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
  
  /// 将Color转换为十六进制颜色字符串
  /// [color] 颜色
  /// [includeAlpha] 是否包含透明度，默认true
  static String toHex(Color color, {bool includeAlpha = true}) {
    if (includeAlpha) {
      return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    } else {
      return '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }
  }
  
  // ==================== 颜色调整 ====================
  
  /// 使颜色变亮
  /// [color] 原颜色
  /// [amount] 变亮程度（0-1），值越大越亮
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// 使颜色变暗
  /// [color] 原颜色
  /// [amount] 变暗程度（0-1），值越大越暗
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// 调整颜色透明度
  /// [color] 原颜色
  /// [opacity] 透明度（0-1）
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
  
  // ==================== K线颜色 ====================
  
  /// K线阳线颜色（上涨）
  static Color get klineUpColor => const Color(0xFFEF5350);
  
  /// K线阴线颜色（下跌）
  static Color get klineDownColor => const Color(0xFF26A69A);
  
  /// K线平盘颜色
  static Color get klineFlatColor => const Color(0xFF9E9E9E);
  
  // ==================== 图表颜色 ====================
  
  /// 图表颜色列表（用于多系列图表）
  static List<Color> get chartColors => const [
    Color(0xFF1E88E5), // 蓝色
    Color(0xFFEF5350), // 红色
    Color(0xFF26A69A), // 绿色
    Color(0xFFFFB74D), // 橙色
    Color(0xFF9575CD), // 紫色
    Color(0xFF4DB6AC), // 青色
    Color(0xFFF06292), // 粉色
    Color(0xFF90A4AE), // 灰蓝色
  ];
  
  /// 获取图表颜色
  /// [index] 颜色索引
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}

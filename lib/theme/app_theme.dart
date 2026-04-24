import 'package:flutter/material.dart';

/// 筹码追踪App深色主题配置
/// 采用金融App经典深色配色，红涨绿跌
class AppTheme {
  // ==================== 颜色定义 ====================
  
  /// 主题主色 - 证券蓝
  static const Color primaryColor = Color(0xFF1E88E5);
  
  /// 上涨颜色 - 中国红
  static const Color upColor = Color(0xFFEF5350);
  
  /// 下跌颜色 - 翠绿
  static const Color downColor = Color(0xFF26A69A);
  
  /// 平盘/持平颜色
  static const Color flatColor = Color(0xFF9E9E9E);
  
  /// 背景色 - 深灰黑
  static const Color backgroundColor = Color(0xFF121212);
  
  /// 卡片背景色
  static const Color cardBackground = Color(0xFF1E1E1E);
  
  /// 表面色
  static const Color surfaceColor = Color(0xFF2D2D2D);
  
  /// 次级文本颜色
  static const Color secondaryTextColor = Color(0xFFB0B0B0);
  
  /// 主文本颜色
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  
  /// 分割线颜色
  static const Color dividerColor = Color(0xFF3D3D3D);
  
  /// 盈利筹码颜色
  static const Color profitColor = Color(0xFF4CAF50);
  
  /// 亏损筹码颜色
  static const Color lossColor = Color(0xFFFF5722);
  
  // ==================== 主题数据 ====================
  
  /// 深色主题数据
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 主题色
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: upColor,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 列表主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.transparent,
      ),
      
      // 分割线
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        hintStyle: const TextStyle(color: secondaryTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 文字主题
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
        ),
      ),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: primaryTextColor,
        size: 24,
      ),
    );
  }
  
  // ==================== 工具方法 ====================
  
  /// 根据涨跌幅获取颜色
  static Color getChangeColor(double change) {
    if (change > 0) return upColor;
    if (change < 0) return downColor;
    return flatColor;
  }
  
  /// 根据涨跌幅获取带符号字符串
  static String formatChangeWithSign(double change) {
    if (change > 0) return '+${change.toStringAsFixed(2)}%';
    return '${change.toStringAsFixed(2)}%';
  }
  
  /// 根据价格获取筹码颜色（相对于成本）
  static Color getChipColor(double price, double costBasis) {
    if (price >= costBasis) return profitColor;
    return lossColor;
  }
}

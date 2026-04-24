import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

/// 股东户数趋势图组件
/// 使用折线图展示股东户数变化趋势
class HolderTrendChart extends StatefulWidget {
  /// 股东户数数据
  final HolderNumber holderNumber;
  
  /// 图表高度
  final double height;

  const HolderTrendChart({
    super.key,
    required this.holderNumber,
    this.height = 200,
  });

  @override
  State<HolderTrendChart> createState() => _HolderTrendChartState();
}

class _HolderTrendChartState extends State<HolderTrendChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和统计信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '股东户数趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
            _buildTrendIndicator(),
          ],
        ),
        const SizedBox(height: 16),
        
        // 折线图
        SizedBox(
          height: widget.height,
          child: _buildLineChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 统计卡片
        _buildStatCards(),
      ],
    );
  }

  /// 构建趋势指示器
  Widget _buildTrendIndicator() {
    final isIncreasing = widget.holderNumber.isIncreasing;
    final changePercent = widget.holderNumber.changePercent.abs();
    final color = isIncreasing ? ColorUtils.downColor : ColorUtils.profitColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${changePercent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建折线图
  Widget _buildLineChart() {
    final history = widget.holderNumber.history;
    if (history.isEmpty) {
      return const Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
      );
    }
    
    // 反转历史数据，使最新的在右边
    final reversedHistory = history.reversed.toList();
    
    // 计算最大值和最小值
    final counts = reversedHistory.map((h) => h.count.toDouble()).toList();
    final maxY = counts.reduce((a, b) => a > b ? a : b) * 1.1;
    final minY = counts.reduce((a, b) => a < b ? a : b) * 0.9;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.dividerColor,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (reversedHistory.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= reversedHistory.length) {
                  return const SizedBox.shrink();
                }
                final data = reversedHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    Formatters.formatDate(data.date, format: 'MM/dd'),
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  Formatters.formatHolderCount(value.toInt()),
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (reversedHistory.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= reversedHistory.length) {
                  return null;
                }
                final data = reversedHistory[index];
                return LineTooltipItem(
                  '${Formatters.formatDate(data.date)}\n${Formatters.formatHolderCount(data.count)}户',
                  const TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            setState(() {
              if (event is FlTapUpEvent) {
                _touchedIndex = response?.lineBarSpots?.first.x.toInt();
              } else {
                _touchedIndex = null;
              }
            });
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              reversedHistory.length,
              (index) => FlSpot(index.toDouble(), reversedHistory[index].count.toDouble()),
            ),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: index == _touchedIndex ? 5 : 3,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: AppTheme.cardBackground,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '最新股东户数',
            Formatters.formatHolderCount(widget.holderNumber.latestCount),
            Icons.people,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '户均持股数',
            Formatters.formatVolume(widget.holderNumber.avgSharesPerHolder.toInt()),
            Icons.stacked_bar_chart,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '户均市值',
            Formatters.formatMarketValue(widget.holderNumber.avgMarketValuePerHolder),
            Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

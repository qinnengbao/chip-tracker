import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

/// 筹码分布图组件
/// 使用横向柱状图展示不同价格区间的筹码量
class ChipDistributionChart extends StatefulWidget {
  /// 筹码分布数据
  final ChipDistribution chipDistribution;
  
  /// 当前价格
  final double currentPrice;
  
  /// 图表高度
  final double height;

  const ChipDistributionChart({
    super.key,
    required this.chipDistribution,
    required this.currentPrice,
    this.height = 200,
  });

  @override
  State<ChipDistributionChart> createState() => _ChipDistributionChartState();
}

class _ChipDistributionChartState extends State<ChipDistributionChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图表标题
        const Text(
          '筹码分布',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // 筹码分布图
        SizedBox(
          height: widget.height,
          child: _buildBarChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 价格区间图例
        _buildLegend(),
        
        const SizedBox(height: 8),
        
        // 当前价格标记
        _buildCurrentPriceMarker(),
      ],
    );
  }

  /// 构建柱状图
  Widget _buildBarChart() {
    final chips = widget.chipDistribution.chips;
    if (chips.isEmpty) {
      return const Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
      );
    }
    
    // 计算最大值，用于Y轴
    final maxRatio = chips.map((c) => c.ratio).reduce((a, b) => a > b ? a : b);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRatio * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final chip = chips[groupIndex];
              return BarTooltipItem(
                '${chip.priceRange}\n${chip.ratio.toStringAsFixed(1)}%\n${Formatters.formatVolume(chip.shares)}股',
                const TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 12,
                ),
              );
            },
          ),
          touchCallback: (event, response) {
            setState(() {
              if (event is FlTapUpEvent) {
                _touchedIndex = response?.spot?.touchedBarGroupIndex;
              } else {
                _touchedIndex = null;
              }
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chips.length) {
                  return const SizedBox.shrink();
                }
                // 每隔几个显示一个标签
                if (chips.length > 10 && index % 4 != 0) {
                  return const SizedBox.shrink();
                }
                final chip = chips[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    chip.priceLow.toStringAsFixed(0),
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxRatio / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.dividerColor,
              strokeWidth: 0.5,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(chips),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            // 当前价格线
            VerticalLine(
              x: _getPricePosition(widget.currentPrice, chips),
              color: AppTheme.primaryColor,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (line) => '当前价',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建柱状组
  List<BarChartGroupData> _buildBarGroups(List<ChipData> chips) {
    return List.generate(chips.length, (index) {
      final chip = chips[index];
      final isTouched = _touchedIndex == index;
      
      // 判断是盈利还是亏损筹码
      final isProfit = chip.profitRatio > 0;
      final color = isProfit ? ColorUtils.profitColor : ColorUtils.lossColor;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: chip.ratio,
            color: isTouched ? color.withOpacity(0.8) : color.withOpacity(0.6),
            width: isTouched ? 16 : 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: chips.map((c) => c.ratio).reduce((a, b) => a > b ? a : b) * 1.2,
              color: AppTheme.surfaceColor,
            ),
          ),
        ],
      );
    });
  }

  /// 计算价格在图表中的位置
  double _getPricePosition(double price, List<ChipData> chips) {
    if (chips.isEmpty) return 0;
    
    final minPrice = chips.first.priceLow;
    final maxPrice = chips.last.priceHigh;
    final priceRange = maxPrice - minPrice;
    
    if (priceRange == 0) return chips.length / 2;
    
    return (price - minPrice) / priceRange * chips.length;
  }

  /// 构建图例
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 盈利筹码
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ColorUtils.profitColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '盈利筹码',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // 亏损筹码
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ColorUtils.lossColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '亏损筹码',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建当前价格标记
  Widget _buildCurrentPriceMarker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriceItem('当前价', widget.currentPrice, AppTheme.primaryColor),
          _buildPriceItem('平均成本', widget.chipDistribution.avgCost, AppTheme.secondaryTextColor),
          _buildPriceItem('支撑位', widget.chipDistribution.supportLevel, ColorUtils.downColor),
          _buildPriceItem('压力位', widget.chipDistribution.resistanceLevel, ColorUtils.upColor),
        ],
      ),
    );
  }

  /// 构建价格项
  Widget _buildPriceItem(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatPrice(price),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

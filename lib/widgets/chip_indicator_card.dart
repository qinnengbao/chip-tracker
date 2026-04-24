import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

/// 筹码指标数据模型
class ChipIndicator {
  final String name;
  final String value;
  final String unit;
  final Color? color;
  final String? description;
  final IconData icon;

  ChipIndicator({
    required this.name,
    required this.value,
    this.unit = '',
    this.color,
    this.description,
    required this.icon,
  });
}

/// 筹码指标卡片组件
/// 展示筹码集中度、主力占比等关键指标
class ChipIndicatorCard extends StatelessWidget {
  /// 筹码集中度（百分比）
  final double concentration;
  
  /// 主力持仓比例（百分比）
  final double mainForceRatio;
  
  /// 平均成本
  final double avgCost;
  
  /// 当前价格
  final double currentPrice;
  
  /// 获利盘比例（百分比）
  final double profitRatio;

  const ChipIndicatorCard({
    super.key,
    required this.concentration,
    required this.mainForceRatio,
    required this.avgCost,
    required this.currentPrice,
    required this.profitRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '筹码指标',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // 指标网格
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildIndicatorCard(
              name: '筹码集中度',
              value: concentration.toStringAsFixed(1),
              unit: '%',
              icon: Icons.grain,
              color: _getConcentrationColor(concentration),
              description: concentration < 30 ? '筹码分散' : concentration < 70 ? '筹码较集中' : '高度集中',
            ),
            _buildIndicatorCard(
              name: '主力持仓',
              value: mainForceRatio.toStringAsFixed(1),
              unit: '%',
              icon: Icons.groups,
              color: AppTheme.primaryColor,
              description: mainForceRatio < 30 ? '主力低控盘' : mainForceRatio < 60 ? '主力高控盘' : '主力高度控盘',
            ),
            _buildIndicatorCard(
              name: '获利盘比例',
              value: profitRatio.toStringAsFixed(1),
              unit: '%',
              icon: Icons.trending_up,
              color: profitRatio > 50 ? ColorUtils.profitColor : ColorUtils.lossColor,
              description: profitRatio > 80 ? '绝大多数盈利' : profitRatio > 50 ? '多数盈利' : '多数亏损',
            ),
            _buildIndicatorCard(
              name: '成本偏离度',
              value: ((currentPrice - avgCost) / avgCost * 100).abs().toStringAsFixed(1),
              unit: '%',
              icon: Icons.compare_arrows,
              color: currentPrice >= avgCost ? ColorUtils.profitColor : ColorUtils.lossColor,
              description: currentPrice >= avgCost ? '股价高于成本' : '股价低于成本',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 成本分布图
        _buildCostDistributionBar(),
      ],
    );
  }

  /// 根据集中度获取颜色
  Color _getConcentrationColor(double value) {
    if (value < 30) return ColorUtils.downColor;
    if (value < 70) return AppTheme.primaryColor;
    return ColorUtils.upColor;
  }

  /// 构建指标卡片
  Widget _buildIndicatorCard({
    required String name,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    String? description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题行
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // 数值行
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
          
          // 描述
          if (description != null)
            Text(
              description,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.secondaryTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// 构建成本分布条
  Widget _buildCostDistributionBar() {
    final profitWidth = profitRatio / 100;
    final lossWidth = 1 - profitWidth;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '成本分布',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // 分布条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                // 盈利部分
                Expanded(
                  flex: (profitWidth * 100).round(),
                  child: Container(
                    height: 16,
                    color: ColorUtils.profitColor,
                    child: profitWidth > 0.15
                        ? Center(
                            child: Text(
                              '盈利 ${(profitRatio).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                // 亏损部分
                Expanded(
                  flex: (lossWidth * 100).round(),
                  child: Container(
                    height: 16,
                    color: ColorUtils.lossColor,
                    child: lossWidth > 0.15
                        ? Center(
                            child: Text(
                              '亏损 ${(100 - profitRatio).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColorUtils.lossColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '平均成本 ${Formatters.formatPrice(avgCost)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColorUtils.profitColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '当前价 ${Formatters.formatPrice(currentPrice)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

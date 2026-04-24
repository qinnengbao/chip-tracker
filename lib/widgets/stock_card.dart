import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

/// 股票列表项卡片组件
/// 用于展示单个股票的基本信息和涨跌情况
class StockCard extends StatelessWidget {
  /// 股票数据
  final Stock stock;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 是否显示删除按钮
  final bool showDelete;
  
  /// 删除回调
  final VoidCallback? onDelete;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 股票信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 股票名称和代码
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            stock.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stock.fullCode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 当前价格
                    Text(
                      Formatters.formatPrice(stock.currentPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorUtils.getChangeColor(stock.change),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 涨跌信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 涨跌幅
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorUtils.getChangeColor(stock.change).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Formatters.formatChangePercent(stock.changePercent),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorUtils.getChangeColor(stock.change),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 涨跌额
                  Text(
                    Formatters.formatChange(stock.change),
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.getChangeColor(stock.change),
                    ),
                  ),
                ],
              ),
              
              // 删除按钮
              if (showDelete) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.secondaryTextColor,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 股票行情卡片组件（简化版）
/// 用于自选股列表展示
class StockQuoteCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const StockQuoteCard({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 股票名称
            Text(
              stock.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 股票代码
            Text(
              stock.code,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            // 价格
            Text(
              Formatters.formatPrice(stock.currentPrice),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorUtils.getChangeColor(stock.change),
              ),
            ),
            const SizedBox(height: 4),
            // 涨跌幅
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ColorUtils.getChangeColor(stock.change).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                Formatters.formatChangePercent(stock.changePercent),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.getChangeColor(stock.change),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

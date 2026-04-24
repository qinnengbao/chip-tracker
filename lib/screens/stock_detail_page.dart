import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

/// 股票详情页面
/// 展示股票的筹码分布、股东户数等详细信息
class StockDetailPage extends StatefulWidget {
  /// 股票代码
  final String stockCode;

  const StockDetailPage({
    super.key,
    required this.stockCode,
  });

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StockDetailProvider _detailProvider;
  bool _isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _detailProvider = StockDetailProvider(StockService());
    
    // 加载股票详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detailProvider.loadStockDetail(widget.stockCode);
      _checkWatchlist();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _detailProvider.dispose();
    super.dispose();
  }

  /// 检查是否在自选股列表中
  void _checkWatchlist() {
    final watchlist = context.read<WatchlistProvider>().watchlist;
    setState(() {
      _isInWatchlist = watchlist.contains(widget.stockCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _detailProvider,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Consumer<StockDetailProvider>(
          builder: (context, provider, child) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(provider),
                  _buildPriceHeader(provider),
                  _buildTabBar(),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildChipTab(provider),
                  _buildHolderTab(provider),
                  _buildInfoTab(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建SliverAppBar
  Widget _buildSliverAppBar(StockDetailProvider provider) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      title: Text(provider.stock?.name ?? widget.stockCode),
      actions: [
        // 自选按钮
        IconButton(
          icon: Icon(
            _isInWatchlist ? Icons.star : Icons.star_outline,
            color: _isInWatchlist ? Colors.amber : null,
          ),
          onPressed: _toggleWatchlist,
        ),
        // 分享按钮
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
        // 更多按钮
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {},
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'notes', child: Text('笔记')),
            const PopupMenuItem(value: 'alert', child: Text('价格提醒')),
            const PopupMenuItem(value: 'compare', child: Text('对比')),
          ],
        ),
      ],
    );
  }

  /// 构建价格头部
  Widget _buildPriceHeader(StockDetailProvider provider) {
    final stock = provider.stock;
    final quote = provider.quote;
    
    if (stock == null && quote == null) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final currentPrice = quote?.currentPrice ?? stock?.currentPrice ?? 0;
    final change = quote?.change ?? stock?.change ?? 0;
    final changePercent = quote?.changePercent ?? stock?.changePercent ?? 0;
    final priceColor = ColorUtils.getChangeColor(change);

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 股票代码和名称
            Row(
              children: [
                Text(
                  stock?.name ?? quote?.stockName ?? widget.stockCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stock?.fullCode ?? widget.stockCode,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 价格和涨跌
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 当前价格
                Text(
                  Formatters.formatPrice(currentPrice),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
                const SizedBox(width: 12),
                // 涨跌额和涨跌幅
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priceColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        Formatters.formatChangePercent(changePercent),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: priceColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatChange(change),
                      style: TextStyle(
                        fontSize: 14,
                        color: priceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 关键指标
            _buildKeyIndicators(quote, stock),
          ],
        ),
      ),
    );
  }

  /// 构建关键指标行
  Widget _buildKeyIndicators(Quote? quote, Stock? stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildIndicatorItem('今开', Formatters.formatPrice(quote?.openPrice ?? stock?.openPrice ?? 0)),
        _buildIndicatorItem('最高', Formatters.formatPrice(quote?.highPrice ?? stock?.highPrice ?? 0)),
        _buildIndicatorItem('最低', Formatters.formatPrice(quote?.lowPrice ?? stock?.lowPrice ?? 0)),
        _buildIndicatorItem('成交量', Formatters.formatVolume(quote?.volume ?? stock?.volume ?? 0)),
      ],
    );
  }

  /// 构建指标项
  Widget _buildIndicatorItem(String label, String value) {
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
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }

  /// 构建TabBar
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: '筹码分布'),
            Tab(text: '股东户数'),
            Tab(text: '公司信息'),
          ],
        ),
      ),
    );
  }

  /// 筹码分布标签页
  Widget _buildChipTab(StockDetailProvider provider) {
    final chipDist = provider.chipDistribution;
    final quote = provider.quote;
    final stock = provider.stock;
    
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chipDist == null) {
      return _buildEmptyState('暂无筹码分布数据');
    }

    final currentPrice = quote?.currentPrice ?? stock?.currentPrice ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 筹码分布图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ChipDistributionChart(
                chipDistribution: chipDist,
                currentPrice: currentPrice,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 筹码指标卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ChipIndicatorCard(
                concentration: chipDist.concentration,
                mainForceRatio: chipDist.mainForceRatio,
                avgCost: chipDist.avgCost,
                currentPrice: currentPrice,
                profitRatio: chipDist.chips.isNotEmpty 
                    ? chipDist.chips.where((c) => c.profitRatio > 0).fold(0.0, (sum, c) => sum + c.ratio)
                    : 50,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 龙虎榜信息
          if (provider.dragonTiger != null) _buildDragonTigerCard(provider.dragonTiger!),
        ],
      ),
    );
  }

  /// 股东户数标签页
  Widget _buildHolderTab(StockDetailProvider provider) {
    final holderNumber = provider.holderNumber;
    
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (holderNumber == null) {
      return _buildEmptyState('暂无股东户数数据');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 股东户数趋势图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HolderTrendChart(holderNumber: holderNumber),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 股东户数详情
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHolderDetail(holderNumber),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建股东户数详情
  Widget _buildHolderDetail(HolderNumber holderNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '股东户数详情',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // 变化趋势说明
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                holderNumber.isIncreasing 
                    ? Icons.trending_up 
                    : Icons.trending_down,
                color: holderNumber.isIncreasing 
                    ? ColorUtils.downColor 
                    : ColorUtils.profitColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  holderNumber.isIncreasing
                      ? '股东户数增加，筹码分散'
                      : '股东户数减少，筹码集中',
                  style: TextStyle(
                    fontSize: 14,
                    color: holderNumber.isIncreasing 
                        ? ColorUtils.downColor 
                        : ColorUtils.profitColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 详细数据表格
        _buildDetailRow('最新股东户数', Formatters.formatHolderCount(holderNumber.latestCount)),
        _buildDetailRow('较上期变化', '${holderNumber.changeCount > 0 ? '+' : ''}${Formatters.formatHolderCount(holderNumber.changeCount.abs())}'),
        _buildDetailRow('变化比例', '${holderNumber.changePercent > 0 ? '+' : ''}${holderNumber.changePercent.toStringAsFixed(2)}%'),
        _buildDetailRow('户均持股数', Formatters.formatVolume(holderNumber.avgSharesPerHolder.toInt())),
        _buildDetailRow('户均市值', Formatters.formatMarketValue(holderNumber.avgMarketValuePerHolder)),
      ],
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 公司信息标签页
  Widget _buildInfoTab(StockDetailProvider provider) {
    final stock = provider.stock;
    final quote = provider.quote;
    
    if (stock == null && quote == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 基本信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoSection('基本信息', [
                _buildInfoRow('股票代码', stock?.fullCode ?? widget.stockCode),
                _buildInfoRow('股票名称', stock?.name ?? quote?.stockName ?? '-'),
                _buildInfoRow('交易所', stock?.exchange == 'SH' ? '上海证券交易所' : '深圳证券交易所'),
              ]),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 估值指标卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoSection('估值指标', [
                _buildInfoRow('市盈率(PE)', Formatters.formatRatio(quote?.pe ?? stock?.pe ?? 0)),
                _buildInfoRow('市净率(PB)', Formatters.formatRatio(quote?.pb ?? stock?.pb ?? 0)),
                _buildInfoRow('总市值', Formatters.formatMarketValue(quote?.totalMarketValue ?? stock?.totalMarketValue ?? 0)),
                _buildInfoRow('流通市值', Formatters.formatMarketValue(quote?.flowMarketValue ?? stock?.flowMarketValue ?? 0)),
              ]),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 交易指标卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoSection('交易指标', [
                _buildInfoRow('换手率', '${Formatters.formatPercent(quote?.turnoverRate ?? stock?.turnoverRate ?? 0)}'),
                _buildInfoRow('成交额', Formatters.formatAmount(quote?.amount ?? stock?.amount ?? 0)),
                _buildInfoRow('52周最高', Formatters.formatPrice(quote?.high52Week ?? stock?.high52Week ?? 0)),
                _buildInfoRow('52周最低', Formatters.formatPrice(quote?.low52Week ?? stock?.low52Week ?? 0)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息区块
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建龙虎榜卡片
  Widget _buildDragonTigerCard(DragonTiger dragonTiger) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '龙虎榜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '上榜${dragonTiger.appearCount}次',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 最新龙虎榜记录
            if (dragonTiger.records.isNotEmpty) ...[
              ...dragonTiger.records.take(3).map((record) => _buildDragonTigerItem(record)),
            ] else
              const Text(
                '暂无龙虎榜记录',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建龙虎榜项
  Widget _buildDragonTigerItem(DragonTigerRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatDate(record.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              Text(
                Formatters.formatChangePercent(record.changePercent),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.getChangeColor(record.changePercent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record.reason,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 切换自选状态
  void _toggleWatchlist() async {
    final watchlistProvider = context.read<WatchlistProvider>();
    
    if (_isInWatchlist) {
      await watchlistProvider.removeFromWatchlist(widget.stockCode);
    } else {
      await watchlistProvider.addToWatchlist(widget.stockCode);
    }
    
    setState(() {
      _isInWatchlist = !_isInWatchlist;
    });
  }
}

/// TabBar代理类
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

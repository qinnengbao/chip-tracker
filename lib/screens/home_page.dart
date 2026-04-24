import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'stock_detail_page.dart';
import 'search_page.dart';

/// 首页
/// 展示自选股列表和快速搜索入口
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化加载自选股
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _WatchlistTab(),
          _MarketTab(),
          _DiscoverTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToSearch(),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: '自选',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.candlestick_chart_outlined),
          activeIcon: Icon(Icons.candlestick_chart),
          label: '行情',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: '发现',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }

  /// 跳转到搜索页
  void _navigateToSearch() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
    
    if (result != null && mounted) {
      // 添加到自选股
      context.read<WatchlistProvider>().addToWatchlist(result);
    }
  }
}

/// 自选股列表标签页
class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自选'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WatchlistProvider>().refreshQuotes();
            },
          ),
        ],
      ),
      body: Consumer<WatchlistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.watchlistStocks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.watchlistStocks.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.refreshQuotes(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.watchlistStocks.length,
              itemBuilder: (context, index) {
                final stock = provider.watchlistStocks[index];
                return Dismissible(
                  key: Key(stock.code),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmation(context);
                  },
                  onDismissed: (direction) {
                    provider.removeFromWatchlist(stock.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已删除 ${stock.name}'),
                        action: SnackBarAction(
                          label: '撤销',
                          onPressed: () {
                            provider.addToWatchlist(stock.code);
                          },
                        ),
                      ),
                    );
                  },
                  child: StockCard(
                    stock: stock,
                    onTap: () => _navigateToDetail(context, stock.code),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无自选股',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角 + 添加股票',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('添加自选'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('删除自选'),
        content: const Text('确定要从自选列表中删除该股票吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 跳转到股票详情页
  void _navigateToDetail(BuildContext context, String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(stockCode: code),
      ),
    );
  }
}

/// 行情标签页（占位）
class _MarketTab extends StatelessWidget {
  const _MarketTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行情'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.candlestick_chart,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              '行情页面开发中...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 发现标签页（占位）
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              '发现页面开发中...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 我的标签页（占位）
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              '个人中心开发中...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

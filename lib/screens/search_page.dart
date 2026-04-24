import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

/// 股票搜索页面
/// 支持按代码或名称搜索股票
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StockService _stockService = StockService();
  
  /// 搜索结果列表
  List<Stock> _searchResults = [];
  
  /// 搜索历史
  List<String> _searchHistory = [];
  
  /// 是否正在搜索
  bool _isSearching = false;
  
  /// 是否显示搜索结果
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: const TextStyle(color: AppTheme.primaryTextColor),
        decoration: InputDecoration(
          hintText: '输入股票代码或名称',
          hintStyle: const TextStyle(color: AppTheme.secondaryTextColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.secondaryTextColor),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showResults = false;
                      _searchResults = [];
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) => _onSearch(value),
        onSubmitted: (value) => _performSearch(value),
        textInputAction: TextInputAction.search,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _performSearch(_searchController.text),
        ),
      ],
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_showResults) {
      return _buildSearchResults();
    }
    return _buildSearchHistory();
  }

  /// 构建搜索历史
  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索提示
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '搜索股票示例',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
            ),
          ),
        ),
        
        // 热门股票
        _buildHotStocks(),
        
        const SizedBox(height: 24),
        
        // 搜索历史
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text(
                    '清空',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final code = _searchHistory[_searchHistory.length - 1 - index];
                return ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                  title: Text(
                    code,
                    style: const TextStyle(color: AppTheme.primaryTextColor),
                  ),
                  onTap: () {
                    _searchController.text = code;
                    _performSearch(code);
                  },
                );
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: AppTheme.secondaryTextColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '输入关键词搜索股票',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建热门股票列表
  Widget _buildHotStocks() {
    final hotStocks = [
      {'code': '000001', 'name': '平安银行'},
      {'code': '600519', 'name': '贵州茅台'},
      {'code': '000858', 'name': '五粮液'},
      {'code': '601318', 'name': '中国平安'},
      {'code': '600036', 'name': '招商银行'},
      {'code': '000002', 'name': '万科A'},
      {'code': '600276', 'name': '恒瑞医药'},
      {'code': '002594', 'name': '比亚迪'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '热门股票',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hotStocks.map((stock) {
              return ActionChip(
                label: Text(
                  '${stock['name']} ${stock['code']}',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: AppTheme.surfaceColor,
                onPressed: () {
                  _searchController.text = stock['code']!;
                  _performSearch(stock['code']!);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.secondaryTextColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              '未找到相关股票',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return _buildSearchResultItem(stock);
      },
    );
  }

  /// 构建搜索结果项
  Widget _buildSearchResultItem(Stock stock) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _selectStock(stock),
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
                    Row(
                      children: [
                        // 股票名称
                        Text(
                          stock.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 股票代码
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            stock.fullCode,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 交易所
                    Text(
                      stock.exchange == 'SH' ? '上海证券交易所' : '深圳证券交易所',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 添加按钮
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _selectStock(stock),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索输入事件处理
  void _onSearch(String value) {
    setState(() {});
    
    // 防抖处理
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == value && value.isNotEmpty) {
        _performSearch(value);
      }
    });
  }

  /// 执行搜索
  Future<void> _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final results = await _stockService.searchStocks(keyword);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  /// 选择股票
  void _selectStock(Stock stock) {
    // 添加到搜索历史
    if (!_searchHistory.contains(stock.code)) {
      setState(() {
        _searchHistory.add(stock.code);
        // 限制历史记录数量
        if (_searchHistory.length > 20) {
          _searchHistory.removeAt(0);
        }
      });
    }
    
    // 返回选中的股票代码
    Navigator.pop(context, stock.code);
  }
}

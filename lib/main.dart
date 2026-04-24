import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/providers.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';

/// 筹码追踪软件入口文件
/// 采用Provider模式进行状态管理
void main() {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // 锁定竖屏方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ChipTrackingApp());
}

/// 筹码追踪App根组件
class ChipTrackingApp extends StatelessWidget {
  const ChipTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 股票服务
        Provider<StockService>(
          create: (_) => StockService(),
        ),
        
        // 自选股状态管理
        ChangeNotifierProxyProvider<StockService, WatchlistProvider>(
          create: (context) => WatchlistProvider(
            context.read<StockService>(),
          ),
          update: (context, stockService, previous) =>
              previous ?? WatchlistProvider(stockService),
        ),
      ],
      child: MaterialApp(
        title: '筹码追踪',
        debugShowCheckedModeBanner: false,
        
        // 主题配置
        theme: AppTheme.darkTheme,
        
        // 首页
        home: const HomePage(),
        
        // 路由配置
        onGenerateRoute: _generateRoute,
        
        // 错误处理
        builder: (context, child) {
          // 全局错误捕获
          ErrorWidget.builder = (details) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.upColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '页面出错了',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details.exceptionAsString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            );
          };
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
  
  /// 路由生成器
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case '/search':
        return MaterialPageRoute(
          builder: (_) => const SearchPage(),
        );
      case '/detail':
        final code = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => StockDetailPage(stockCode: code ?? ''),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
    }
  }
}

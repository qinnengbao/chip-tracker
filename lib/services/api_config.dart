import 'package:dio/dio.dart';

/// API服务配置类
/// 管理API基础配置和连接设置
class ApiConfig {
  // ==================== API配置 ====================
  
  /// API基础URL - 开发环境
  /// TODO: 部署时替换为实际后端服务器地址
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  /// 连接超时时间（毫秒）
  static const int connectTimeout = 10000;
  
  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 15000;
  
  /// 是否启用日志
  static const bool enableLog = true;
  
  // ==================== API端点 ====================
  
  /// 股票相关接口
  static const String stockList = '/stocks';
  static const String stockDetail = '/stocks/{code}';
  static const String stockSearch = '/stocks/search';
  static const String stockQuote = '/quotes/{code}';
  
  /// 筹码分布接口
  static const String chipDistribution = '/chips/{code}';
  static const String chipHistory = '/chips/{code}/history';
  
  /// 股东户数接口
  static const String holderNumber = '/holders/{code}';
  static const String holderHistory = '/holders/{code}/history';
  
  /// 龙虎榜接口
  static const String dragonTiger = '/dragonTiger/{code}';
  
  /// 自选股接口
  static const String watchlist = '/watchlist';
  
  // ==================== 请求头配置 ====================
  
  /// 默认请求头
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'ChipTracking/1.0.0',
  };
  
  // ==================== Dio实例工厂 ====================
  
  /// 创建配置好的Dio实例
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: connectTimeout),
      receiveTimeout: const Duration(milliseconds: receiveTimeout),
      headers: defaultHeaders,
    ));
    
    // 添加拦截器
    dio.interceptors.add(ApiInterceptor());
    
    // 开发环境添加日志拦截器
    if (enableLog) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
    
    return dio;
  }
}

/// API拦截器
/// 用于统一处理请求和响应
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 可以在这里添加统一的请求参数，如token等
    // options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 可以在这里统一处理响应
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 统一错误处理
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络';
        break;
      case DioExceptionType.sendTimeout:
        message = '发送请求超时';
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收数据超时';
        break;
      case DioExceptionType.badResponse:
        message = '服务器错误: ${err.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络';
        break;
      default:
        message = '网络异常: ${err.message}';
    }
    
    // 创建一个新的错误，携带友好的错误信息
    final newError = DioException(
      requestOptions: err.requestOptions,
      error: message,
      type: err.type,
      response: err.response,
    );
    
    super.onError(newError, handler);
  }
}

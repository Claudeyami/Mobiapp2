import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    final baseUrl = 'http://10.0.2.2:4000/api';
    print('🔧 Initializing ApiClient with baseUrl: $baseUrl');
    
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getInt('user_id');
          if (userId != null) {
            options.headers['X-User-Id'] = userId.toString();
            options.headers['userId'] = userId.toString();
          }
        } catch (e) {
          print('⚠️ Error getting user ID for header: $e');
        }
        
        print('➡️ REQUEST: ${options.method} ${options.uri}');
        print('   Headers: ${options.headers}');
        if (options.data != null) {
          print('   Data: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('⬅️ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        if (response.requestOptions.uri.toString().contains('/movies/') && 
            !response.requestOptions.uri.toString().contains('/comments') &&
            !response.requestOptions.uri.toString().contains('/ratings')) {
          final dataStr = response.data?.toString() ?? 'null';
          final preview = dataStr.length > 200 ? '${dataStr.substring(0, 200)}...' : dataStr;
          print('   📦 Response data preview: $preview');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR: ${error.type} - ${error.message}');
        if (error.response != null) {
          print('   Status: ${error.response?.statusCode}');
          print('   Data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }
}

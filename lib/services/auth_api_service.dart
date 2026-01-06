import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/login_response.dart';

class AuthApiService {
  final ApiClient _api = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<LoginResponse> register(String email, String password, String name) async {
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': name,
        },
      );
      print('📦 Register response data: ${response.data}');
      print('📦 Response type: ${response.data.runtimeType}');
      final loginResponse = LoginResponse.fromJson(response.data);
      print('✅ Parsed LoginResponse: ok=${loginResponse.ok}, userId=${loginResponse.userId}');
      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        try {
          final response = await _api.post(
            '/auth/register',
            data: {
              'email': email,
              'password': password,
              'name': name,
            },
          );
          print('📦 Register response data (retry with name): ${response.data}');
          final loginResponse = LoginResponse.fromJson(response.data);
          print('✅ Parsed LoginResponse: ok=${loginResponse.ok}, userId=${loginResponse.userId}');
          return loginResponse;
        } on DioException {
          throw Exception(_handleDioError(e));
        }
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('❌ Register error: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is TypeError) {
        throw Exception('Lỗi xử lý dữ liệu từ server. Vui lòng thử lại.');
      }
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final endpoints = [
        '/users/$userId',
        '/users/me',
        '/profile',
        '/user/profile',
      ];

      DioException? lastError;

      for (final endpoint in endpoints) {
        try {
          final response = await _api.get(endpoint);
          return response.data;
        } on DioException catch (e) {
          lastError = e;
          if (e.response?.statusCode == 404) {
            continue;
          }
        }
      }
      return {
        'id': userId,
        'name': '',
        'email': '',
      };
    } on DioException catch (e) {
      return {
        'id': userId,
        'name': '',
        'email': '',
      };
    } catch (e) {
      return {
        'id': userId,
        'name': '',
        'email': '',
      };
    }
  }

  Future<bool> updateUserProfile(
    int userId,
    String name,
    String? email, {
    String? phone,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    final endpoints = [
      '/users/$userId',
      '/users/me',
      '/profile',
      '/user/profile',
    ];

    DioException? lastError;
    for (final endpoint in endpoints) {
      try {
        await _api.put(endpoint, data: data);
        return true;
      } on DioException catch (e) {
        lastError = e;
        if (e.response?.statusCode == 404) {
          try {
            await _api.patch(endpoint, data: data);
            return true;
          } on DioException catch (e2) {
            if (e2.response?.statusCode != 404) {
              throw Exception(_handleDioError(e2));
            }
            continue;
          }
        } else {
          throw Exception(_handleDioError(e));
        }
      }
    }

    return false;
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      String? serverMessage;
      if (data is Map<String, dynamic>) {
        serverMessage = data['message'] ?? 
                       data['error'] ?? 
                       data['msg'];
        
        if (serverMessage == null && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            serverMessage = errors[0].toString();
          } else if (errors is Map && errors.isNotEmpty) {
            final errorMessages = errors.values
                .map((e) => e.toString())
                .where((msg) => msg.isNotEmpty)
                .join(', ');
            if (errorMessages.isNotEmpty) {
              serverMessage = errorMessages;
            } else {
              serverMessage = errors.values.first.toString();
            }
          }
        }
        
        if (serverMessage == null && data['missingFields'] != null) {
          final missingFields = data['missingFields'];
          if (missingFields is List) {
            serverMessage = 'Thiếu các trường: ${missingFields.join(', ')}';
          } else if (missingFields is String) {
            serverMessage = 'Thiếu trường: $missingFields';
          }
        }
      }
      
      if (serverMessage != null && serverMessage.isNotEmpty) {
        if (statusCode == 409) {
          if (serverMessage.toLowerCase().contains('email') && 
              serverMessage.toLowerCase().contains('username')) {
            return 'Email hoặc tên người dùng đã tồn tại. Vui lòng thử lại.';
          } else if (serverMessage.toLowerCase().contains('email')) {
            return 'Email đã được sử dụng. Vui lòng chọn email khác.';
          } else if (serverMessage.toLowerCase().contains('username')) {
            return 'Tên người dùng đã tồn tại. Vui lòng chọn tên khác.';
          }
        }
        return serverMessage;
      }
      
      switch (statusCode) {
        case 400:
          return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
        case 401:
          return 'Email hoặc mật khẩu không đúng.';
        case 409:
          return 'Email hoặc tên người dùng đã tồn tại. Vui lòng thử lại.';
        case 422:
          return 'Thông tin không hợp lệ. Vui lòng kiểm tra lại.';
        case 500:
          return 'Lỗi server. Vui lòng thử lại sau.';
        default:
          return 'Đã xảy ra lỗi (Status: $statusCode)';
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng kiểm tra kết nối mạng.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }
    
    return 'Đã xảy ra lỗi: ${e.message ?? e.toString()}';
  }
}

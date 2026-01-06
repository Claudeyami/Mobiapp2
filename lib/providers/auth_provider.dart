import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _authApi = AuthApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _error = '';
  int? _userId;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get error => _error;
  int? get userId => _userId;

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    _isAuthenticated = _userId != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final res = await _authApi.login(email, password);
      if (res.ok && res.userId != null) {
        _userId = res.userId;
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', res.userId!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email hoặc mật khẩu không đúng';
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _error = errorMsg;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final res = await _authApi.register(email, password, name);
      if (res.ok) {
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Đăng ký thất bại. Vui lòng thử lại.';
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      } else if (errorMsg.contains("type 'Null' is not a subtype")) {
        errorMsg = 'Lỗi xử lý dữ liệu từ server. Vui lòng thử lại.';
      } else if (errorMsg.contains('is not a subtype')) {
        errorMsg = 'Lỗi định dạng dữ liệu. Vui lòng thử lại.';
      }
      _error = errorMsg;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }
}

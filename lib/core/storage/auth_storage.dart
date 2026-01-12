import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(String token) async {
    try {
      if (token.isEmpty || token.trim().isEmpty) {
        print('⚠️ AuthStorage: Cannot save empty token');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final trimmedToken = token.trim();
      await prefs.setString(_tokenKey, trimmedToken);
      print('✅ AuthStorage: Token saved successfully (${trimmedToken.length} chars, key: $_tokenKey)');
      print('   Token preview: ${trimmedToken.length > 20 ? trimmedToken.substring(0, 20) + "..." : trimmedToken}');
    } catch (e) {
      print('⚠️ AuthStorage: Error saving token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      print('🔍 AuthStorage: Checking for token (key: $_tokenKey)');
      print('   Available keys: ${allKeys.where((k) => k.contains('token') || k.contains('auth')).join(", ")}');
      
      final token = prefs.getString(_tokenKey);
      if (token != null && token.trim().isNotEmpty) {
        final trimmedToken = token.trim();
        print('✅ AuthStorage: Token loaded from storage (${trimmedToken.length} chars)');
        print('   Token preview: ${trimmedToken.length > 20 ? trimmedToken.substring(0, 20) + "..." : trimmedToken}');
        return trimmedToken;
      } else {
        print('⚠️ AuthStorage: No token found in storage (key: $_tokenKey)');
        final alternateToken = prefs.getString('auth_token');
        if (alternateToken != null && alternateToken.trim().isNotEmpty) {
          print('🔄 AuthStorage: Found token with alternate key "auth_token", migrating...');
          await saveToken(alternateToken);
          return alternateToken.trim();
        }
        return null;
      }
    } catch (e) {
      print('⚠️ AuthStorage: Error getting token: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hadToken = prefs.containsKey(_tokenKey) || prefs.containsKey('auth_token');
      await prefs.remove(_tokenKey);
      await prefs.remove('auth_token');
      await prefs.remove(_userIdKey);
      if (hadToken) {
        print('🔒 AuthStorage: Token cleared successfully (removed $_tokenKey and auth_token)');
      }
    } catch (e) {
      print('⚠️ AuthStorage: Error clearing token: $e');
    }
  }

  static Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey) ?? prefs.getString('auth_token');
      final hasToken = token != null && token.trim().isNotEmpty;
      if (!hasToken) {
        print('⚠️ AuthStorage.hasToken(): No valid token found');
      }
      return hasToken;
    } catch (e) {
      print('⚠️ AuthStorage.hasToken(): Error checking token: $e');
      return false;
    }
  }
}

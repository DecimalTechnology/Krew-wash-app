import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _userDataKey = 'user_data';

  // Save tokens
  static Future<void> saveTokens({
    String? UseraccessToken,
    String? UserrefreshToken,
    String? idToken,
  }) async {
    try {
      if (UseraccessToken != null) {
        await _storage.write(key: _accessTokenKey, value: UseraccessToken);
        if (kDebugMode) {
          print('🔐 Access token saved to secure storage');
        }
      }

      if (UserrefreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: UserrefreshToken);
        if (kDebugMode) {
          print('🔄 Refresh token saved to secure storage');
        }
      }

      if (idToken != null) {
        await _storage.write(key: _idTokenKey, value: idToken);
        if (kDebugMode) {
          print('🆔 ID token saved to secure storage');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving tokens: $e');
      }
    }
  }

  // Get tokens
  static Future<Map<String, String?>> getTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final idToken = await _storage.read(key: _idTokenKey);

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'idToken': idToken,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading tokens: $e');
      }
      return {};
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading access token: $e');
      }
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading refresh token: $e');
      }
      return null;
    }
  }

  // Get ID token
  static Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _idTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading ID token: $e');
      }
      return null;
    }
  }

  // Save user data
  static Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
      if (kDebugMode) {
        print('👤 User data saved to secure storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving user data: $e');
      }
    }
  }

  // Get user data
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading user data: $e');
      }
      return null;
    }
  }

  // Clear all tokens and user data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        print('🗑️ All secure storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing secure storage: $e');
      }
    }
  }

  // Clear specific token
  static Future<void> clearToken(String tokenType) async {
    try {
      String key;
      switch (tokenType.toLowerCase()) {
        case 'access':
          key = _accessTokenKey;
          break;
        case 'refresh':
          key = _refreshTokenKey;
          break;
        case 'id':
          key = _idTokenKey;
          break;
        default:
          return;
      }

      await _storage.delete(key: key);
      if (kDebugMode) {
        print('🗑️ $tokenType token cleared from secure storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing $tokenType token: $e');
      }
    }
  }

  // Check if user is logged in (has tokens)
  static Future<bool> isLoggedIn() async {
    try {
      final tokens = await getTokens();
      return tokens['accessToken'] != null || tokens['idToken'] != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking login status: $e');
      }
      return false;
    }
  }
}

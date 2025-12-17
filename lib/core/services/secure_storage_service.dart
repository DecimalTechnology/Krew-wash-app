import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token keys for customers
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _userDataKey = 'user_data';

  // Token keys for staff/cleaners
  static const String _staffAccessTokenKey = 'staff_access_token';
  static const String _staffDataKey = 'staff_data';

  // Pending booking (for payment retry)
  static const String _pendingBookingKey = 'pending_booking';

  // Save tokens
  static Future<void> saveTokens({
    String? UseraccessToken,
    String? UserrefreshToken,
    String? idToken,
  }) async {
    try {
      if (UseraccessToken != null) {
        await _storage.write(key: _accessTokenKey, value: UseraccessToken);
      }

      if (UserrefreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: UserrefreshToken);
      }

      if (idToken != null) {
        await _storage.write(key: _idTokenKey, value: idToken);
      }
    } catch (e) {
      // Error saving tokens
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
      return {};
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get ID token
  static Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _idTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Save user data
  static Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      // Error saving user data
    }
  }

  // Get user data
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      return null;
    }
  }

  // Clear all tokens and user data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Error clearing secure storage
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
    } catch (e) {
      // Error clearing token
    }
  }

  // Check if user is logged in (has tokens)
  static Future<bool> isLoggedIn() async {
    try {
      final tokens = await getTokens();
      return tokens['accessToken'] != null || tokens['idToken'] != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // STAFF/CLEANER STORAGE METHODS
  // ============================================

  // Save staff tokens
  static Future<void> saveStaffTokens({required String accessToken}) async {
    try {
      await _storage.write(key: _staffAccessTokenKey, value: accessToken);
    } catch (e) {
      // Error saving staff tokens
    }
  }

  // Get staff access token
  static Future<String?> getStaffAccessToken() async {
    try {
      return await _storage.read(key: _staffAccessTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Save staff data
  static Future<void> saveStaffData(String staffData) async {
    try {
      await _storage.write(key: _staffDataKey, value: staffData);
    } catch (e) {
      // Error saving staff data
    }
  }

  // Get staff data
  static Future<String?> getStaffData() async {
    try {
      return await _storage.read(key: _staffDataKey);
    } catch (e) {
      return null;
    }
  }

  // Check if staff is logged in
  static Future<bool> isStaffLoggedIn() async {
    try {
      final token = await getStaffAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Clear staff data
  static Future<void> clearStaffData() async {
    try {
      await _storage.delete(key: _staffAccessTokenKey);
      await _storage.delete(key: _staffDataKey);
    } catch (e) {
      // Error clearing staff data
    }
  }

  // ============================================
  // PENDING BOOKING (PAYMENT RETRY) METHODS
  // ============================================

  static Future<void> savePendingBooking({
    required String bookingId,
    required String signature,
  }) async {
    try {
      final payload = jsonEncode({
        'bookingId': bookingId,
        'signature': signature,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _storage.write(key: _pendingBookingKey, value: payload);
    } catch (e) {
      // Error saving pending booking
    }
  }

  static Future<Map<String, dynamic>?> getPendingBooking() async {
    try {
      final raw = await _storage.read(key: _pendingBookingKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearPendingBooking() async {
    try {
      await _storage.delete(key: _pendingBookingKey);
    } catch (e) {
      // Error clearing pending booking
    }
  }
}

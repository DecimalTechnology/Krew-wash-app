import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api.dart';

class StaffRepository {
  /// Login cleaner with cleanerId and password
  static Future<Map<String, dynamic>> loginCleaner({
    required String cleanerId,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseurl/cleaner/login');

      if (kDebugMode) {
        print('🔐 Staff Login API Call');
        print('📍 URL: $url');
        print('📤 Request: {cleanerId: $cleanerId, password: ***}');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cleanerId': cleanerId, 'password': password}),
      );

      if (kDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData['data'],
          'accessToken': responseData['accessToken'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error staff login: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error staff login: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error staff login: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Staff Login Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get cleaner profile
  static Future<Map<String, dynamic>> getCleanerProfile({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$baseurl/cleaners/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get profile',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get Profile Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api.dart';
import '../../../../core/services/secure_storage_service.dart';

class ChatRepository {
  /// Initiate chat about an issue
  /// POST /cleaner/chats/initiate
  static Future<Map<String, dynamic>> initiateChat({
    required String bookingId,
    required String description,
    required String issue,
  }) async {
    try {
      final url = Uri.parse('$baseurl/cleaner/chats/initiate');
      final token = await SecureStorageService.getStaffAccessToken();

      final requestBody = {
        'bookingId': bookingId,
        'description': description,
        'issue': issue,
      };

      if (kDebugMode) {
        print('💬 Initiate Chat API Call');
        print('📍 URL: $url');
        print('📤 Request Body: $requestBody');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
        print(
          '📥 Response Bodyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy: ${response.body}',
        );
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Chat initiated successfully',
          'data': responseData['data'] ?? responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to initiate chat: ${response.statusCode}',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error initiating chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error initiating chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error initiating chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Initiate Chat Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get existing chat for a booking
  /// GET /cleaner/chats/:bookingId or similar endpoint
  /// Note: Adjust endpoint based on your backend API
  static Future<Map<String, dynamic>> getChatByBookingId({
    required String bookingId,
  }) async {
    try {
      // Try to get existing chat - adjust endpoint as needed
      // If your backend has a different endpoint, update this
      final url = Uri.parse('$baseurl/cleaner/chats/booking/$bookingId');
      final token = await SecureStorageService.getStaffAccessToken();

      if (kDebugMode) {
        print('💬 Get Chat by Booking ID API Call');
        print('📍 URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Chat retrieved successfully',
          'data': responseData['data'] ?? responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to get chat: ${response.statusCode}',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error getting chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error getting chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error getting chat: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get Chat Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get messages for a chat
  /// GET /cleaner/chats/:chatId/messages
  static Future<Map<String, dynamic>> getChatMessages({
    required String chatId,
  }) async {
    try {
      final url = Uri.parse('$baseurl/cleaner/chats/$chatId/messages');
      final token = await SecureStorageService.getStaffAccessToken();

      if (kDebugMode) {
        print('💬 Get Chat Messages API Call');
        print('📍 URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Messages fetched successfully',
          'messages': responseData['messages'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to get messages: ${response.statusCode}',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error getting chat messages: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error getting chat messages: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error getting chat messages: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get Chat Messages Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

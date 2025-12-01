import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api.dart';

class CleanerBookingRepository {
  static Uri _buildUri(String path, Map<String, dynamic> query) {
    final filteredQuery = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      filteredQuery[key] = value;
    });
    return Uri.parse('$baseurl$path').replace(queryParameters: filteredQuery);
  }

  static Future<Map<String, dynamic>> fetchAssignedBookings({
    required String accessToken,
    int page = 1,
    int limit = 30,
    String? search,
  }) async {
    final uri = _buildUri('/cleaner/bookings', {
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _get(uri, accessToken);
  }

  static Future<Map<String, dynamic>> fetchCompletedBookings({
    required String accessToken,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final uri = _buildUri('/cleaner/bookings/completed', {
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _get(uri, accessToken);
  }

  static Future<Map<String, dynamic>> fetchBookingById({
    required String accessToken,
    required String bookingId,
  }) async {
    final uri = Uri.parse('$baseurl/cleaner/bookings/$bookingId');
    if (kDebugMode) {
      print('📋 Fetching booking details:');
      print('   URL: ${uri.toString()}');
      print('   Booking ID: $bookingId');
    }
    print("accessToken: $accessToken");
    return _get(uri, accessToken);
  }

  static Future<Map<String, dynamic>> updateSession({
    required String accessToken,
    required String bookingId,
    required String sessionId,
    required String sessionType,
    String? addonId,
  }) async {
    print(sessionId);
    final uri = Uri.parse(
      '$baseurl/cleaner/bookings/$bookingId/sessions/$sessionId',
    );
    final body = <String, dynamic>{'sessionType': sessionType};
    if (addonId != null) {
      body['addonId'] = addonId;
    }
    return _patch(uri, accessToken, body: body);
  }

  static Future<Map<String, dynamic>> _get(Uri uri, String accessToken) async {
    try {
      if (kDebugMode) {
        print('🛰️ GET $uri');
      }
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (kDebugMode) {
        print('⬇️ ${response.statusCode} ${response.body}');
      }

      // Handle different status codes
      if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Booking not found',
          'data': null,
          'pagination': null,
        };
      }

      if (response.statusCode != 200) {
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': body['message'] ?? 'Failed to load booking',
            'data': null,
            'pagination': null,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to load booking (${response.statusCode})',
            'data': null,
            'pagination': null,
          };
        }
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success =
          response.statusCode == 200 &&
          (body['success'] == true || body['data'] != null);

      return {
        'success': success,
        'message': body['message'] ?? 'Something went wrong',
        'data': body['data'],
        'pagination': body['pagination'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ CleanerBookingRepository error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> _patch(
    Uri uri,
    String accessToken, {
    Map<String, dynamic>? body,
  }) async {
    try {
      if (kDebugMode) {
        print('🛰️ PATCH $uri');
        if (body != null) {
          print('📦 Body: $body');
        }
      }
      final requestBody = body != null ? jsonEncode(body) : null;
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBody,
      );

      if (kDebugMode) {
        print('⬇️ ${response.statusCode} ${response.body}');
      }

      // Handle different status codes
      if (response.statusCode == 404) {
        return {'success': false, 'message': 'Session not found', 'data': null};
      }

      if (response.statusCode != 200) {
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Failed to update session',
            'data': null,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to update session (${response.statusCode})',
            'data': null,
          };
        }
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final success =
          response.statusCode == 200 &&
          (responseBody['success'] == true || responseBody['data'] != null);

      return {
        'success': success,
        'message': responseBody['message'] ?? 'Something went wrong',
        'data': responseBody['data'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ CleanerBookingRepository error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

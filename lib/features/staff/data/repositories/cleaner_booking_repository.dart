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
    int limit = 10,
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
    final uri = Uri.parse('$baseurl/cleaner/$bookingId');
    return _get(uri, accessToken);
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
}

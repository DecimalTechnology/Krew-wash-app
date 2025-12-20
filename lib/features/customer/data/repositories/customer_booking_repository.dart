import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api.dart';
import '../../../../core/services/secure_storage_service.dart';

class CustomerBookingRepository {
  const CustomerBookingRepository();

  Future<Map<String, dynamic>> getMyBookings({String? search}) async {
    final token = await SecureStorageService.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // Backend may expose different paths. We try a few common ones.
    final candidates = <Uri>[
      Uri.parse('$baseurl/bookings').replace(
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ),
      Uri.parse('$baseurl/bookings/my').replace(
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ),
      Uri.parse('$baseurl/user/bookings').replace(
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ),
      Uri.parse('$baseurl/users/bookings').replace(
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ),
    ];

    try {
      http.Response? lastResponse;
      for (final uri in candidates) {
        try {
          final res = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
          lastResponse = res;

          // If endpoint exists, stop trying alternates (even if it's a 4xx with body message).
          if (res.statusCode != 404) break;
        } on TimeoutException {
          rethrow;
        } on SocketException {
          rethrow;
        } on http.ClientException {
          rethrow;
        } catch (_) {
          // try next candidate
        }
      }

      final res = lastResponse;
      if (res == null) {
        return {'success': false, 'message': 'Failed to load bookings'};
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final list =
            (decoded['data'] as List?) ??
            (decoded['bookings'] as List?) ??
            (decoded['results'] as List?) ??
            const [];
        return {'success': true, 'data': list};
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to load bookings',
      };
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ CustomerBookingRepository.getMyBookings SocketException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ CustomerBookingRepository.getMyBookings TimeoutException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ CustomerBookingRepository.getMyBookings ClientException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ CustomerBookingRepository.getMyBookings Error: $e');
      }
      return {'success': false, 'message': 'Failed to load bookings'};
    }
  }

  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    final token = await SecureStorageService.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final candidates = <Uri>[
      Uri.parse('$baseurl/bookings/$bookingId'),
      Uri.parse('$baseurl/bookings/details/$bookingId'),
      Uri.parse('$baseurl/user/bookings/$bookingId'),
    ];

    try {
      http.Response? lastResponse;
      for (final uri in candidates) {
        try {
          final res = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
          lastResponse = res;
          if (res.statusCode != 404) break;
        } catch (_) {
          // try next
        }
      }

      final res = lastResponse;
      if (res == null) {
        return {'success': false, 'message': 'Failed to load booking'};
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = (decoded['data'] as Map?) ?? decoded;
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to load booking',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (_) {
      return {'success': false, 'message': 'Failed to load booking'};
    }
  }
}



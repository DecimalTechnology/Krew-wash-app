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
        print('📤 Request: {cleanerId: $cleanerId, password: $password}');
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

  /// Get cleaner dashboard data (booking, completedBooking, upcomingBooking)
  static Future<Map<String, dynamic>> getDashboardData({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$baseurl/cleaner/dashboard');

      if (kDebugMode) {
        print('📊 Dashboard API Call');
        print('📍 URL: $url');
      }

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      if (kDebugMode) {
        print('📥 Dashboard Response Status: ${response.statusCode}');
        print('📥 Dashboard Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (kDebugMode) {
        print('\n📊 ========== DASHBOARD API RESPONSE ==========');
        print('✅ Success: ${responseData['success']}');
        print('📝 Message: ${responseData['message'] ?? 'N/A'}');

        // Print Booking Info
        final booking = responseData['booking'] as Map<String, dynamic>?;
        if (booking != null) {
          print('\n📋 CURRENT BOOKING:');
          print('   Booking ID: ${booking['bookingId'] ?? 'N/A'}');
          print('   Status: ${booking['status'] ?? 'N/A'}');
          print('   Vehicle Model: ${booking['vehicleModel'] ?? 'N/A'}');
          print(
            '   Vehicle Number: ${booking['vehilceNumber'] ?? booking['vehicleNumber'] ?? 'N/A'}',
          );
          print('   Created At: ${booking['createdAt'] ?? 'N/A'}');
          print('   Updated At: ${booking['updatedAt'] ?? 'N/A'}');

          final services = booking['services'] as List? ?? [];
          if (services.isNotEmpty) {
            print('   Services:');
            for (var i = 0; i < services.length; i++) {
              print('      [$i] ${services[i]}');
            }
          }
        } else {
          print('\n📋 CURRENT BOOKING: None');
        }

        // Print Booking Counts
        print('\n📊 BOOKING STATISTICS:');
        print(
          '   ✅ Completed Bookings: ${responseData['completedBooking'] ?? 0}',
        );
        print(
          '   📅 Upcoming Bookings: ${responseData['upcomingBooking'] ?? 0}',
        );

        print('📊 ===========================================\n');
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? '',
          'booking': responseData['booking'],
          'completedBooking': responseData['completedBooking'] ?? 0,
          'upcomingBooking': responseData['upcomingBooking'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get dashboard data',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Network error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get Dashboard Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

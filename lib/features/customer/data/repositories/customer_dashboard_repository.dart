import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api.dart';
import '../../../../core/services/secure_storage_service.dart';

class CustomerDashboardRepository {
  const CustomerDashboardRepository();

  void _logToken(String source, String? token) {
    if (kDebugMode) {
      debugPrint('🔐 [$source] accessToken: ${token ?? 'null'}');
    }
  }

  /// Get customer dashboard data (services, packages, buildings)
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('CustomerDashboardRepository.getDashboardData', token);
      final uri = Uri.parse('$baseurl/dashboard');

      if (kDebugMode) {
        debugPrint('📊 Customer Dashboard API Call');
        debugPrint('📍 URL: $uri');
      }

      final res = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
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
        debugPrint('📥 Dashboard Response Status: ${res.statusCode}');
        debugPrint('📥 Dashboard Response Body: ${res.body}');
      }

      final responseData = jsonDecode(res.body) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint(
          '\n📊 ========== CUSTOMER DASHBOARD API RESPONSE ==========',
        );
        debugPrint('✅ Success: ${responseData['success']}');
        debugPrint('📝 Message: ${responseData['message'] ?? 'N/A'}');

        // Print Services
        final services = responseData['services'] as List? ?? [];
        debugPrint('\n📦 SERVICES (${services.length}):');
        for (var i = 0; i < services.length; i++) {
          final service = services[i] as Map<String, dynamic>;
          debugPrint(
            '   [$i] ${service['name'] ?? 'N/A'}: ${service['description'] ?? 'N/A'}',
          );
        }

        // Print Packages
        final packages = responseData['packages'] as List? ?? [];
        debugPrint('\n📋 PACKAGES (${packages.length}):');
        for (var i = 0; i < packages.length; i++) {
          final package = packages[i] as Map<String, dynamic>;
          debugPrint('   [$i] ${package['name'] ?? 'N/A'}');
          debugPrint('       ID: ${package['_id'] ?? 'N/A'}');
          debugPrint('       Frequency: ${package['frequency'] ?? 'N/A'}');
          debugPrint('       Description: ${package['description'] ?? 'N/A'}');
          debugPrint(
            '       Is AddOn: ${package['isAddOn'] ?? package['isAddon'] ?? false}',
          );
          final basePrices = package['basePrices'] as List? ?? [];
          if (basePrices.isNotEmpty) {
            debugPrint('       Base Prices:');
            for (var price in basePrices) {
              final priceMap = price as Map<String, dynamic>;
              debugPrint(
                '         - Vehicle: ${priceMap['vehicleType']}, Price: ${priceMap['price']}',
              );
            }
          }
        }

        // Print Buildings
        final buildings = responseData['buildings'] as List? ?? [];
        debugPrint('\n🏢 BUILDINGS (${buildings.length}):');
        for (var i = 0; i < buildings.length; i++) {
          final building = buildings[i] as Map<String, dynamic>;
          debugPrint('   [$i] ${building['buildingName'] ?? 'N/A'}');
        }

        debugPrint('📊 ===========================================\n');
      }

      if (res.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? '',
          'services': responseData['services'] ?? [],
          'packages': responseData['packages'] ?? [],
          'buildings': responseData['buildings'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get dashboard data',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error getting dashboard: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Dashboard Error: $e');
      }
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

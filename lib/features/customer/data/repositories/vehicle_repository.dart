import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api.dart';
import '../../../../core/services/secure_storage_service.dart';

class VehicleRepository {
  const VehicleRepository();

  void _logToken(String source, String? token) {
    if (kDebugMode) {
      debugPrint('🔐 [$source] accessToken: ${token ?? 'null'}');
    }
  }

  Future<List<Map<String, String>>> getVehicleTypes() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.getVehicleTypes', token);
      final uri = Uri.parse('$baseurl/vehicle-types');
      final res = await http
          .get(
            uri,
            headers: {
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

      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List?) ?? [];
      return data
          .map<Map<String, String>>(
            (item) => {
              'id': item['_id']?.toString() ?? '',
              'name': item['name']?.toString() ?? '',
            },
          )
          .where((map) => map['id']!.isNotEmpty && map['name']!.isNotEmpty)
          .toList();
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicleTypes] SocketException: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VehicleRepository.getVehicleTypes] TimeoutException: $e',
        );
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicleTypes] ClientException: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicleTypes] Error: $e');
      }
      return [];
    }
  }

  Future<List<String>> getVehicleModelsByType(String vehicleTypeId) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.getVehicleModelsByType', token);
      final uri = Uri.parse('$baseurl/vehicles/list/$vehicleTypeId');
      final res = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List?) ?? [];
      return data.map((item) => item.toString()).toList();
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error getting vehicle models: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error getting vehicle models: $e');
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error getting vehicle models: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting vehicle models: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.getVehicles', token);
      final uri = Uri.parse('$baseurl/vehicles');
      final res = await http
          .get(
            uri,
            headers: {
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

      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List?) ?? [];
      return data
          .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
          .toList();
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicles] SocketException: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicles] TimeoutException: $e');
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicles] ClientException: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [VehicleRepository.getVehicles] Error: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> createVehicle({
    required String vehicleNumber,
    required String color,
    required String vehicleTypeId,
    required String vehicleModel,
    required String parkingNumber,
    required String parkingArea,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.createVehicle', token);
      final uri = Uri.parse('$baseurl/vehicles');
      final body = jsonEncode({
        'vehicleNumber': vehicleNumber,
        'color': color,
        'type': vehicleTypeId,
        'vehicleModel': vehicleModel,
        'parkingNumber': parkingNumber,
        'parkingArea': parkingArea,
      });

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error creating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error creating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error creating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Failed to create vehicle: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateVehicle({
    required String vehicleId,
    required String vehicleNumber,
    required String color,
    required String vehicleTypeId,
    required String vehicleModel,
    required String parkingNumber,
    required String parkingArea,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.updateVehicle', token);
      final uri = Uri.parse('$baseurl/vehicles/$vehicleId');
      final body = jsonEncode({
        'vehicleNumber': vehicleNumber,
        'color': color,
        'type': vehicleTypeId,
        'vehicleModel': vehicleModel,
        'parkingNumber': parkingNumber,
        'parkingArea': parkingArea,
      });

      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error updating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error updating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error updating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Failed to update vehicle: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('VehicleRepository.deleteVehicle', token);
      final uri = Uri.parse('$baseurl/vehicles/$vehicleId');
      final res = await http.delete(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error deleting vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error deleting vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error deleting vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting vehicle: $e');
      }
      return {
        'success': false,
        'message': 'Failed to delete vehicle: ${e.toString()}',
      };
    }
  }
}

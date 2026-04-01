import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api.dart';
import '../../domain/models/building_model.dart';
import '../../../../core/services/secure_storage_service.dart';

class PackageRepository {
  const PackageRepository();

  void _logToken(String source, String? token) {
    if (kDebugMode) {
      debugPrint('🔐 [$source] accessToken: ${token ?? 'null'}');
    }
  }

  Future<List<BuildingModel>> searchBuildings(String query) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('PackageRepository.searchBuildings', token);
      final uri = Uri.parse(
        '$baseurl/buildings/search',
      ).replace(queryParameters: {'search': query});
      if (kDebugMode) {
        debugPrint('📞 [searchBuildings] GET ${uri.toString()}');
        debugPrint('📞 [searchBuildings] query: "$query"');
      }
      final res = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (kDebugMode) {
        debugPrint('📞 [searchBuildings] response status: ${res.statusCode}');
      }
      if (res.statusCode != 200) return [];
      final decoded = jsonDecode(res.body);
      List<dynamic> list = [];
      if (decoded is Map<String, dynamic>) {
        list = (decoded['data'] as List?) ?? (decoded['buildings'] as List?) ?? [];
      } else if (decoded is List) {
        list = decoded;
      }
      final result = <BuildingModel>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            result.add(BuildingModel.fromMap(e));
          } catch (_) {
            // skip malformed items
          }
        }
      }
      if (kDebugMode) {
        debugPrint('📞 [searchBuildings] results count: ${result.length}');
      }
      return result;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error searching buildings: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error searching buildings: $e');
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error searching buildings: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error searching buildings: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, String>>> getVehicleTypes() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('PackageRepository.getVehicleTypes', token);
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
      if (kDebugMode) {
        debugPrint('📦 [PackageRepository.getVehicleTypes] res: ${res.body}');
      }

      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (body['data'] as List?) ?? [];
      return list
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
        debugPrint('❌ [PackageRepository.getVehicleTypes] SocketException: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [PackageRepository.getVehicleTypes] TimeoutException: $e',
        );
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PackageRepository.getVehicleTypes] ClientException: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PackageRepository.getVehicleTypes] Error: $e');
      }
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getPackages({
    required String buildingId,
    required String vehicleId,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('PackageRepository.getPackages', token);
      final uri = Uri.parse('$baseurl/packages').replace(
        queryParameters: {'buildingId': buildingId, 'vehicleId': vehicleId},
      );
      final res = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode != 200) {
        return {'packages': [], 'addOns': []};
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as Map?) ?? {};

      List<Map<String, dynamic>> parseItems(List? items) {
        return (items ?? [])
            .map<Map<String, dynamic>>(
              (item) => {
                'id': item['_id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Package',
                'description': item['description']?.toString() ?? '',
                'frequency': item['frequency']?.toString() ?? '',
                'price': '${item['price'] ?? 0} AED',
                'rawPrice': item['price'] ?? 0,
                'isAddon': item['isAddon'] == true,
              },
            )
            .toList();
      }

      final packages = parseItems(
        data['packages'] as List?,
      ).where((item) => item['isAddon'] != true).toList();
      final addOns = parseItems(
        data['addOns'] as List?,
      ).where((item) => item['isAddon'] == true).toList();

      return {'packages': packages, 'addOns': addOns};
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error getting packages: $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error getting packages: $e');
      }
      rethrow;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error getting packages: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting packages: $e');
      }
      return {'packages': [], 'addOns': []};
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    final token = await SecureStorageService.getAccessToken();
    _logToken('PackageRepository.searchBuildings', token);
    final uri = Uri.parse(
      '$baseurl/buildings/search',
    ).replace(queryParameters: {'search': query});
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List?) ?? [];
    return list
        .map((e) => BuildingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, String>>> getVehicleTypes() async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('PackageRepository.getVehicleTypes', token);
    final uri = Uri.parse('$baseurl/vehicle-types');
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
  }

  Future<Map<String, List<Map<String, dynamic>>>> getPackages({
    required String buildingId,
    required String vehicleId,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('PackageRepository.getPackages', token);
    final uri = Uri.parse('$baseurl/packages').replace(
      queryParameters: {'buildingId': buildingId, 'vehicleId': vehicleId},
    );
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
  }
}

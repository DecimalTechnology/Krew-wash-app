import 'dart:convert';
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
    final token = await SecureStorageService.getAccessToken();
    _logToken('VehicleRepository.getVehicleTypes', token);
    final uri = Uri.parse('$baseurl/vehicle-types');
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
  }

  Future<List<String>> getVehicleModelsByType(String vehicleTypeId) async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('VehicleRepository.getVehicleModelsByType', token);
    final uri = Uri.parse('$baseurl/vehicles/list/$vehicleTypeId');
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (body['data'] as List?) ?? [];
    return data.map((item) => item.toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('VehicleRepository.getVehicles', token);
    final uri = Uri.parse('$baseurl/vehicles');
    final res = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (body['data'] as List?) ?? [];
    return data
        .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> createVehicle({
    required String vehicleNumber,
    required String color,
    required String vehicleTypeId,
    required String vehicleModel,
    required String parkingNumber,
    required String parkingArea,
  }) async {
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
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: body,
    );

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded;
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
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: body,
    );

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded;
  }

  Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('VehicleRepository.deleteVehicle', token);
    final uri = Uri.parse('$baseurl/vehicles/$vehicleId');
    final res = await http.delete(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api.dart';
import '../../../../core/services/secure_storage_service.dart';

class ProfileRepository {
  const ProfileRepository();

  void _logToken(String source, String? token) {
    if (kDebugMode) {
      debugPrint('🔐 [$source] accessToken: ${token ?? 'null'}');
    }
  }

  // Update profile - PUT /profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? buildingId,
    String? apartmentNumber,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('ProfileRepository.updateProfile', token);
    final uri = Uri.parse('$baseurl/profile');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (buildingId != null) body['buildingId'] = buildingId;
    if (apartmentNumber != null) body['apartmentNumber'] = apartmentNumber;

    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return {'success': true};
      }
    }

    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': false,
        'message': err['message'] ?? 'Failed to update profile',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${res.statusCode}',
      };
    }
  }

  // Get profile - GET /profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('ProfileRepository.getProfile', token);
    final uri = Uri.parse('$baseurl/profile');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to parse profile response',
        };
      }
    }

    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': false,
        'message': err['message'] ?? 'Failed to get profile',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to get profile: ${res.statusCode}',
      };
    }
  }

  // Update profile picture - PATCH /profile/image (multipart, field: image)
  Future<Map<String, dynamic>> uploadProfileImage({
    required File imageFile,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    _logToken('ProfileRepository.uploadProfileImage', token);
    final uri = Uri.parse('$baseurl/profile/image');

    final req = http.MultipartRequest('PATCH', uri);
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return {'success': true};
      }
    }

    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': false,
        'message': err['message'] ?? 'Failed to upload profile picture',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to upload profile picture: ${res.statusCode}',
      };
    }
  }
}

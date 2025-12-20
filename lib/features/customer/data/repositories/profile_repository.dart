import 'dart:async';
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
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('ProfileRepository.updateProfile', token);
      final uri = Uri.parse('$baseurl/profile');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (buildingId != null) body['buildingId'] = buildingId;
      // Include apartmentNumber if provided
      // Empty string means clear it (send null), null means don't update (don't include)
      if (apartmentNumber != null) {
        // If empty string, send null to backend to clear it; otherwise send the value
        body['apartmentNumber'] = apartmentNumber.isEmpty
            ? null
            : apartmentNumber;
        if (kDebugMode) {
          debugPrint(
            '📦 [ProfileRepository.updateProfile] Including apartmentNumber: ${apartmentNumber.isEmpty ? "null (to clear)" : apartmentNumber}',
          );
        }
      } else if (kDebugMode) {
        debugPrint(
          '📦 [ProfileRepository.updateProfile] apartmentNumber is null, not including in request',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '📦 [ProfileRepository.updateProfile] Request body: ${jsonEncode(body)}',
        );
        debugPrint(
          '📦 [ProfileRepository.updateProfile] apartmentNumber parameter: $apartmentNumber',
        );
      }

      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        try {
          final response = jsonDecode(res.body) as Map<String, dynamic>;
          if (kDebugMode) {
            debugPrint(
              '📦 [ProfileRepository.updateProfile] Response status: ${res.statusCode}',
            );
            debugPrint(
              '📦 [ProfileRepository.updateProfile] Response body: ${res.body}',
            );
            if (response.containsKey('data') && response['data'] is Map) {
              final data = response['data'] as Map;
              debugPrint(
                '📦 [ProfileRepository.updateProfile] Response data keys: ${data.keys.join(", ")}',
              );
              if (data.containsKey('apartmentNumber')) {
                debugPrint(
                  '📦 [ProfileRepository.updateProfile] Response apartmentNumber: ${data['apartmentNumber']}',
                );
              }
            }
          }
          return response;
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
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error updating profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error updating profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error updating profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating profile: $e');
      }
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  // Get profile - GET /profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('ProfileRepository.getProfile', token);
      final uri = Uri.parse('$baseurl/profile');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
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
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting profile: $e');
      }
      return {
        'success': false,
        'message': 'Failed to get profile: ${e.toString()}',
      };
    }
  }

  // Update profile picture - PATCH /profile/image (multipart, field: image)
  Future<Map<String, dynamic>> uploadProfileImage({
    required File imageFile,
  }) async {
    try {
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
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error uploading profile image: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error uploading profile image: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error uploading profile image: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error uploading profile image: $e');
      }
      return {
        'success': false,
        'message': 'Failed to upload profile picture: ${e.toString()}',
      };
    }
  }

  // Delete account/profile - DELETE /profile
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await SecureStorageService.getAccessToken();
      _logToken('ProfileRepository.deleteAccount', token);
      final uri = Uri.parse('$baseurl/profile');

      final res = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
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
          'message': err['message'] ?? 'Failed to delete account',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to delete account: ${res.statusCode}',
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network error deleting account: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeout error deleting account: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Client error deleting account: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting account: $e');
      }
      return {
        'success': false,
        'message': 'Failed to delete account: ${e.toString()}',
      };
    }
  }
}

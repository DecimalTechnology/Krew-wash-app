import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../../core/services/secure_storage_service.dart';

class EditProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo;
  bool _isSaving = false;
  String? _error;

  EditProfileProvider(this._repo);

  bool get isSaving => _isSaving;
  String? get error => _error;

  // Helper method to update user locally when backend doesn't return user data
  Future<void> _updateUserLocally({
    required AuthProvider authProvider,
    String? name,
    String? phone,
    String? email,
    String? buildingId,
    String? apartmentNumber,
  }) async {
    final current = authProvider.user;
    if (current != null) {
      // Only update buildingId if a new one is explicitly provided
      // Preserve existing buildingId if null is passed
      final updatedUser = current.copyWith(
        name: name,
        phone: phone != null ? int.tryParse(phone) : null,
        email: email,
        buildingId: buildingId ?? current.buildingId,
        apartmentNumber: apartmentNumber ?? current.apartmentNumber,
      );
      await SecureStorageService.saveUserData(jsonEncode(updatedUser.toMap()));
      authProvider.setUser(updatedUser);

      if (kDebugMode) {
        print('✅ Profile updated locally and saved to storage');
      }
    }
  }

  Future<bool> saveProfile({
    required AuthProvider authProvider,
    String? name,
    String? phone,
    String? email,
    String? buildingId,
    String? apartmentName,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Store apartmentName before API call to ensure it's preserved
      final apartmentToSave = apartmentName;

      if (kDebugMode) {
        print(
          '📦 [EditProfileProvider.saveProfile] apartmentName received: $apartmentName',
        );
        print(
          '📦 [EditProfileProvider.saveProfile] apartmentToSave: $apartmentToSave',
        );
      }

      final result = await _repo.updateProfile(
        name: name,
        phone: phone,
        email: email,
        buildingId: buildingId,
        apartmentNumber: apartmentToSave,
      );

      if (result['success'] == false) {
        _error = result['message']?.toString();
        // Check if it's a network error
        if (result['isNetworkError'] == true) {
          _error = 'NETWORK_ERROR'; // Special marker for network errors
        }
        _isSaving = false;
        notifyListeners();
        return false;
      }

      // Check if backend returned new tokens and save them
      // This is important as the backend might invalidate old tokens after profile update
      try {
        // Check multiple possible locations for tokens in the response
        final accessToken =
            result['accessToken'] as String? ??
            result['data']?['accessToken'] as String? ??
            (result['data'] is Map
                ? (result['data'] as Map)['accessToken']?.toString()
                : null);
        final refreshToken =
            result['refreshToken'] as String? ??
            result['data']?['refreshToken'] as String? ??
            (result['data'] is Map
                ? (result['data'] as Map)['refreshToken']?.toString()
                : null);

        if (accessToken != null || refreshToken != null) {
          await SecureStorageService.saveTokens(
            UseraccessToken: accessToken,
            UserrefreshToken: refreshToken,
          );
          if (kDebugMode) {
            print('🔐 New tokens saved after profile update');
            print(
              '   Access token: ${accessToken != null ? "updated" : "not provided"}',
            );
            print(
              '   Refresh token: ${refreshToken != null ? "updated" : "not provided"}',
            );
          }
        } else if (kDebugMode) {
          print('ℹ️ No new tokens in profile update response');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error saving tokens from profile update response: $e');
        }
      }

      // If backend returns updated user data, persist it
      final updated = result['data'] ?? result['user'] ?? result;

      if (kDebugMode) {
        print(
          '📦 [EditProfileProvider] Backend response keys: ${result.keys.join(", ")}',
        );
        if (updated is Map) {
          print(
            '📦 [EditProfileProvider] Updated data keys: ${updated.keys.join(", ")}',
          );
          if (updated.containsKey('apartmentNumber')) {
            print(
              '📦 [EditProfileProvider] Backend returned apartmentNumber: ${updated['apartmentNumber']}',
            );
          } else {
            print(
              '📦 [EditProfileProvider] Backend did NOT return apartmentNumber',
            );
          }
        } else {
          print('📦 [EditProfileProvider] Updated data is not a map');
        }
      }

      if (updated != null && updated is Map<String, dynamic>) {
        try {
          final map = Map<String, dynamic>.from(updated);

          // Ensure apartmentNumber is included in saved data
          // If apartmentToSave was sent, use it (even if empty string to clear it)
          // Otherwise preserve existing value from current user
          if (apartmentToSave != null) {
            // User provided a value (could be empty string to clear)
            // If empty string, set to null to clear it; otherwise use the value
            map['apartmentNumber'] = apartmentToSave.isEmpty
                ? null
                : apartmentToSave;
            if (kDebugMode) {
              print(
                '📦 [EditProfileProvider] Setting apartmentNumber from apartmentToSave: ${apartmentToSave.isEmpty ? "null (cleared)" : apartmentToSave}',
              );
            }
          } else {
            // apartmentToSave is null - user didn't change it, preserve existing
            final currentUser = authProvider.user;
            if (currentUser?.apartmentNumber != null) {
              map['apartmentNumber'] = currentUser!.apartmentNumber;
              if (kDebugMode) {
                print(
                  '📦 [EditProfileProvider] Preserving existing apartmentNumber: ${currentUser.apartmentNumber}',
                );
              }
            } else if (kDebugMode) {
              print('📦 [EditProfileProvider] No apartmentNumber to preserve');
            }
          }

          // Save to local storage
          await SecureStorageService.saveUserData(jsonEncode(map));

          // Update AuthProvider with new user data
          authProvider.setUser(UserModel.fromMap(map));

          if (kDebugMode) {
            print('✅ Profile updated and saved to local storage');
            print('📦 Saved user data: ${map.keys.join(", ")}');
            print(
              '📦 Apartment Number: ${map['apartmentNumber'] ?? "not included"}',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing user data from response: $e');
          }
          // Fallback: update locally from inputs
          await _updateUserLocally(
            authProvider: authProvider,
            name: name,
            phone: phone,
            email: email,
            buildingId: buildingId,
            apartmentNumber: apartmentToSave,
          );
        }
      } else {
        // Backend didn't return user data, update locally from inputs
        await _updateUserLocally(
          authProvider: authProvider,
          name: name,
          phone: phone,
          email: email,
          buildingId: buildingId,
          apartmentNumber: apartmentToSave,
        );
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfileImage({
    required AuthProvider authProvider,
    required String filePath,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final file = File(filePath);
      final result = await _repo.uploadProfileImage(imageFile: file);
      if (result['success'] == false) {
        _error = result['message']?.toString();
        // Check if it's a network error
        if (result['isNetworkError'] == true) {
          _error = 'NETWORK_ERROR'; // Special marker for network errors
        }
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final updated = result['data'] ?? result['user'] ?? result;
      if (updated != null && updated is Map<String, dynamic>) {
        try {
          final map = updated;
          // Ensure 'image' field is preserved if present
          if (map['image'] != null && map['photo'] == null) {
            map['photo'] = map['image'];
          }
          await SecureStorageService.saveUserData(jsonEncode(map));
          authProvider.setUser(UserModel.fromMap(map));

          if (kDebugMode) {
            print('✅ Profile image updated and saved to local storage');
            print(
              '📸 Image URL: ${map['image'] ?? map['photo'] ?? 'NOT FOUND'}',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing user data from image upload response: $e');
          }
        }
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}

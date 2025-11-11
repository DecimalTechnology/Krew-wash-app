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
  }) async {
    final current = authProvider.user;
    if (current != null) {
      final updatedUser = current.copyWith(
        name: name,
        phone: phone != null ? int.tryParse(phone) : null,
        email: email,
        buildingId: buildingId,
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
      final result = await _repo.updateProfile(
        name: name,
        phone: phone,
        email: email,
        buildingId: buildingId,
        apartmentNumber: apartmentName,
      );

      if (result['success'] == false) {
        _error = result['message']?.toString();
        _isSaving = false;
        notifyListeners();
        return false;
      }

      // If backend returns updated user data, persist it
      final updated = result['data'] ?? result['user'] ?? result;

      if (updated != null && updated is Map<String, dynamic>) {
        try {
          final map = updated;

          // Save to local storage
          await SecureStorageService.saveUserData(jsonEncode(map));

          // Update AuthProvider with new user data
          authProvider.setUser(UserModel.fromMap(map));

          if (kDebugMode) {
            print('✅ Profile updated and saved to local storage');
            print('📦 Saved user data: ${map.keys.join(", ")}');
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
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final updated = result['data'] ?? result['user'] ?? result;
      if (updated != null && updated is Map<String, dynamic>) {
        try {
          final map = updated;
          await SecureStorageService.saveUserData(jsonEncode(map));
          authProvider.setUser(UserModel.fromMap(map));

          if (kDebugMode) {
            print('✅ Profile image updated and saved to local storage');
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

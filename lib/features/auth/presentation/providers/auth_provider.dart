import 'package:carwash_app/core/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';
import 'dart:convert';
import '../../domain/models/auth_result.dart';
import '../../domain/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // First, try to restore user from secure storage (stay logged in)
    await _restoreUserFromStorage();

    // Also listen to auth state changes (Firebase)
    _authService.authStateChanges.listen((UserModel? user) {
      // Only update if we don't have a user from storage
      if (_user == null && user != null) {
        _user = user;
        notifyListeners();
      }
    });
  }

  Future<void> _restoreUserFromStorage() async {
    try {
      // Check if we have tokens and user data
      final hasTokens = await SecureStorageService.isLoggedIn();
      final userDataJson = await SecureStorageService.getUserData();

      if (hasTokens && userDataJson != null && userDataJson.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          _user = UserModel.fromMap(userData);
          if (kDebugMode) {
            print('✅ User restored from secure storage: ${_user?.email}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing user data from storage: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring user from storage: $e');
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Google Authentication
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithGoogle();

      if (result['success']) {
        // Create UserModel from the result
        final userData = result['user'];
        _user = UserModel.fromFirebaseUser(
          uid: userData['uid'],
          email: userData['email'],
          displayName: userData['displayName'],
          phoneNumber: userData['phoneNumber'],
          photoURL: userData['photoURL'],
        );

        // Persist tokens (if present) and user info securely
        final tokens = result['tokens'];
        if (tokens is Map<String, dynamic>) {
          await SecureStorageService.saveTokens(
            UseraccessToken: tokens['accessToken'] as String?,
            UserrefreshToken: null,
            idToken: tokens['idToken'] as String?,
          );
        }
        await SecureStorageService.saveUserData(jsonEncode(_user!.toMap()));
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(result['message'] ?? 'Google sign in failed');
        _setLoading(false);
      }

      return result;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Phone Authentication
  Future<PhoneAuthResult> sendPhoneVerificationCode({
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.sendPhoneVerificationCode(
        phoneNumber: phoneNumber,
      );

      if (!result.isSuccess) {
        _setError(result.errorMessage ?? 'Failed to send verification code');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return PhoneAuthResult.failure(
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<AuthResult> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (result.isSuccess) {
        _user = result.user;
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(result.errorMessage ?? 'Phone verification failed');
        _setLoading(false);
      }

      return result;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred',
        method: AuthMethod.phone,
      );
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();

      // Clear all tokens and user data from secure storage
      await SecureStorageService.clearAll();

      _user = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Setter to update user object from external providers
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Check if user is logged in using secure storage
  Future<bool> isLoggedInWithTokens() async {
    return await SecureStorageService.isLoggedIn();
  }

  // Get stored tokens
  Future<Map<String, String?>> getStoredTokens() async {
    return await SecureStorageService.getTokens();
  }

  // Get stored user data
  Future<String?> getStoredUserData() async {
    return await SecureStorageService.getUserData();
  }

  // Repository Methods
  Future<Map<String, dynamic>> checkPhoneExists(
    String phno,
    String email,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final exists = await _authRepository.checkPhoneandEmailExists(
        phno,
        email,
      );

      _setLoading(false);
      return exists;
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'message': 'Failed to check email existence'};
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final userData = await _authRepository.getUserByEmail(email);
      _setLoading(false);
      return userData;
    } catch (e) {
      _setError('Failed to get user by email');
      _setLoading(false);
      return null;
    }
  }

  Future<bool> checkUserExists(String email, String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final exists = await AuthRepository.checkUserExists(email, phoneNumber);
      _setLoading(false);
      return exists;
    } catch (e) {
      _setError('Failed to check user existence');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> registerUserAfterVerification({
    required String email,
    required String name,
    required String phoneNumber,
    required String verificationMethod,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.registerUser(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        photoURL: photoURL,
        verificationMethod: verificationMethod,
      );
      if (result['success'] == true) {
        try {
          final accessToken = result['accessToken'] as String?;
          final refreshToken = result['refreshToken'] as String?;
          if (accessToken != null || refreshToken != null) {
            await SecureStorageService.saveTokens(
              UseraccessToken: accessToken,
              UserrefreshToken: refreshToken,
            );
          }
          final userData = result['data'];
          if (userData != null) {
            await SecureStorageService.saveUserData(jsonEncode(userData));
            _user = UserModel.fromMap(userData as Map<String, dynamic>);
            notifyListeners();
          }
        } catch (_) {}
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to register user');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to register user'};
    }
  }

  Future<Map<String, dynamic>> loginUserWithEmail({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.loginUserWithEmail(email: email);
      // If backend returns tokens and/or user data, persist them securely
      if (result['success'] == true) {
        try {
          final accessToken = result['accessToken'] as String?;
          final refreshToken = result['refreshToken'] as String?;
          if (accessToken != null || refreshToken != null) {
            await SecureStorageService.saveTokens(
              UseraccessToken: accessToken,
              UserrefreshToken: refreshToken,
            );
          }
          final userData = result['data'] ?? result['user'];
          if (userData != null) {
            await SecureStorageService.saveUserData(jsonEncode(userData));
            _user = UserModel.fromMap(userData as Map<String, dynamic>);
            notifyListeners();
          }
        } catch (_) {}
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to login with email');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to login with email'};
    }
  }

  Future<Map<String, dynamic>> loginUserAfterPhoneVerification({
    required String uid,
    required String email,
    required String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.loginUserAfterPhoneVerification(
        uid: uid,
        email: email,
        phoneNumber: phoneNumber,
      );
      if (result['success'] == true) {
        try {
          final accessToken = result['accessToken'] as String?;
          final refreshToken = result['refreshToken'] as String?;
          if (accessToken != null || refreshToken != null) {
            await SecureStorageService.saveTokens(
              UseraccessToken: accessToken,
              UserrefreshToken: refreshToken,
            );
          }
          final userData = result['data'] ?? result['user'];
          if (userData != null) {
            await SecureStorageService.saveUserData(jsonEncode(userData));
            _user = UserModel.fromMap(userData as Map<String, dynamic>);
            notifyListeners();
          }
        } catch (_) {}
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to login user');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to login user'};
    }
  }

  Future<Map<String, dynamic>> registerUserInFirestore({
    required String email,
    required String name,
    required String phoneNumber,
    required String verificationMethod,
    String? uid,
    String? photoURL,
    String role = 'customer',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.registerUser(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        verificationMethod: verificationMethod,
        photoURL: photoURL,
      );
      if (result['success'] == true) {
        try {
          final accessToken = result['accessToken'] as String?;
          final refreshToken = result['refreshToken'] as String?;
          if (accessToken != null || refreshToken != null) {
            await SecureStorageService.saveTokens(
              UseraccessToken: accessToken,
              UserrefreshToken: refreshToken,
            );
          }
          if (result['data'] != null) {
            await SecureStorageService.saveUserData(jsonEncode(result['data']));
          }
        } catch (_) {}
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to register user');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to register user'};
    }
  }

  // Update user building ID
  Future<void> updateBuildingId(String buildingId) async {
    if (_user == null) return;

    try {
      // Update user model with building ID
      _user = _user!.copyWith(buildingId: buildingId);

      // Save updated user data to secure storage
      await SecureStorageService.saveUserData(jsonEncode(_user!.toMap()));

      notifyListeners();

      if (kDebugMode) {
        print('🏢 Building ID updated and saved: $buildingId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating building ID: $e');
      }
    }
  }

  // Validation Methods
  bool isValidEmail(String email) {
    return AuthRepository.isValidEmail(email);
  }

  bool isValidPhoneNumber(String phone) {
    return AuthRepository.isValidPhoneNumber(phone);
  }

  String formatPhoneNumber(String phone) {
    return AuthRepository.formatPhoneNumber(phone);
  }

  // Email OTP Methods
  Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.sendEmailOtp(email: email);
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to send email OTP');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to send email OTP: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthRepository.verifyEmailOtp(
        email: email,
        otp: otp,
      );
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to verify email OTP');
      _setLoading(false);
      return {'success': false, 'message': 'Failed to verify email OTP: $e'};
    }
  }
}

import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';

import 'package:carwash_app/core/constants/api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/user_model.dart';

class AuthRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user via API
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String phoneNumber,
    required String verificationMethod,
    String? photoURL,
  }) async {
    try {
      const String url = '$baseurl/auth/register';

      // Format phone number for API (remove + sign)
      final phoneForApi = formatPhoneNumberForApi(phoneNumber);

      final Map<String, dynamic> requestBody = {
        'email': email,
        'name': name,
        'phone': phoneForApi,
        'verificationMethod': verificationMethod,
      };

      if (photoURL != null) requestBody['photoURL'] = photoURL;

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Failed to register user: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to register user: $e'};
    }
  }

  // Update user data

  // Get user data
  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user exists

  // Check if email exists

  // Get user data by email
  Future<Map<String, dynamic>?> getUserByEmail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Network error: Please check your internet connection');
    } on TimeoutException {
      throw Exception('Network error: Request timeout. Please try again');
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('GET request error: $e');
    }
  }

  // Check if phone number exists
  Future<Map<String, dynamic>> checkPhoneandEmailExists(
    String phone,
    String email,
  ) async {
    try {
      const String url = '$baseurl/auth/check-phone';

      // Format phone number for API (remove + sign)
      final phoneForApi = formatPhoneNumberForApi(phone);

      final Map<String, dynamic> requestBody = {
        'phone': phoneForApi,
        'email': email,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Include status code in response for handling 409 (phone already exists)
      // 409 means phone exists - this is expected for sign-in, error for sign-up
      return {...data, 'statusCode': response.statusCode};
    } on SocketException {
      throw Exception('Network error: Please check your internet connection');
    } on TimeoutException {
      throw Exception('Network error: Request timeout. Please try again');
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('Check user request error: $e');
    }
  }
  //

  // Check if user exists by email and phone
  static Future<bool> checkUserExists(String email, String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Login user with email
  static Future<Map<String, dynamic>> loginUserWithEmail({
    required String email,
  }) async {
    try {
      const String url = '$baseurl/auth/login-email';

      final Map<String, dynamic> requestBody = {'email': email};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': 'User logged in successfully with email',
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
          'data': data['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'Email login failed: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to login with email: $e'};
    }
  }

  // Login user after phone verification
  static Future<Map<String, dynamic>> loginUserAfterPhoneVerification({
    String? uid,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      const String url = '$baseurl/auth/login-phone';

      // Format phone number for API (remove + sign)
      final phoneForApi = phoneNumber != null && phoneNumber.isNotEmpty
          ? formatPhoneNumberForApi(phoneNumber)
          : "";

      final Map<String, dynamic> requestBody = {'phone': phoneForApi};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': 'User logged in successfully',
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
          'data': data['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'Login failed: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to login user: $e'};
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number format (E.164: 8–15 digits total)
  static bool isValidPhoneNumber(String phone) {
    if (phone.trim().isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 8 || cleaned.length > 15) return false;
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Validates the national part of a phone number (digits only) against
  /// country-specific min/max length. Use when a country is selected.
  static bool isValidPhoneNumberForCountry(
    String nationalPart,
    int minLength,
    int maxLength,
  ) {
    final cleaned = nationalPart.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < minLength || cleaned.length > maxLength) return false;
    return RegExp(r'^\d+$').hasMatch(cleaned);
  }

  // Format phone number to E.164 format (with + sign for Firebase)
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  // Format phone number for API calls (without + sign, just country code + number)
  static String formatPhoneNumberForApi(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Remove the + sign if present
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  // Email OTP Methods
  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      const String url = '$baseurl/auth/send-otp';

      final Map<String, dynamic> requestBody = {'email': email};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final body = response.body.trim();
      final isJson = body.startsWith('{') || body.startsWith('[');
      if (!isJson) {
        return {
          'success': false,
          'message': response.statusCode >= 500
              ? 'Server error. Please try again later.'
              : 'Could not send OTP. Please check your connection and try again.',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP sent to email successfully',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send email OTP',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to send email OTP: $e'};
    }
  }

  /// Check which verification method (email/phone) the user used at signup.
  ///
  /// Exactly one of [email] or [phone] should be provided.
  /// Returns:
  /// - {'success': true} when user exists and verification method matches input.
  /// - {'success': false, 'message': '<reason>'} for all error cases described in API docs.
  static Future<Map<String, dynamic>> checkAccountVerificationMethod({
    String? email,
    String? phone,
  }) async {
    try {
      // Basic client-side validation to avoid bad requests
      final hasEmail = email != null && email.trim().isNotEmpty;
      final hasPhone = phone != null && phone.trim().isNotEmpty;

      if (!hasEmail && !hasPhone) {
        return {'success': false, 'message': 'Email or phone is required'};
      }
      if (hasEmail && hasPhone) {
        return {
          'success': false,
          'message': 'Only email or phone required, not both',
        };
      }

      final queryParams = <String, String>{};
      if (hasEmail) {
        queryParams['email'] = email.trim();
      } else if (hasPhone) {
        // API expects phone without + prefix, like 9876543210
        queryParams['phone'] = formatPhoneNumberForApi(phone);
      }

      final uri = Uri.parse(
        '$baseurl/auth/account/verification-method',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);
      final body = response.body.trim();
      final isJson = body.startsWith('{') || body.startsWith('[');

      if (!isJson) {
        return {
          'success': false,
          'message': response.statusCode >= 500
              ? 'Server error. Please try again later.'
              : 'Could not verify account. Please try again.',
        };
      }

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        // User exists and verification method matches the provided field
        return {'success': true};
      }

      // For all documented error cases, backend returns success:false + message
      return {
        'success': false,
        'message':
            data['message']?.toString() ?? 'Failed to verify account method',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to verify account method: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      const String url = '$baseurl/auth/verify-otp';

      final Map<String, dynamic> requestBody = {'email': email, 'otp': otp};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final body = response.body.trim();
      final isJson = body.startsWith('{') || body.startsWith('[');
      if (!isJson) {
        return {
          'success': false,
          'message': response.statusCode >= 500
              ? 'Server error. Please try again later.'
              : 'Could not verify OTP. Please try again.',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Email OTP verified successfully',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Invalid OTP',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to verify email OTP: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendDeleteAccountOtp({
    required String email,
  }) async {
    try {
      const String url = '$baseurl/auth/delete-account/send-otp';
      final Map<String, dynamic> requestBody = {'email': email};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final body = response.body.trim();
      debugPrint('sendDeleteAccountOtp RAW status: ${response.statusCode}');
      debugPrint('sendDeleteAccountOtp RAW body: $body');

      final isJson = body.startsWith('{') || body.startsWith('[');
      if (!isJson) {
        return {
          'success': false,
          'message': response.statusCode >= 500
              ? 'Server error. Please try again later.'
              : 'Could not send OTP. Please try again.',
        };
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      debugPrint('sendDeleteAccountOtp parsed keys: ${data.keys.toList()}');
      debugPrint('sendDeleteAccountOtp parsed data: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API returns the OTP as the "data" field (a plain string).
        // e.g. {"success":true,"message":"OTP send successfully","data":"206421"}
        final otpValue =
            data['data']?.toString() ??
            data['otp']?.toString() ??
            (data['data'] is Map ? data['data']['otp']?.toString() : null);
        debugPrint('sendDeleteAccountOtp otpValue extracted: "$otpValue"');
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent',
          'otp': otpValue,
        };
      }

      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Failed to send OTP',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send delete account OTP: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteAccount({
    required String email,
    String? otp,
  }) async {
    try {
      const String url = '$baseurl/auth/delete-account';
      final Map<String, dynamic> requestBody = {'email': email};
      if (otp != null && otp.trim().isNotEmpty) {
        requestBody['otp'] = otp.trim();
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final body = response.body.trim();
      final isJson = body.startsWith('{') || body.startsWith('[');
      if (!isJson) {
        return {
          'success': false,
          'message': response.statusCode >= 500
              ? 'Server error. Please try again later.'
              : 'Could not delete account. Please try again.',
        };
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Account deleted successfully',
        };
      }

      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Failed to delete account',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete account: $e'};
    }
  }
}

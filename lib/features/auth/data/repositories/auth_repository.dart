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

      final Map<String, dynamic> requestBody = {
        'email': email,
        'name': name,
        'phone': phoneNumber,
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
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
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection');
    } on TimeoutException catch (e) {
      throw Exception('Network error: Request timeout. Please try again');
    } on http.ClientException catch (e) {
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

      final Map<String, dynamic> requestBody = {'phone': phone, 'email': email};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      return data;
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection');
    } on TimeoutException catch (e) {
      throw Exception('Network error: Request timeout. Please try again');
    } on http.ClientException catch (e) {
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
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

      final Map<String, dynamic> requestBody = {'phone': phoneNumber ?? ""};

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
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
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

  // Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(' ', ''));
  }

  // Format phone number to E.164 format
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to send email OTP: $e'};
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to verify email OTP: $e'};
    }
  }
}

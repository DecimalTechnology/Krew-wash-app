import 'dart:convert';

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
      print(
        "verificationMethoddddddddddddddddddddddddddd: $verificationMethod",
      );

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
    } catch (e) {
      if (kDebugMode) {
        print('Error registering user: $e');
      }
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
      if (kDebugMode) {
        print('Error getting user: $e');
      }
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
      print("requestBodyrequestBodyrequestBodyrequestBody: $requestBody");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print(e);
      if (kDebugMode) {
        print('Error checking phone and email existence: $e');
      }
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
      if (kDebugMode) {
        print('Error checking user existence: $e');
      }
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

      if (kDebugMode) {
        print('📧 Calling email login API: $url');
        print('📦 Request body: $requestBody');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print(response.body);

      if (kDebugMode) {
        print('📊 Email login API Response status: ${response.statusCode}');
        print('📊 Email login API Response body: ${response.body}');
      }

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
    } catch (e) {
      if (kDebugMode) {
        print('💥 Error calling email login API: $e');
      }
      return {'success': false, 'message': 'Failed to login with email: $e'};
    }
  }

  // Login user after phone verification
  static Future<Map<String, dynamic>> loginUserAfterPhoneVerification({
    String? uid,
    String? email,
    String? phoneNumber,
  }) async {
    print("loginnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
    try {
      const String url = '$baseurl/auth/login-phone';

      final Map<String, dynamic> requestBody = {'phone': phoneNumber ?? ""};

      if (kDebugMode) {
        print('🔐 Calling login API: $url');
        print('📦 Request body: $requestBody');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print("responseresponseresponseresponse: $response");

      if (kDebugMode) {
        print('📊 API Response status: ${response.statusCode}');
        print('📊 API Response body: ${response.body}');
      }

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
    } catch (e) {
      if (kDebugMode) {
        print('💥 Error calling login API: $e');
      }
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
    print("hiiiiiiiiiiiiiiiiiiiiiiiii");

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
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email OTP: $e');
      }
      return {'success': false, 'message': 'Failed to send email OTP: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print("otpppppppppppppp$otp");
      const String url = '$baseurl/auth/verify-otp';

      final Map<String, dynamic> requestBody = {'email': email, 'otp': otp};

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
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
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying email OTP: $e');
      }
      return {'success': false, 'message': 'Failed to verify email OTP: $e'};
    }
  }
}

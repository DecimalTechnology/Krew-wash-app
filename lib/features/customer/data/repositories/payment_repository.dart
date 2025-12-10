import 'dart:convert';
import 'package:carwash_app/core/constants/api.dart';
import 'package:carwash_app/core/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  // Initialize payment - get tokenURL and orderURL from backend
  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> bookingData,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      final uri = Uri.parse('$baseurl/payments/initialize');

      final body = jsonEncode({
        'amount': amount,
        'currency': currency,
        'bookingData': bookingData,
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (kDebugMode) {
        print('Payment initialization response: $decoded');
      }

      return decoded;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing payment: $e');
      }
      return {'success': false, 'message': 'Failed to initialize payment: $e'};
    }
  }

  // Create booking after successful payment
  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
    required String paymentTransactionId,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      final uri = Uri.parse('$baseurl/bookings');

      final body = jsonEncode({
        ...bookingData,
        'payment': {
          'transactionId': paymentTransactionId,
          'method': 'telr',
          'status': 'completed',
        },
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (kDebugMode) {
        print('Create booking response: $decoded');
      }

      return decoded;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating booking: $e');
      }
      return {'success': false, 'message': 'Failed to create booking: $e'};
    }
  }
}

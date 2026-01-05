import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carwash_app/core/constants/api.dart';
import 'package:carwash_app/core/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  // Create booking before payment (pre-booking)
  Future<Map<String, dynamic>> createBookingBeforePayment({
    String? packageId,
    required String vehicleId,
    required String vehicleTypeId,
    required List<Map<String, dynamic>> addons,
  }) async {
    // LOG VEHICLE ID AND TYPE ID DETAILS IN REPOSITORY
    print('═══════════════════════════════════════════════════════════');
    print('🚗 [PaymentRepository] VEHICLE ID AND TYPE ID DETAILS');
    print('═══════════════════════════════════════════════════════════');
    print('📦 packageId received: $packageId');
    print('📦 vehicleId received: $vehicleId');
    print('📦 vehicleId type: ${vehicleId.runtimeType}');
    print('📦 vehicleId length: ${vehicleId.length}');
    print('📦 vehicleTypeId received: $vehicleTypeId');
    print('📦 vehicleTypeId type: ${vehicleTypeId.runtimeType}');
    print('📦 vehicleTypeId length: ${vehicleTypeId.length}');
    print('📦 addons count: ${addons.length}');
    print('📦 addons: $addons');
    print('═══════════════════════════════════════════════════════════');

    try {
      final token = await SecureStorageService.getAccessToken();

      final uri = Uri.parse('$baseurl/booking');

      // Validate vehicleId before creating request
      if (vehicleId.isEmpty) {
        print('❌ [PaymentRepository] Vehicle ID is empty!');
        return {
          'success': false,
          'message': 'Vehicle ID is required but was empty',
        };
      }

      // Validate vehicleTypeId before creating request
      if (vehicleTypeId.isEmpty) {
        print('❌ [PaymentRepository] Vehicle Type ID is empty!');
        return {
          'success': false,
          'message': 'Vehicle Type ID is required but was empty',
        };
      }

      // Ensure vehicleId is a non-null string - DO NOT MODIFY
      final vehicleIdString = vehicleId.toString().trim();
      print('🔍 [PaymentRepository] Processing vehicleId...');
      print('   📦 Original: $vehicleId');
      print('   📦 After toString().trim(): $vehicleIdString');
      print('   📦 Match: ${vehicleId == vehicleIdString}');

      // Ensure vehicleTypeId is a non-null string
      final vehicleTypeIdString = vehicleTypeId.toString().trim();
      print('🔍 [PaymentRepository] Processing vehicleTypeId...');
      print('   📦 Original: $vehicleTypeId');
      print('   📦 After toString().trim(): $vehicleTypeIdString');
      print('   📦 Match: ${vehicleTypeId == vehicleTypeIdString}');

      if (vehicleIdString.isEmpty) {
        print('❌ [PaymentRepository] Vehicle ID is empty after processing!');
        return {
          'success': false,
          'message': 'Vehicle ID is required but was empty',
        };
      }

      if (vehicleTypeIdString.isEmpty) {
        print(
          '❌ [PaymentRepository] Vehicle Type ID is empty after processing!',
        );
        return {
          'success': false,
          'message': 'Vehicle Type ID is required but was empty',
        };
      }

      // Create request body - include both vehicleId and vehicleTypeId
      final requestBody = <String, dynamic>{
        'vehicleId': vehicleIdString, // Vehicle ID (_id field)
        'vehicleTypeId': vehicleTypeIdString, // Vehicle Type ID
        'addons': addons,
      };
      
      // Only include packageId if it's not null
      if (packageId != null && packageId.isNotEmpty) {
        requestBody['packageId'] = packageId.toString().trim();
      }

      print('═══════════════════════════════════════════════════════════');
      print('📦 [PaymentRepository] REQUEST BODY CREATED');
      print('═══════════════════════════════════════════════════════════');
      print('📦 packageId: "${requestBody['packageId']}"');
      print('📦 vehicleId: "${requestBody['vehicleId']}"');
      print('📦 vehicleId type: ${requestBody['vehicleId'].runtimeType}');
      print(
        '📦 vehicleId length: ${(requestBody['vehicleId'] as String).length}',
      );
      print('📦 vehicleTypeId: "${requestBody['vehicleTypeId']}"');
      print(
        '📦 vehicleTypeId type: ${requestBody['vehicleTypeId'].runtimeType}',
      );
      print(
        '📦 vehicleTypeId length: ${(requestBody['vehicleTypeId'] as String).length}',
      );
      print(
        '📦 vehicleId == vehicleIdString: ${requestBody['vehicleId'] == vehicleIdString}',
      );
      print(
        '📦 vehicleTypeId == vehicleTypeIdString: ${requestBody['vehicleTypeId'] == vehicleTypeIdString}',
      );
      print('📦 addons count: ${(requestBody['addons'] as List).length}');
      for (int i = 0; i < (requestBody['addons'] as List).length; i++) {
        final addon =
            (requestBody['addons'] as List)[i] as Map<String, dynamic>;
        print('   📦 Addon $i: $addon');
        print('   📦 Addon $i keys: ${addon.keys.toList()}');
        if (addon.containsKey('vehicleId') ||
            addon.containsKey('vehicle_id') ||
            addon.containsKey('vehicleTypeId') ||
            addon.containsKey('vehicle_type_id')) {
          print(
            '   ⚠️⚠️⚠️ CRITICAL: Addon $i contains vehicle ID/Type ID field!',
          );
        }
      }
      print('═══════════════════════════════════════════════════════════');

      final body = jsonEncode(requestBody);
      print('═══════════════════════════════════════════════════════════');
      print('📄 [PaymentRepository] JSON BODY ENCODED');
      print('═══════════════════════════════════════════════════════════');
      print('📄 JSON string: $body');
      print('📄 JSON length: ${body.length} bytes');
      print('═══════════════════════════════════════════════════════════');

      // Verify vehicleId and vehicleTypeId in JSON
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [PaymentRepository] VERIFYING VEHICLE ID AND TYPE ID IN JSON');
      print('═══════════════════════════════════════════════════════════');
      final vehicleIdMatch = RegExp(
        r'"vehicleId"\s*:\s*"([^"]+)"',
      ).firstMatch(body);
      final vehicleTypeIdMatch = RegExp(
        r'"vehicleTypeId"\s*:\s*"([^"]+)"',
      ).firstMatch(body);

      if (vehicleIdMatch != null) {
        final vehicleIdInJson = vehicleIdMatch.group(1);
        print('📦 Vehicle ID extracted from JSON: "$vehicleIdInJson"');
        print('📦 Expected vehicleIdString: "$vehicleIdString"');
        print(
          '📦 Match with vehicleIdString: ${vehicleIdInJson == vehicleIdString}',
        );
        if (vehicleIdInJson != vehicleIdString) {
          print('❌❌❌ CRITICAL: Vehicle ID mismatch in JSON!');
          print('   Expected: "$vehicleIdString"');
          print('   Got: "$vehicleIdInJson"');
        } else {
          print('✅ Vehicle ID matches in JSON');
        }
      } else {
        print('⚠️ Could not extract vehicleId from JSON string');
      }

      if (vehicleTypeIdMatch != null) {
        final vehicleTypeIdInJson = vehicleTypeIdMatch.group(1);
        print('📦 Vehicle Type ID extracted from JSON: "$vehicleTypeIdInJson"');
        print('📦 Expected vehicleTypeIdString: "$vehicleTypeIdString"');
        print(
          '📦 Match with vehicleTypeIdString: ${vehicleTypeIdInJson == vehicleTypeIdString}',
        );
        if (vehicleTypeIdInJson != vehicleTypeIdString) {
          print('❌❌❌ CRITICAL: Vehicle Type ID mismatch in JSON!');
          print('   Expected: "$vehicleTypeIdString"');
          print('   Got: "$vehicleTypeIdInJson"');
        } else {
          print('✅ Vehicle Type ID matches in JSON');
        }
      } else {
        print('⚠️ Could not extract vehicleTypeId from JSON string');
      }
      print('═══════════════════════════════════════════════════════════');

      // Parse back to verify
      print('═══════════════════════════════════════════════════════════');
      print('✅ [PaymentRepository] PARSING JSON BACK FOR VERIFICATION');
      print('═══════════════════════════════════════════════════════════');
      try {
        final parsed = jsonDecode(body) as Map<String, dynamic>;
        print('📦 vehicleId in parsed JSON: "${parsed['vehicleId']}"');
        print('📦 vehicleId type: ${parsed['vehicleId'].runtimeType}');
        print('📦 vehicleId length: ${(parsed['vehicleId'] as String).length}');
        print(
          '📦 vehicleId Match with vehicleIdString: ${parsed['vehicleId'] == vehicleIdString}',
        );
        print('📦 vehicleTypeId in parsed JSON: "${parsed['vehicleTypeId']}"');
        print('📦 vehicleTypeId type: ${parsed['vehicleTypeId'].runtimeType}');
        print(
          '📦 vehicleTypeId length: ${(parsed['vehicleTypeId'] as String).length}',
        );
        print(
          '📦 vehicleTypeId Match with vehicleTypeIdString: ${parsed['vehicleTypeId'] == vehicleTypeIdString}',
        );

        // Check addons for any vehicleId contamination
        final addonsList = parsed['addons'] as List?;
        if (addonsList != null) {
          for (int i = 0; i < addonsList.length; i++) {
            final addon = addonsList[i] as Map<String, dynamic>?;
            if (addon != null) {
              print('   📦 Addon $i: $addon');
              if (addon.containsKey('vehicleId') ||
                  addon.containsKey('vehicle_id')) {
                print('   ⚠️⚠️⚠️ CRITICAL: Addon $i contains vehicleId field!');
                print(
                  '      vehicleId value: ${addon['vehicleId'] ?? addon['vehicle_id']}',
                );
              }
            }
          }
        }

        if (parsed['vehicleId'] != vehicleIdString) {
          print('❌❌❌ CRITICAL: Vehicle ID mismatch after parsing!');
        } else {
          print('✅ Vehicle ID verified correctly in parsed JSON');
        }

        if (parsed['vehicleTypeId'] != vehicleTypeIdString) {
          print('❌❌❌ CRITICAL: Vehicle Type ID mismatch after parsing!');
        } else {
          print('✅ Vehicle Type ID verified correctly in parsed JSON');
        }
      } catch (e) {
        print('⚠️ Could not parse JSON back: $e');
      }
      print('═══════════════════════════════════════════════════════════');

      // LOG BEFORE SENDING HTTP REQUEST
      print('═══════════════════════════════════════════════════════════');
      print('📤 [PaymentRepository] ABOUT TO SEND HTTP POST REQUEST');
      print('═══════════════════════════════════════════════════════════');
      print('📤 URL: $uri');
      print('📤 Method: POST');
      print('📤 Body: $body');
      print('📤 Body length: ${body.length} bytes');
      print('📤 vehicleId in body: "$vehicleIdString"');
      print('📤 Original vehicleId: "$vehicleId"');
      print('═══════════════════════════════════════════════════════════');

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Create booking request timeout',
                const Duration(seconds: 30),
              );
            },
          );
      stopwatch.stop();

      // LOG AFTER RECEIVING RESPONSE
      print('═══════════════════════════════════════════════════════════');
      print('📥 [PaymentRepository] HTTP RESPONSE RECEIVED');
      print('═══════════════════════════════════════════════════════════');
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded;
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
      return {'success': false, 'message': 'Failed to create booking: $e'};
    }
  }

  // Initialize payment - get tokenURL and orderURL from backend
  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    try {
      final token = await SecureStorageService.getAccessToken();

      final uri = Uri.parse('$baseurl/payments/initialize');

      final body = jsonEncode({'totalPrice': amount, 'bookingId': bookingId});

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Payment initialization request timeout',
                const Duration(seconds: 30),
              );
            },
          );
      stopwatch.stop();

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      return decoded;
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

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Create booking request timeout',
                const Duration(seconds: 30),
              );
            },
          );
      stopwatch.stop();

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      return decoded;
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
      return {'success': false, 'message': 'Failed to create booking: $e'};
    }
  }

  /// Verify Telr Payment Status
  /// 
  /// Verifies the payment status of a Telr transaction using the order reference.
  /// Returns a normalized response with status and bookingStatus fields.
  /// 
  /// Status values:
  /// - SUCCESS: Payment completed
  /// - PENDING: Processing
  /// - REJECTED: Merchant/test rejection
  /// - CANCELLED: User cancelled
  /// - DECLINED: Bank declined
  /// - FAILED: Payment failed
  /// - EXPIRED: Session expired
  /// - UNKNOWN: Unrecognized state
  /// - INVALID_REQUEST: Missing order reference
  /// - VERIFICATION_ERROR: Gateway/Network error
  Future<Map<String, dynamic>> verifyTelrPaymentStatus({
    required String orderRef,
  }) async {
    if (kDebugMode) {
    print('═══════════════════════════════════════════════════════════');
      print('🔄 [PaymentRepository] verifyTelrPaymentStatus API Call');
    print('═══════════════════════════════════════════════════════════');
      print('📦 orderRef: $orderRef');
    }

    // Validate order reference
    if (orderRef.isEmpty || orderRef.trim().isEmpty) {
      if (kDebugMode) {
        print('❌ [PaymentRepository] Missing Telr order reference');
      }
      return {
        'success': false,
        'status': 'INVALID_REQUEST',
        'message': 'Missing Telr order reference',
      };
    }

    try {
      final token = await SecureStorageService.getAccessToken();
      if (kDebugMode) {
      print('📦 token available: ${token != null && token.isNotEmpty}');
      }

      // Try /payments/status (plural) first, fallback to /payment/status (singular) if 404
      Uri uri = Uri.parse('$baseurl/payments/status');
      if (kDebugMode) {
      print('📦 API URL: $uri');
      }

      final body = jsonEncode({'ref': orderRef.trim()});
      if (kDebugMode) {
      print('📦 Request body: $body');
      }

      if (kDebugMode) {
      print('🔄 Sending POST request...');
      }
      http.Response response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              if (kDebugMode) {
              print('❌ [PaymentRepository] Request timeout');
              }
              throw TimeoutException(
                'Payment status verification request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      if (kDebugMode) {
      print('📦 Response status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      }

      // If 404, try the singular endpoint as fallback
      if (response.statusCode == 404) {
        if (kDebugMode) {
          print('⚠️ [PaymentRepository] 404 on /payments/status, trying /payment/status...');
        }
        uri = Uri.parse('$baseurl/payment/status');
        if (kDebugMode) {
          print('📦 Fallback API URL: $uri');
        }
        response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
              body: body,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                if (kDebugMode) {
                  print('❌ [PaymentRepository] Fallback request timeout');
                }
                throw TimeoutException(
                  'Payment status verification request timeout',
                  const Duration(seconds: 30),
                );
              },
            );
        if (kDebugMode) {
          print('📦 Fallback response status code: ${response.statusCode}');
          print('📦 Fallback response body: ${response.body}');
        }
      }

      // Parse response
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle different HTTP status codes
      if (response.statusCode == 400) {
        // Missing order reference
        if (kDebugMode) {
          print('❌ [PaymentRepository] Bad Request (400)');
        }
        return {
          'success': false,
          'status': decoded['status'] ?? 'INVALID_REQUEST',
          'message': decoded['message'] ?? 'Missing Telr order reference',
        };
      } else if (response.statusCode == 500) {
        // Verification error
        if (kDebugMode) {
          print('❌ [PaymentRepository] Server Error (500)');
        }
        return {
          'success': false,
          'status': decoded['status'] ?? 'VERIFICATION_ERROR',
          'bookingStatus': decoded['bookingStatus'] ?? 'FAILED',
          'message': decoded['message'] ??
              'Error verifying payment with payment gateway',
        };
      } else if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response (200 OK)
        // The API returns 200 for all statuses (success, pending, rejected, etc.)
        if (kDebugMode) {
      if (decoded['success'] == true) {
            print('✅ [PaymentRepository] Payment status: SUCCESS');
      } else {
            print(
              '⚠️ [PaymentRepository] Payment status: ${decoded['status'] ?? 'UNKNOWN'}',
            );
          }
          print('   bookingStatus: ${decoded['bookingStatus']}');
        print('   message: ${decoded['message']}');
      }

        // Return normalized response
        return {
          'success': decoded['success'] ?? false,
          'status': decoded['status'] ?? 'UNKNOWN',
          'bookingStatus': decoded['bookingStatus'] ?? 'FAILED',
          'message': decoded['message'] ?? 'Unable to determine payment status',
          if (decoded['data'] != null) 'data': decoded['data'],
          if (decoded['debugInfo'] != null) 'debugInfo': decoded['debugInfo'],
        };
      } else {
        // Other HTTP errors
        if (kDebugMode) {
          print(
            '❌ [PaymentRepository] HTTP error status: ${response.statusCode}',
          );
        }
        return {
          'success': false,
          'status': 'VERIFICATION_ERROR',
          'bookingStatus': 'FAILED',
          'message': 'Server error: HTTP ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] SocketException: $e');
      }
      return {
        'success': false,
        'status': 'VERIFICATION_ERROR',
        'bookingStatus': 'FAILED',
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] TimeoutException: $e');
      }
      return {
        'success': false,
        'status': 'VERIFICATION_ERROR',
        'bookingStatus': 'FAILED',
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] ClientException: $e');
      }
      return {
        'success': false,
        'status': 'VERIFICATION_ERROR',
        'bookingStatus': 'FAILED',
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] Unexpected error: $e');
      print('   Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'status': 'VERIFICATION_ERROR',
        'bookingStatus': 'FAILED',
        'message': 'Failed to verify payment status: $e',
      };
    }
  }

  // Legacy method - kept for backward compatibility
  // Check payment status using reference ID
  @Deprecated('Use verifyTelrPaymentStatus instead')
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String reference,
  }) async {
    return verifyTelrPaymentStatus(orderRef: reference);
  }

  // Confirm payment success
  Future<Map<String, dynamic>> confirmPaymentSuccess({
    required String orderRef,
    required String transactionRef,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('🔄 [PaymentRepository] confirmPaymentSuccess API Call');
    print('═══════════════════════════════════════════════════════════');
    print('📦 orderRef: $orderRef');
    print('📦 transactionRef: $transactionRef');

    try {
      final token = await SecureStorageService.getAccessToken();
      print('📦 token available: ${token != null && token.isNotEmpty}');

      final uri = Uri.parse('$baseurl/payments/success');
      print('📦 API URL: $uri');

      final body = jsonEncode({
        'orderRef': orderRef,
        'transactionRef': transactionRef,
      });
      print('📦 Request body: $body');

      print('🔄 Sending POST request...');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('❌ [PaymentRepository] Request timeout');
              throw TimeoutException(
                'Payment success confirmation request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      print('📦 Response status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Check HTTP status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print(
          '❌ [PaymentRepository] HTTP error status: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Server error: HTTP ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      print('✅ [PaymentRepository] API call successful');
      print('   Response: $decoded');
      print('═══════════════════════════════════════════════════════════');

      return decoded;
    } on SocketException catch (e) {
      print('❌ [PaymentRepository] SocketException: $e');
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      print('❌ [PaymentRepository] TimeoutException: $e');
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      print('❌ [PaymentRepository] ClientException: $e');
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e, stackTrace) {
      print('❌ [PaymentRepository] Unexpected error: $e');
      print('   Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Failed to confirm payment success: $e',
      };
    }
  }

  /// Cancel Payment
  /// 
  /// Marks a Telr payment as FAILED or CANCELLED and updates the related booking.
  /// 
  /// **Status Rules:**
  /// - Status must be either "FAILED" or "CANCELLED"
  /// - Cannot cancel if payment is already COMPLETED
  /// - Cannot set same status if already set (idempotent)
  /// 
  /// **Error Responses:**
  /// - 400: Missing order reference, invalid status, or payment already completed
  /// - 404: Booking not found
  /// - 409: Booking already cancelled/failed
  Future<Map<String, dynamic>> cancelPayment({
    required String orderRef,
    required String status,
  }) async {
    if (kDebugMode) {
    print('═══════════════════════════════════════════════════════════');
    print('🔄 [PaymentRepository] cancelPayment API Call');
    print('═══════════════════════════════════════════════════════════');
    print('📦 orderRef: $orderRef');
      print('📦 status: $status');
    }

    // Validate order reference
    if (orderRef.isEmpty || orderRef.trim().isEmpty) {
      if (kDebugMode) {
        print('❌ [PaymentRepository] Missing order reference');
      }
      return {
        'success': false,
        'message': 'Missing Telr order reference',
      };
    }

    // Validate status - must be FAILED or CANCELLED
    final normalizedStatus = status.trim().toUpperCase();
    if (normalizedStatus != 'FAILED' && normalizedStatus != 'CANCELLED') {
      if (kDebugMode) {
        print('❌ [PaymentRepository] Invalid status: $status');
        print('   Allowed values: FAILED, CANCELLED');
      }
      return {
        'success': false,
        'message': 'Invalid payment status. Must be FAILED or CANCELLED',
      };
    }

    try {
      final token = await SecureStorageService.getAccessToken();
      if (kDebugMode) {
      print('📦 token available: ${token != null && token.isNotEmpty}');
      }

      final uri = Uri.parse('$baseurl/payments/cancel');
      if (kDebugMode) {
      print('📦 API URL: $uri');
      }

      // Build request body with orderRef and status (both required)
      final requestBody = <String, dynamic>{
        'orderRef': orderRef.trim(),
        'status': normalizedStatus,
      };

      final body = jsonEncode(requestBody);
      if (kDebugMode) {
      print('📦 Request body: $body');
      }

      if (kDebugMode) {
      print('🔄 Sending POST request...');
      }
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              if (kDebugMode) {
              print('❌ [PaymentRepository] Request timeout');
              }
              throw TimeoutException(
                'Payment cancel request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      if (kDebugMode) {
      print('📦 Response status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      }

      // Parse response
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle different HTTP status codes
      if (response.statusCode == 400) {
        // Bad Request: Missing order reference, invalid status, or payment already completed
        if (kDebugMode) {
          print('❌ [PaymentRepository] Bad Request (400)');
          print('   message: ${decoded['message']}');
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Invalid request',
          'statusCode': 400,
        };
      } else if (response.statusCode == 404) {
        // Not Found: Booking not found
        if (kDebugMode) {
          print('❌ [PaymentRepository] Not Found (404)');
          print('   message: ${decoded['message']}');
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Booking not found for this payment',
          'statusCode': 404,
        };
      } else if (response.statusCode == 409) {
        // Conflict: Booking already cancelled/failed
        if (kDebugMode) {
          print('❌ [PaymentRepository] Conflict (409)');
          print('   message: ${decoded['message']}');
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Booking already cancelled or failed',
          'statusCode': 409,
        };
      } else if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        if (kDebugMode) {
          print('✅ [PaymentRepository] cancelPayment successful');
          print('   bookingId: ${decoded['bookingId']}');
          print('   message: ${decoded['message']}');
          print('═══════════════════════════════════════════════════════════');
        }
        return decoded;
      } else {
        // Other HTTP errors
        if (kDebugMode) {
        print(
          '❌ [PaymentRepository] HTTP error status: ${response.statusCode}',
        );
        }
        return {
          'success': false,
          'message': decoded['message'] ??
              'Server error: HTTP ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] SocketException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] TimeoutException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
    } on http.ClientException catch (e) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] ClientException: $e');
      }
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
      print('❌ [PaymentRepository] Unexpected error: $e');
      print('   Stack trace: $stackTrace');
      }
      return {'success': false, 'message': 'Failed to cancel payment: $e'};
    }
  }
}

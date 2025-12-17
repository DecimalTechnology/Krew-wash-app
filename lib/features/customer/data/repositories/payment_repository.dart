import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carwash_app/core/constants/api.dart';
import 'package:carwash_app/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  // Create booking before payment (pre-booking)
  Future<Map<String, dynamic>> createBookingBeforePayment({
    required String packageId,
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
        'packageId': packageId.toString().trim(),
        'vehicleId': vehicleIdString, // Vehicle ID (_id field)
        'vehicleTypeId': vehicleTypeIdString, // Vehicle Type ID
        'addons': addons,
      };

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

  // Check payment status using reference ID
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String reference,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('🔄 [PaymentRepository] checkPaymentStatus API Call');
    print('═══════════════════════════════════════════════════════════');
    print('📦 reference: $reference');

    try {
      final token = await SecureStorageService.getAccessToken();
      print('📦 token available: ${token != null && token.isNotEmpty}');

      final uri = Uri.parse('$baseurl/payments/status');
      print('📦 API URL: $uri');

      final body = jsonEncode({'ref': reference});
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
                'Payment status check request timeout',
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
        final errorResponse = {
          'success': false,
          'message': 'Server error: HTTP ${response.statusCode}',
          'statusCode': response.statusCode,
        };
        print('📦 Returning error response: $errorResponse');
        print('═══════════════════════════════════════════════════════════');
        return errorResponse;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (decoded['success'] == true) {
        print('✅ [PaymentRepository] Payment status check successful');
      } else {
        print('❌ [PaymentRepository] Payment status check failed');
        print('   success: ${decoded['success']}');
        print('   message: ${decoded['message']}');
      }

      print('📦 Response: $decoded');
      print('═══════════════════════════════════════════════════════════');

      return decoded;
    } on SocketException catch (e) {
      print('❌ [PaymentRepository] SocketException: $e');
      final errorResponse = {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
      print('📦 Returning error response: $errorResponse');
      print('═══════════════════════════════════════════════════════════');
      return errorResponse;
    } on TimeoutException catch (e) {
      print('❌ [PaymentRepository] TimeoutException: $e');
      final errorResponse = {
        'success': false,
        'message': 'Network error: Request timeout. Please try again',
        'isNetworkError': true,
      };
      print('📦 Returning error response: $errorResponse');
      print('═══════════════════════════════════════════════════════════');
      return errorResponse;
    } on http.ClientException catch (e) {
      print('❌ [PaymentRepository] ClientException: $e');
      final errorResponse = {
        'success': false,
        'message': 'Network error: Please check your internet connection',
        'isNetworkError': true,
      };
      print('📦 Returning error response: $errorResponse');
      print('═══════════════════════════════════════════════════════════');
      return errorResponse;
    } catch (e, stackTrace) {
      print('❌ [PaymentRepository] Unexpected error: $e');
      print('   Stack trace: $stackTrace');
      final errorResponse = {
        'success': false,
        'message': 'Failed to check payment status: $e',
      };
      print('📦 Returning error response: $errorResponse');
      print('═══════════════════════════════════════════════════════════');
      return errorResponse;
    }
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

  // Cancel payment (when status check returns success=false)
  Future<Map<String, dynamic>> cancelPayment({required String orderRef}) async {
    print('═══════════════════════════════════════════════════════════');
    print('🔄 [PaymentRepository] cancelPayment API Call');
    print('═══════════════════════════════════════════════════════════');
    print('📦 orderRef: $orderRef');

    try {
      final token = await SecureStorageService.getAccessToken();
      print('📦 token available: ${token != null && token.isNotEmpty}');

      final uri = Uri.parse('$baseurl/payments/cancel');
      print('📦 API URL: $uri');

      final body = jsonEncode({'orderRef': orderRef});
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
                'Payment cancel request timeout',
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
      print('✅ [PaymentRepository] cancelPayment API call completed');
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
      return {'success': false, 'message': 'Failed to cancel payment: $e'};
    }
  }
}

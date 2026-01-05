import 'package:flutter/foundation.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  bool _isInitializing = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _tokenUrl;
  String? _orderUrl;
  String? _paymentUrl;
  String? _reference;

  bool get isInitializing => _isInitializing;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get tokenUrl => _tokenUrl;
  String? get orderUrl => _orderUrl;
  String? get paymentUrl => _paymentUrl;
  String? get reference => _reference;

  Future<Map<String, dynamic>> createBookingBeforePayment({
    String? packageId,
    required String vehicleId,
    required String vehicleTypeId,
    required List<Map<String, dynamic>> addons,
  }) async {
    // LOG VEHICLE ID AND TYPE ID DETAILS IN PROVIDER
    print('═══════════════════════════════════════════════════════════');
    print('🚗 [PaymentProvider] VEHICLE ID AND TYPE ID DETAILS');
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

    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if addons contain any vehicleId fields that might interfere
      for (int i = 0; i < addons.length; i++) {
        if (addons[i].containsKey('vehicleId') ||
            addons[i].containsKey('vehicle_id')) {
          print('⚠️ WARNING: Addon $i contains vehicleId field!');
        }
      }

      // Store IDs before call for comparison
      final vehicleIdBeforeCall = vehicleId;
      final vehicleTypeIdBeforeCall = vehicleTypeId;
      print('🔒 [PaymentProvider] IDs stored before call:');
      print('   📦 vehicleId: "$vehicleIdBeforeCall"');
      print('   📦 vehicleTypeId: "$vehicleTypeIdBeforeCall"');

      // LOG BEFORE CALLING REPOSITORY
      print('═══════════════════════════════════════════════════════════');
      print(
        '📞 [PaymentProvider] ABOUT TO CALL Repository.createBookingBeforePayment',
      );
      print('═══════════════════════════════════════════════════════════');
      print('📦 packageId being passed: "$packageId"');
      print('📦 vehicleId being passed: "$vehicleId"');
      print('📦 vehicleId type: ${vehicleId.runtimeType}');
      print('📦 vehicleId length: ${vehicleId.length}');
      print('📦 vehicleTypeId being passed: "$vehicleTypeId"');
      print('📦 vehicleTypeId type: ${vehicleTypeId.runtimeType}');
      print('📦 vehicleTypeId length: ${vehicleTypeId.length}');
      print('📦 addons count: ${addons.length}');
      for (int i = 0; i < addons.length; i++) {
        print('   📦 Addon $i: ${addons[i]}');
        print('   📦 Addon $i keys: ${addons[i].keys.toList()}');
        if (addons[i].containsKey('vehicleId') ||
            addons[i].containsKey('vehicle_id') ||
            addons[i].containsKey('vehicleTypeId') ||
            addons[i].containsKey('vehicle_type_id')) {
          print(
            '   ⚠️⚠️⚠️ CRITICAL: Addon $i contains vehicle ID/Type ID field!',
          );
        }
      }
      print('═══════════════════════════════════════════════════════════');

      final response = await _repository.createBookingBeforePayment(
        packageId: packageId,
        vehicleId: vehicleId,
        vehicleTypeId: vehicleTypeId,
        addons: addons,
      );

      // LOG AFTER CALLING REPOSITORY
      print('═══════════════════════════════════════════════════════════');
      print(
        '📥 [PaymentProvider] AFTER Repository.createBookingBeforePayment CALL',
      );
      print('═══════════════════════════════════════════════════════════');
      print('📦 vehicleId (before call): "$vehicleIdBeforeCall"');
      print('📦 vehicleId (after call): "$vehicleId"');
      print('📦 vehicleId unchanged: ${vehicleId == vehicleIdBeforeCall}');
      print('📦 vehicleTypeId (before call): "$vehicleTypeIdBeforeCall"');
      print('📦 vehicleTypeId (after call): "$vehicleTypeId"');
      print(
        '📦 vehicleTypeId unchanged: ${vehicleTypeId == vehicleTypeIdBeforeCall}',
      );
      print('📦 response success: ${response['success']}');
      print('═══════════════════════════════════════════════════════════');

      // Verify vehicle ID didn't change
      if (vehicleIdBeforeCall != vehicleId) {}

      _isInitializing = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = 'Error creating booking: $e';
      _isInitializing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    _isInitializing = true;
    _errorMessage = null;
    _tokenUrl = null;
    _orderUrl = null;
    _paymentUrl = null;
    _reference = null;
    notifyListeners();

    try {
      final response = await _repository.initializePayment(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
      );

      if (response['success'] == true) {
        // Extract paymentUrl and reference directly from root response
        // Expected format: {success: true, paymentUrl: "...", reference: "..."}
        final paymentUrlValue = response['paymentUrl'];
        final referenceValue = response['reference'];

        // Handle different possible types - convert to String
        if (paymentUrlValue != null) {
          _paymentUrl = paymentUrlValue.toString();
        } else {}

        if (referenceValue != null) {
          _reference = referenceValue.toString();
        } else {}

        // Check if we have paymentUrl (required for WebView flow)
        if (_paymentUrl == null || _paymentUrl!.isEmpty) {
          _errorMessage =
              'Payment URL not found. Backend must return paymentUrl in response.';
          _isInitializing = false;
          notifyListeners();
          return {
            'success': false,
            'message': _errorMessage,
            'isNetworkError': response['isNetworkError'] == true,
          };
        }

        _isInitializing = false;
        notifyListeners();
        return response;
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Failed to initialize payment';
        _isInitializing = false;
        notifyListeners();
        return {
          ...response,
          'isNetworkError': response['isNetworkError'] == true,
        };
      }
    } catch (e) {
      _errorMessage = 'Error initializing payment: $e';
      _isInitializing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
    required String paymentTransactionId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.createBooking(
        bookingData: bookingData,
        paymentTransactionId: paymentTransactionId,
      );

      _isProcessing = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = 'Error creating booking: $e';
      _isProcessing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus({
    required String reference,
  }) async {
    if (kDebugMode) {
      print('🔄 [PaymentProvider] checkPaymentStatus called');
      print('   reference: $reference');
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.checkPaymentStatus(
        reference: reference,
      );

      if (kDebugMode) {
        print('✅ [PaymentProvider] checkPaymentStatus response received');
        print('   success: ${response['success']}');
        print('   message: ${response['message']}');
        if (response['success'] != true) {
          print('   ⚠️ Payment status check returned success=false');
        }
      }

      _isProcessing = false;
      notifyListeners();
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PaymentProvider] Exception in checkPaymentStatus: $e');
        print('   Stack trace: $stackTrace');
      }
      _errorMessage = 'Error checking payment status: $e';
      _isProcessing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  Future<Map<String, dynamic>> confirmPaymentSuccess({
    required String orderRef,
    required String transactionRef,
  }) async {
    if (kDebugMode) {
      print('🔄 [PaymentProvider] confirmPaymentSuccess called');
      print('   orderRef: $orderRef');
      print('   transactionRef: $transactionRef');
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.confirmPaymentSuccess(
        orderRef: orderRef,
        transactionRef: transactionRef,
      );

      if (kDebugMode) {
        print('✅ [PaymentProvider] confirmPaymentSuccess response received');
        print('   success: ${response['success']}');
        print('   message: ${response['message']}');
      }

      _isProcessing = false;
      notifyListeners();
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PaymentProvider] Exception in confirmPaymentSuccess: $e');
        print('   Stack trace: $stackTrace');
      }
      _errorMessage = 'Error confirming payment success: $e';
      _isProcessing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  /// Cancel Payment
  ///
  /// Marks a Telr payment as FAILED or CANCELLED.
  ///
  /// **Parameters:**
  /// - `orderRef`: Telr order reference (required)
  /// - `status`: Payment status - must be "FAILED" or "CANCELLED" (required)
  ///
  /// **Returns:**
  /// - Success: `{success: true, message: "...", bookingId: "..."}`
  /// - Error: `{success: false, message: "...", statusCode: ...}`
  Future<Map<String, dynamic>> cancelPayment({
    required String orderRef,
    required String status,
  }) async {
    if (kDebugMode) {
      print('🔄 [PaymentProvider] cancelPayment called');
      print('   orderRef: $orderRef');
      print('   status: $status');
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.cancelPayment(
        orderRef: orderRef,
        status: status,
      );

      if (kDebugMode) {
        print('✅ [PaymentProvider] cancelPayment response received');
        print('   success: ${response['success']}');
        print('   message: ${response['message']}');
      }

      _isProcessing = false;
      notifyListeners();
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [PaymentProvider] Exception in cancelPayment: $e');
        print('   Stack trace: $stackTrace');
      }
      _errorMessage = 'Error cancelling payment: $e';
      _isProcessing = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  void reset() {
    _isInitializing = false;
    _isProcessing = false;
    _errorMessage = null;
    _tokenUrl = null;
    _orderUrl = null;
    _paymentUrl = null;
    _reference = null;
    notifyListeners();
  }
}

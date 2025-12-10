import 'package:flutter/foundation.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  bool _isInitializing = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _tokenUrl;
  String? _orderUrl;

  bool get isInitializing => _isInitializing;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get tokenUrl => _tokenUrl;
  String? get orderUrl => _orderUrl;

  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> bookingData,
  }) async {
    _isInitializing = true;
    _errorMessage = null;
    _tokenUrl = null;
    _orderUrl = null;
    notifyListeners();

    try {
      final response = await _repository.initializePayment(
        amount: amount,
        currency: currency,
        bookingData: bookingData,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _tokenUrl = data['tokenUrl'] as String?;
        _orderUrl = data['orderUrl'] as String?;

        _isInitializing = false;
        notifyListeners();
        return response;
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Failed to initialize payment';
        _isInitializing = false;
        notifyListeners();
        return response;
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

  void reset() {
    _isInitializing = false;
    _isProcessing = false;
    _errorMessage = null;
    _tokenUrl = null;
    _orderUrl = null;
    notifyListeners();
  }
}

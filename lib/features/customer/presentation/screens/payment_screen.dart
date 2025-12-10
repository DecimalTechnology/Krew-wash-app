import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:telr_mobile_payment_sdk/telr_mobile_payment_sdk.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/payment_provider.dart';

class PaymentScreenArguments {
  const PaymentScreenArguments({
    required this.amount,
    required this.currency,
    required this.bookingData,
    required this.package,
    required this.selectedAddOns,
    required this.selectedDates,
    required this.selectedVehicle,
  });

  final double amount;
  final String currency;
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> package;
  final List<Map<String, dynamic>> selectedAddOns;
  final List<DateTime> selectedDates;
  final Map<String, dynamic> selectedVehicle;
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.arguments});

  final PaymentScreenArguments? arguments;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _statusMessage = 'Initializing payment...';

  @override
  void initState() {
    super.initState();
    print('🚀 PaymentScreen initState called');
    print('   Arguments: ${widget.arguments != null ? "present" : "null"}');
    if (widget.arguments != null) {
      print('   Amount: ${widget.arguments!.amount}');
      print('   Currency: ${widget.arguments!.currency}');
    }
    try {
      _initializePayment();
    } catch (e, stackTrace) {
      print('❌❌❌ ERROR IN initState ❌❌❌');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
    }
  }

  Future<void> _initializePayment() async {
    print('🔄 _initializePayment called');

    if (widget.arguments == null) {
      print('❌ Payment arguments are null in _initializePayment');
      if (mounted) {
        _showError('Invalid payment data');
      }
      return;
    }

    print('🔄 Initializing payment with backend...');
    print('   Amount: ${widget.arguments!.amount}');
    print('   Currency: ${widget.arguments!.currency}');

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Connecting to payment gateway...';
    });

    try {
      // Initialize payment with backend to get tokenURL and orderURL
      setState(() {
        _statusMessage = 'Requesting payment session...';
      });

      final response = await paymentProvider.initializePayment(
        amount: widget.arguments!.amount,
        currency: widget.arguments!.currency,
        bookingData: widget.arguments!.bookingData,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (response['success'] == true &&
          paymentProvider.tokenUrl != null &&
          paymentProvider.orderUrl != null) {
        print('✅ Payment initialized, tokenURL and orderURL received');
        setState(() {
          _statusMessage = 'Opening payment gateway...';
        });
        // Proceed with Telr payment
        await _processPayment(paymentProvider);
      } else {
        print('❌ Failed to initialize payment');
        print('   Response: $response');
        print('   TokenURL: ${paymentProvider.tokenUrl}');
        print('   OrderURL: ${paymentProvider.orderUrl}');

        String errorMsg =
            response['message']?.toString() ?? 'Failed to initialize payment';

        // Check if it's a 404 or API not found error
        if (errorMsg.contains('404') ||
            errorMsg.contains('not found') ||
            errorMsg.contains('Route not found')) {
          errorMsg =
              'Payment API endpoint not found. '
              'Please ensure your backend has the payment initialization endpoint: '
              'POST /api/v1/payments/initialize';
        }

        _showError(errorMsg);
      }
    } catch (e, stackTrace) {
      print('❌❌❌ ERROR IN _initializePayment ❌❌❌');
      print('   Error: $e');
      print('   Error type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showError('Failed to initialize payment: $e');
      } else {
        print('⚠️ Widget not mounted, cannot show error dialog');
      }
    }
  }

  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    print('🔄 _processPayment started');
    print('   TokenURL: ${paymentProvider.tokenUrl}');
    print('   OrderURL: ${paymentProvider.orderUrl}');

    if (paymentProvider.tokenUrl == null || paymentProvider.orderUrl == null) {
      print('❌ TokenURL or OrderURL is null');
      if (mounted) {
        _showError('Payment initialization failed. Missing payment URLs.');
      }
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Loading payment gateway...';
      });

      print('🔄 Calling TelrSdk.presentPayment...');

      // Call Telr SDK with tokenURL and orderURL
      final result = await TelrSdk.presentPayment(
        paymentProvider.tokenUrl!,
        paymentProvider.orderUrl!,
      );

      print('✅ Telr payment response received');
      print('   Success: ${result.success}');
      print('   Message: ${result.message}');

      if (!mounted) {
        print('⚠️ Widget not mounted after payment response');
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      if (result.success) {
        print('✅ Payment successful - creating booking');
        // Payment successful - create booking
        // Extract transaction ID from message or use timestamp
        final transactionId = result.message.isNotEmpty
            ? result.message
            : DateTime.now().millisecondsSinceEpoch.toString();
        await _handlePaymentSuccess(result.message, transactionId);
      } else {
        print('❌ Payment failed or cancelled');
        // Payment cancelled or failed
        _showError(
          result.message.isNotEmpty
              ? result.message
              : 'Payment was cancelled or failed',
        );
      }
    } on PlatformException catch (e) {
      print('❌❌❌ PLATFORM EXCEPTION CAUGHT ❌❌❌');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.details}');
      print('   toString: ${e.toString()}');

      if (!mounted) {
        print('⚠️ Widget not mounted, cannot show error');
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      String errorMessage = 'Payment error occurred';
      if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.code.isNotEmpty) {
        errorMessage = 'Payment error: ${e.code}';
      } else {
        errorMessage = 'Payment error: ${e.toString()}';
      }

      print('   Showing error to user: $errorMessage');
      _showError(errorMessage);
    } catch (e, stackTrace) {
      print('❌❌❌ GENERAL EXCEPTION CAUGHT ❌❌❌');
      print('   Error: $e');
      print('   Error type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');

      if (!mounted) {
        print('⚠️ Widget not mounted, cannot show error');
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      print('   Showing error to user: ${e.toString()}');
      _showError('Payment error: ${e.toString()}');
    }
  }

  Future<void> _handlePaymentSuccess(
    String transactionMessage,
    String cartId,
  ) async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isProcessing = true;
    });

    // Create booking with transaction ID
    final bookingResponse = await paymentProvider.createBooking(
      bookingData: widget.arguments!.bookingData,
      paymentTransactionId: cartId,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (bookingResponse['success'] == true) {
      _showSuccess('Payment successful! Booking confirmed.');
      // Navigate to home screen
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.customerHome, (route) => false);
        }
      });
    } else {
      _showError(
        bookingResponse['message']?.toString() ?? 'Failed to create booking',
      );
    }
  }

  void _showError(String message) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Payment Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to summary
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF00D4AA),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ PaymentScreen build called');

    if (widget.arguments == null) {
      print('❌ Payment arguments are null in build');
      return _buildErrorScreen('Invalid payment data');
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    print('   Platform: ${isIOS ? "iOS" : "Android"}');
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _buildIOSHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'PAYMENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF04CDFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'PAYMENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    print('🏗️ _buildContent called, _isProcessing: $_isProcessing');

    if (_isProcessing) {
      print('   Showing loading indicator');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF04CDFE)),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? '.SF Pro Text'
                    : 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            // Debug button to manually trigger payment
            if (kDebugMode)
              ElevatedButton(
                onPressed: () {
                  print('🔘 Manual payment trigger button pressed');
                  final paymentProvider = Provider.of<PaymentProvider>(
                    context,
                    listen: false,
                  );
                  if (paymentProvider.tokenUrl != null &&
                      paymentProvider.orderUrl != null) {
                    _processPayment(paymentProvider);
                  } else {
                    _initializePayment();
                  }
                },
                child: const Text('Retry Payment (Debug)'),
              ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoIcons.creditcard
                  : Icons.credit_card,
              size: 80,
              color: const Color(0xFF04CDFE),
            ),
            const SizedBox(height: 24),
            Text(
              'Total Amount',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? '.SF Pro Text'
                    : 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.arguments!.amount.toStringAsFixed(0)} ${widget.arguments!.currency}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? '.SF Pro Text'
                    : 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

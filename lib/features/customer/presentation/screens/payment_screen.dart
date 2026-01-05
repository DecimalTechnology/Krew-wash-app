import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:telr_mobile_payment_sdk/telr_mobile_payment_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/network_error_dialog.dart';
import '../../../../core/utils/network_error_utils.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../providers/payment_provider.dart';
import '../providers/package_provider.dart';

class PaymentScreenArguments {
  const PaymentScreenArguments({
    required this.amount,
    required this.currency,
    required this.bookingData,
    this.package,
    required this.selectedAddOns,
    required this.selectedDates,
    required this.selectedVehicle,
  });

  final double amount;
  final String currency;
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic>? package;
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

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  bool _isProcessing = false;
  String _statusMessage = 'Initializing payment...';
  bool _initInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      // Delay accessing Provider until after the widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializePayment();
        }
      });
    } catch (e) {
      // Error handling - initialization failed
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // If payment is still processing when screen is disposed, cancel it
    if (_isProcessing) {
      _handleAppCloseDuringPayment();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If app goes to background or is closed while payment is processing, cancel it
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        _isProcessing) {
      _handleAppCloseDuringPayment();
    }
  }

  Future<void> _handleAppCloseDuringPayment() async {
    if (!_isProcessing) return; // Already handled or not processing

    try {
      // Use a try-catch to safely access context/provider
      PaymentProvider? paymentProvider;
      String? reference;

      if (mounted) {
        try {
          paymentProvider = Provider.of<PaymentProvider>(
            context,
            listen: false,
          );
          reference = paymentProvider.reference;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [PaymentScreen] Could not access PaymentProvider: $e');
          }
        }
      }

      // If we have a reference, call cancel API
      if (reference != null &&
          reference.isNotEmpty &&
          paymentProvider != null) {
        try {
          if (kDebugMode) {
            print(
              '🔄 [PaymentScreen] App closed during payment - calling cancelPayment API',
            );
            print('   reference: $reference');
          }

          // Call cancel API with CANCELLED status
          await paymentProvider.cancelPayment(
            orderRef: reference,
            status: 'CANCELLED',
          );

          if (kDebugMode) {
            print(
              '✅ [PaymentScreen] cancelPayment API called successfully (app closed)',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [PaymentScreen] Error calling cancelPayment API: $e');
          }
        }
      }

      // Clear pending booking from local storage (always try this)
      try {
        await SecureStorageService.clearPendingBooking();
        if (kDebugMode) {
          print(
            '✅ [PaymentScreen] Cleared pending booking from local storage (app closed)',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [PaymentScreen] Error handling app close during payment: $e');
      }
    }
  }

  Future<void> _initializePayment() async {
    if (widget.arguments == null) {
      if (mounted) {
        _showError('Invalid payment data');
      }
      return;
    }

    if (_initInProgress) {
      if (kDebugMode) {
        print(
          '⛔ [PaymentScreen] _initializePayment already running, skipping duplicate call',
        );
      }
      return;
    }
    _initInProgress = true;

    // LOG SELECTED VEHICLE DETAILS IN PAYMENT SCREEN
    print('═══════════════════════════════════════════════════════════');
    print('🚗 [PaymentScreen] SELECTED VEHICLE DETAILS');
    print('═══════════════════════════════════════════════════════════');
    final selectedVehicle = widget.arguments!.selectedVehicle;
    print('📦 Full vehicle object: $selectedVehicle');
    print('📦 Vehicle keys: ${selectedVehicle.keys.toList()}');
    print('📦 Vehicle _id: ${selectedVehicle['_id']}');
    print('📦 Vehicle id: ${selectedVehicle['id']}');
    print('📦 Vehicle vehicleId: ${selectedVehicle['vehicleId']}');
    print('📦 Vehicle vehicle_id: ${selectedVehicle['vehicle_id']}');
    print('📦 Vehicle userId: ${selectedVehicle['userId']}');
    print('📦 Vehicle type: ${selectedVehicle['type']}');
    print('📦 Vehicle vehicleModel: ${selectedVehicle['vehicleModel']}');
    print('📦 Vehicle vehicleNumber: ${selectedVehicle['vehicleNumber']}');
    print('📦 All vehicle values: ${selectedVehicle.values.toList()}');
    print('═══════════════════════════════════════════════════════════');

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Connecting to payment gateway...';
    });

    try {
      setState(() {
        _statusMessage = 'Requesting payment session...';
      });

      // Step 1: Create booking first
      final packageId = widget.arguments!.package != null
          ? (widget.arguments!.package!['_id']?.toString() ??
                widget.arguments!.package!['id']?.toString())
          : null;
      // Extract vehicle ID - prioritize _id field (MongoDB standard)
      String? vehicleId;

      // First, try _id (MongoDB standard field)
      final mongoId = widget.arguments!.selectedVehicle['_id'];
      print('🔍 [PaymentScreen] Extracting vehicle ID...');
      print('   📦 mongoId (_id field): $mongoId');
      print('   📦 mongoId type: ${mongoId.runtimeType}');

      if (mongoId != null) {
        vehicleId = mongoId.toString().trim();
        print('   ✅ Using _id field: $vehicleId');
      } else {
        // Fallback to other possible field names
        print('   ⚠️ _id is null, trying fallback fields...');
        final idField = widget.arguments!.selectedVehicle['id'];
        final vehicleIdField = widget.arguments!.selectedVehicle['vehicleId'];
        final vehicle_idField = widget.arguments!.selectedVehicle['vehicle_id'];
        print('   📦 id field: $idField');
        print('   📦 vehicleId field: $vehicleIdField');
        print('   📦 vehicle_id field: $vehicle_idField');

        vehicleId =
            idField?.toString().trim() ??
            vehicleIdField?.toString().trim() ??
            vehicle_idField?.toString().trim();
        print('   ✅ Using fallback: $vehicleId');
      }

      // Extract VEHICLE TYPE ID - check multiple possible fields
      String? vehicleTypeId;
      print('🔍 [PaymentScreen] Extracting VEHICLE TYPE ID...');

      // Check all possible fields that might contain the type ID
      final typeIdField = widget.arguments!.selectedVehicle['typeId'];
      final vehicleTypeIdField =
          widget.arguments!.selectedVehicle['vehicleTypeId'];
      final vehicle_type_idField =
          widget.arguments!.selectedVehicle['vehicle_type_id'];
      final typeField = widget.arguments!.selectedVehicle['type'];

      print('   📦 typeId field: $typeIdField');
      print('   📦 vehicleTypeId field: $vehicleTypeIdField');
      print('   📦 type field: $typeField');
      print('   📦 type field type: ${typeField.runtimeType}');

      // Check if type field is an object with _id
      String? typeIdFromObject;
      if (typeField is Map) {
        typeIdFromObject =
            typeField['_id']?.toString() ?? typeField['id']?.toString();
        print('   📦 type field is Map, extracting _id: $typeIdFromObject');
      }

      // Prioritize ID fields first
      if (typeIdField != null && typeIdField.toString().trim().isNotEmpty) {
        vehicleTypeId = typeIdField.toString().trim();
        print('   ✅ Using typeId field: $vehicleTypeId');
      } else if (vehicleTypeIdField != null &&
          vehicleTypeIdField.toString().trim().isNotEmpty) {
        vehicleTypeId = vehicleTypeIdField.toString().trim();
        print('   ✅ Using vehicleTypeId field: $vehicleTypeId');
      } else if (vehicle_type_idField != null &&
          vehicle_type_idField.toString().trim().isNotEmpty) {
        vehicleTypeId = vehicle_type_idField.toString().trim();
        print('   ✅ Using vehicle_type_id field: $vehicleTypeId');
      } else if (typeIdFromObject != null &&
          typeIdFromObject.trim().isNotEmpty) {
        vehicleTypeId = typeIdFromObject.trim();
        print('   ✅ Using type._id from object: $vehicleTypeId');
      } else if (typeField != null) {
        // Check if type field looks like an ID (24 hex characters) or a name
        final typeValue = typeField.toString().trim();
        final isLikelyId =
            typeValue.length == 24 &&
            RegExp(r'^[a-f0-9]{24}$', caseSensitive: false).hasMatch(typeValue);

        if (isLikelyId) {
          vehicleTypeId = typeValue;
          print('   ✅ Using type field (appears to be ID): $vehicleTypeId');
        } else {
          // Type field contains a name, need to look up the ID from vehicle types
          print(
            '   ⚠️ type field appears to be a name, not an ID: "$typeValue"',
          );
          print('   🔍 Looking up vehicle type ID from vehicle types list...');

          try {
            final packageProvider = Provider.of<PackageProvider>(
              context,
              listen: false,
            );

            // Ensure vehicle types are loaded
            if (packageProvider.vehicleTypes.isEmpty) {
              print('   ⚠️ Vehicle types list is empty, loading...');
              await packageProvider.loadVehicleTypes();
            }

            // Find matching vehicle type by name
            final matchingType = packageProvider.vehicleTypes.firstWhere(
              (type) =>
                  type['name']?.toString().toLowerCase().trim() ==
                  typeValue.toLowerCase().trim(),
              orElse: () => <String, String>{},
            );

            if (matchingType.isNotEmpty && matchingType['id'] != null) {
              vehicleTypeId = matchingType['id']!.toString().trim();
              print(
                '   ✅ Found vehicle type ID: "$vehicleTypeId" for name "$typeValue"',
              );
            } else {
              print(
                '   ❌ Could not find vehicle type ID for name "$typeValue"',
              );
              print(
                '   📦 Available vehicle types: ${packageProvider.vehicleTypes}',
              );
              vehicleTypeId = null;
            }
          } catch (e) {
            print('   ❌ Error looking up vehicle type ID: $e');
            vehicleTypeId = null;
          }
        }
      } else {
        print('   ❌ No vehicle type ID field found');
        vehicleTypeId = null;
      }

      print('═══════════════════════════════════════════════════════════');
      print('🔍 [PaymentScreen] FINAL EXTRACTED VALUES');
      print('═══════════════════════════════════════════════════════════');
      print('📦 vehicleId: "$vehicleId"');
      print('   📦 vehicleId type: ${vehicleId.runtimeType}');
      print('   📦 vehicleId length: ${vehicleId?.length ?? 0}');
      print('   📦 vehicleId isEmpty: ${vehicleId?.isEmpty ?? true}');
      print('📦 vehicleTypeId: "$vehicleTypeId"');
      print('   📦 vehicleTypeId type: ${vehicleTypeId.runtimeType}');
      print('   📦 vehicleTypeId length: ${vehicleTypeId?.length ?? 0}');
      print('   📦 vehicleTypeId isEmpty: ${vehicleTypeId?.isEmpty ?? true}');
      print(
        '   📦 Original vehicle _id: ${widget.arguments!.selectedVehicle['_id']}',
      );
      print(
        '   📦 Original vehicle type: ${widget.arguments!.selectedVehicle['type']}',
      );
      print('═══════════════════════════════════════════════════════════');

      // Ensure we have both IDs (not empty, not null)
      if (vehicleId == null || vehicleId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Error: Vehicle ID not found';
        });
        _showErrorWithRetry('Vehicle ID not found. Please try again.');
        return;
      }

      if (vehicleTypeId == null || vehicleTypeId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Error: Vehicle Type ID not found';
        });
        _showErrorWithRetry('Vehicle Type ID not found. Please try again.');
        return;
      }

      // Validate IDs format (should be MongoDB ObjectId format - 24 hex characters)
      if (vehicleId.length != 24 ||
          !RegExp(
            r'^[a-f0-9]{24}$',
            caseSensitive: false,
          ).hasMatch(vehicleId)) {
        // Vehicle ID format validation - continue anyway
      }

      if (vehicleTypeId.length != 24 ||
          !RegExp(
            r'^[a-f0-9]{24}$',
            caseSensitive: false,
          ).hasMatch(vehicleTypeId)) {
        print(
          '   ⚠️ Vehicle Type ID format validation failed, but continuing...',
        );
      }

      // Validate vehicle ID format (should be MongoDB ObjectId format - 24 hex characters)
      if (vehicleId.length != 24 ||
          !RegExp(
            r'^[a-f0-9]{24}$',
            caseSensitive: false,
          ).hasMatch(vehicleId)) {
        // Vehicle ID format validation - continue anyway
      }

      // Validate vehicle type ID format
      if (vehicleTypeId.length != 24 ||
          !RegExp(
            r'^[a-f0-9]{24}$',
            caseSensitive: false,
          ).hasMatch(vehicleTypeId)) {
        print(
          '   ⚠️ Vehicle Type ID format validation failed, but continuing...',
        );
      }

      // Allow packageId to be null if add-ons are present
      final hasAddOns = widget.arguments!.selectedAddOns.isNotEmpty;
      if ((packageId == null && !hasAddOns) ||
          vehicleId.isEmpty ||
          vehicleTypeId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Error: Missing booking information';
        });
        _showErrorWithRetry('Missing booking information. Please try again.');
        return;
      }

      // Prepare addons with dates
      print('═══════════════════════════════════════════════════════════');
      print('📦 [PaymentScreen] PREPARING ADDONS');
      print('═══════════════════════════════════════════════════════════');
      print(
        '📦 selectedAddOns count: ${widget.arguments!.selectedAddOns.length}',
      );
      for (int i = 0; i < widget.arguments!.selectedAddOns.length; i++) {
        final addOn = widget.arguments!.selectedAddOns[i];
        print('   📦 AddOn $i (before processing):');
        print('      Keys: ${addOn.keys.toList()}');
        print('      Values: ${addOn.values.toList()}');
        // Check if addon contains vehicleId
        if (addOn.containsKey('vehicleId') || addOn.containsKey('vehicle_id')) {
          print('      ⚠️⚠️⚠️ CRITICAL: AddOn $i contains vehicleId field!');
          print(
            '         vehicleId value: ${addOn['vehicleId'] ?? addOn['vehicle_id']}',
          );
        }
      }
      print('═══════════════════════════════════════════════════════════');

      final addons = widget.arguments!.selectedAddOns.map((addOn) {
        final addonId = addOn['_id']?.toString() ?? addOn['id']?.toString();
        // Convert DateTime objects to day numbers (day of month: 1-31)
        final dates = widget.arguments!.selectedDates
            .map((date) => date.day)
            .toList();
        final addonMap = {'addonId': addonId, 'dates': dates};

        // Log each addon after processing
        print('   📦 Processed addon: $addonMap');
        print('      Keys: ${addonMap.keys.toList()}');
        print('      addonId: ${addonMap['addonId']}');
        print('      dates: ${addonMap['dates']}');

        return addonMap;
      }).toList();

      print('═══════════════════════════════════════════════════════════');
      print('📦 [PaymentScreen] ADDONS PREPARED');
      print('═══════════════════════════════════════════════════════════');
      print('📦 Final addons count: ${addons.length}');
      for (int i = 0; i < addons.length; i++) {
        print('   📦 Final Addon $i: ${addons[i]}');
        if (addons[i].containsKey('vehicleId') ||
            addons[i].containsKey('vehicle_id')) {
          print('   ⚠️⚠️⚠️ CRITICAL: Final Addon $i contains vehicleId field!');
        }
      }
      print('═══════════════════════════════════════════════════════════');

      if (vehicleId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Error: Vehicle ID is missing';
        });
        _showErrorWithRetry('Vehicle ID is missing. Please try again.');
        return;
      }

      // If we already created a booking for this exact selection, reuse it (retry).
      final addonsSignaturePart = addons
          .map((a) {
            final addonId = a['addonId']?.toString() ?? '';
            final dates = (a['dates'] as List?)?.join(',') ?? '';
            return '$addonId:$dates';
          })
          .join('|');
      final pendingSignature =
          '${packageId ?? ''}::$vehicleId::$vehicleTypeId::$addonsSignaturePart';

      String? bookingIdToUse;
      final pendingBooking = await SecureStorageService.getPendingBooking();
      if (pendingBooking != null &&
          pendingBooking['signature']?.toString() == pendingSignature) {
        final storedBookingId = pendingBooking['bookingId']?.toString() ?? '';
        if (storedBookingId.isNotEmpty) {
          bookingIdToUse = storedBookingId;
          if (kDebugMode) {
            print(
              '✅ [PaymentScreen] Reusing pending bookingId from local storage: $bookingIdToUse',
            );
          }
        }
      }

      Map<String, dynamic> bookingResponse = {'success': true};
      // Call create booking ONLY if we don't have a bookingId stored for this flow
      if (bookingIdToUse == null || bookingIdToUse.isEmpty) {
        // LOG BEFORE CALLING PROVIDER (ONLY WHEN ACTUALLY CALLING API)
        print('═══════════════════════════════════════════════════════════');
        print('📞 [PaymentScreen] ABOUT TO CALL createBookingBeforePayment');
        print('═══════════════════════════════════════════════════════════');
        print('📦 packageId: "$packageId"');
        print('📦 vehicleId: "$vehicleId"');
        print('📦 vehicleId type: ${vehicleId.runtimeType}');
        print('📦 vehicleId length: ${vehicleId.length}');
        print('📦 vehicleTypeId: "$vehicleTypeId"');
        print('📦 vehicleTypeId type: ${vehicleTypeId.runtimeType}');
        print('📦 vehicleTypeId length: ${vehicleTypeId.length}');
        print('📦 addons count: ${addons.length}');
        for (int i = 0; i < addons.length; i++) {
          print('   📦 Addon $i: ${addons[i]}');
          print('   📦 Addon $i keys: ${addons[i].keys.toList()}');
          // Check if addon contains vehicleId or vehicleTypeId
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

        bookingResponse = await paymentProvider.createBookingBeforePayment(
          packageId: packageId,
          vehicleId: vehicleId,
          vehicleTypeId: vehicleTypeId,
          addons: addons,
        );
      } else {
        // LOG SKIP (USING LOCAL BOOKING ID)
        print('═══════════════════════════════════════════════════════════');
        print(
          '✅ [PaymentScreen] SKIPPING createBookingBeforePayment (using stored bookingId: $bookingIdToUse)',
        );
        print('═══════════════════════════════════════════════════════════');
      }

      // LOG AFTER (ONLY MEANINGFUL VALUES)
      print('═══════════════════════════════════════════════════════════');
      print('📥 [PaymentScreen] BOOKING STEP RESULT');
      print('═══════════════════════════════════════════════════════════');
      print('📦 bookingIdToUse (stored): $bookingIdToUse');
      print('📦 bookingResponse success: ${bookingResponse['success']}');
      print('📦 bookingResponse bookingId: ${bookingResponse['bookingId']}');
      print('═══════════════════════════════════════════════════════════');

      if (bookingResponse['success'] != true) {
        setState(() {
          _isProcessing = false;
        });
        if (bookingResponse['isNetworkError'] == true) {
          NetworkErrorDialog.show(context);
        } else {
          _showErrorWithRetry(
            bookingResponse['message']?.toString() ??
                'Failed to create booking. Please try again.',
          );
        }
        return;
      }

      final bookingId =
          bookingIdToUse ?? bookingResponse['bookingId']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorWithRetry('Booking ID not found. Please try again.');
        return;
      }

      // Persist booking id locally for retry until booking is completed/cancelled
      if (bookingIdToUse == null || bookingIdToUse.isEmpty) {
        await SecureStorageService.savePendingBooking(
          bookingId: bookingId,
          signature: pendingSignature,
        );
      }

      // Step 2: Initialize payment with bookingId
      final response = await paymentProvider.initializePayment(
        amount: widget.arguments!.amount,
        currency: widget.arguments!.currency,
        bookingId: bookingId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      if (response['success'] == true &&
          ((paymentProvider.tokenUrl != null &&
                  paymentProvider.orderUrl != null) ||
              paymentProvider.paymentUrl != null)) {
        setState(() {
          _statusMessage = 'Opening payment gateway...';
        });
        // Proceed with payment (SDK or WebView)
        await _processPayment(paymentProvider);
      } else {
        // Check for network errors
        if (response['isNetworkError'] == true) {
          if (mounted) {
            NetworkErrorDialog.show(context);
          }
          return;
        }

        String errorMsg =
            response['message']?.toString() ?? 'Failed to initialize payment';

        // Check if it's a 404 or API not found error
        if (errorMsg.contains('404') ||
            errorMsg.contains('not found') ||
            errorMsg.contains('Route not found')) {
          errorMsg =
              'Payment service is currently unavailable. '
              'Please try again later or contact support if the issue persists.';
        }

        _showErrorWithRetry(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Check if it's a network error
        if (NetworkErrorUtils.isNetworkError(e)) {
          NetworkErrorDialog.show(context);
        } else {
          _showErrorWithRetry(
            'Failed to initialize payment. Please check your connection and try again.',
          );
        }
      }
    } finally {
      _initInProgress = false;
    }
  }

  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    // Check if we have paymentUrl (web-based flow) or tokenUrl/orderUrl (SDK flow)
    if (paymentProvider.paymentUrl != null) {
      await _processPaymentWithWebView(paymentProvider);
      return;
    }

    if (paymentProvider.tokenUrl == null || paymentProvider.orderUrl == null) {
      if (mounted) {
        _showErrorWithRetry(
          'Payment initialization failed. Missing payment URLs.',
        );
      }
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Loading payment gateway...';
      });

      // Call Telr SDK with tokenURL and orderURL
      final stopwatch = Stopwatch()..start();
      final result = await TelrSdk.presentPayment(
        paymentProvider.tokenUrl!,
        paymentProvider.orderUrl!,
      );
      stopwatch.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      if (result.success) {
        // Payment successful - create booking
        // Use reference from payment initialization, or fallback to transaction message
        final paymentProvider = Provider.of<PaymentProvider>(
          context,
          listen: false,
        );
        final reference = paymentProvider.reference;
        final transactionId =
            reference ??
            (result.message.isNotEmpty
                ? result.message
                : DateTime.now().millisecondsSinceEpoch.toString());
        await _handlePaymentSuccess(result.message, transactionId);
      } else {
        // Payment cancelled or failed
        final errorMessage = result.message.isNotEmpty
            ? result.message
            : 'Payment was cancelled or failed. Please try again.';

        // Clear pending booking from local storage
        try {
          await SecureStorageService.clearPendingBooking();
          if (kDebugMode) {
            print(
              '✅ [PaymentScreen] Cleared pending booking from local storage (payment cancelled/failed)',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
          }
        }

        if (_isCancelMessage(errorMessage)) {
          _showPaymentCancelledDialog();
        } else {
          _showPaymentFailedDialog();
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) {
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

      _showErrorWithRetry(errorMessage);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showErrorWithRetry('Payment error occurred. Please try again.');
    }
  }

  Future<void> _processPaymentWithWebView(
    PaymentProvider paymentProvider,
  ) async {
    if (paymentProvider.paymentUrl == null) {
      if (mounted) {
        _showErrorWithRetry('Payment URL is missing.');
      }
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Loading payment gateway...';
      });

      // Show WebView in a modal screen
      final referenceFromInit = paymentProvider.reference;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _PaymentWebViewScreen(
            paymentUrl: paymentProvider.paymentUrl!,
            reference: paymentProvider.reference,
            onPaymentComplete: (success, message) async {
              // Always check payment status after WebView closes.
              // Even if user declines/cancels, backend may still mark it paid/failed,
              // so we verify using payments/status.
              final referenceForStatus =
                  referenceFromInit ??
                  paymentProvider.reference ??
                  DateTime.now().millisecondsSinceEpoch.toString();

              final resolvedMessage =
                  message ??
                  (success
                      ? 'Payment completed successfully'
                      : 'Payment cancelled by user');
              final cancelled = !success && _isCancelMessage(resolvedMessage);
              final failed = !success && !cancelled;

              await _handlePaymentSuccess(
                resolvedMessage,
                referenceForStatus,
                initialCancelled: cancelled,
                initialFailed: failed,
              );
            },
          ),
        ),
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showErrorWithRetry('Payment error occurred. Please try again.');
    }
  }

  Future<void> _handlePaymentSuccess(
    String transactionMessage,
    String cartId, {
    bool initialCancelled = false,
    bool initialFailed = false,
  }) async {
    // Booking is already created before payment via createBookingBeforePayment
    // Check payment status using reference ID
    if (!mounted) {
      return;
    }

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying payment status...';
    });

    // Get reference from payment provider
    final reference = paymentProvider.reference ?? cartId;

    if (reference.isEmpty) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorWithRetry(
        'Payment reference not found. Please contact support.',
      );
      return;
    }

    // Check payment status
    Map<String, dynamic> statusResponse = await paymentProvider
        .checkPaymentStatus(reference: reference);

    bool _isPendingPaymentResponse(Map<String, dynamic> resp) {
      final message = (resp['message'] ?? '').toString().toLowerCase();
      final statusCode = resp['statusCode'];
      // Backend commonly returns 400 + "Payment not completed" while gateway is still processing.
      return message.contains('payment not completed') ||
          message.contains('not completed') ||
          statusCode == 400;
    }

    Future<Map<String, dynamic>> _checkWithRetries({
      required String reference,
      int maxAttempts = 6,
      Duration delay = const Duration(seconds: 2),
    }) async {
      Map<String, dynamic> last = statusResponse;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        last = await paymentProvider.checkPaymentStatus(reference: reference);

        if (last['success'] == true) return last;
        if (last['isNetworkError'] == true) return last;

        // If it's not "pending", stop retrying and use the response.
        if (!_isPendingPaymentResponse(last)) return last;

        if (kDebugMode) {
          print(
            '⏳ [PaymentScreen] Payment pending. Retrying status check ($attempt/$maxAttempts) in ${delay.inSeconds}s...',
          );
        }

        if (mounted) {
          setState(() {
            _statusMessage = 'Verifying payment status...';
          });
        }

        await Future.delayed(delay);
      }

      return last;
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [PaymentScreen] Status check completed');
      print('   statusResponse: $statusResponse');
      print('   statusResponse[\'success\']: ${statusResponse['success']}');
      print(
        '   statusResponse[\'success\'] == true: ${statusResponse['success'] == true}',
      );
      print('   statusResponse type: ${statusResponse.runtimeType}');
      print('   mounted: $mounted');
      print('═══════════════════════════════════════════════════════════');
    }

    // If backend says "payment not completed" we should NOT auto-cancel.
    // Retry briefly first so Android matches iOS flow (gateway often finalizes after a delay).
    if (statusResponse['success'] != true &&
        statusResponse['isNetworkError'] != true &&
        _isPendingPaymentResponse(statusResponse)) {
      statusResponse = await _checkWithRetries(reference: reference);
    }

    // Process success API call even if widget is unmounted (backend confirmation)
    if (statusResponse['success'] == true) {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('✅✅✅ [PaymentScreen] SUCCESS BLOCK ENTERED ✅✅✅');
        print('═══════════════════════════════════════════════════════════');
      }
      if (kDebugMode) {
        print('✅ [PaymentScreen] Entering success block');
      }

      // Payment verified successfully
      final bookingStatus = statusResponse['bookingStatus']?.toString() ?? '';
      final paymentData = statusResponse['data'] as Map<String, dynamic>?;
      final paymentStatus = paymentData?['status'] as Map<String, dynamic>?;
      final statusText = paymentStatus?['text']?.toString() ?? '';

      if (kDebugMode) {
        print('📦 [PaymentScreen] Extracting payment data...');
        print('   paymentData: $paymentData');
        print('   paymentData is null: ${paymentData == null}');
        if (paymentData != null) {
          print('   paymentData[\'ref\']: ${paymentData['ref']}');
          print(
            '   paymentData[\'transaction\']: ${paymentData['transaction']}',
          );
        }
      }

      // Extract orderRef and transactionRef for success API call
      // API response structure: { "data": { "orderRef": "...", "transactionRef": "..." } }
      if (kDebugMode) {
        print('🔍 [PaymentScreen] Extracting refs...');
        print('   paymentData: $paymentData');
        print('   paymentData?[\'orderRef\']: ${paymentData?['orderRef']}');
        print(
          '   paymentData?[\'transactionRef\']: ${paymentData?['transactionRef']}',
        );
        print('   paymentData?[\'ref\']: ${paymentData?['ref']}');
        print(
          '   paymentData?[\'transaction\']: ${paymentData?['transaction']}',
        );
        print('   reference: $reference');
      }

      // Extract orderRef: check orderRef first, then ref, then use reference as fallback
      final orderRefValue = paymentData?['orderRef'];
      final refValue = paymentData?['ref'];
      final orderRef =
          (orderRefValue != null && orderRefValue.toString().trim().isNotEmpty)
          ? orderRefValue.toString().trim()
          : (refValue != null && refValue.toString().trim().isNotEmpty
                ? refValue.toString().trim()
                : reference);

      // Extract transactionRef: check transactionRef in data, then transaction.ref, then use orderRef/reference as fallback
      final transactionData =
          paymentData?['transaction'] as Map<String, dynamic>?;
      final transactionRefValue =
          paymentData?['transactionRef'] ?? transactionData?['ref'];
      final transactionRef =
          (transactionRefValue != null &&
              transactionRefValue.toString().trim().isNotEmpty)
          ? transactionRefValue.toString().trim()
          : (orderRef.isNotEmpty ? orderRef : reference);

      // Determine if payment is actually verified/paid
      bool isVerified =
          statusText.toLowerCase() == 'paid' ||
          bookingStatus.toUpperCase() == 'CONFIRMED';

      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('✅ [PaymentScreen] Payment Status Check Success');
        print('═══════════════════════════════════════════════════════════');
        print('📦 orderRef extracted: $orderRef');
        print('📦 transactionRef extracted: $transactionRef');
        print('📦 orderRef isEmpty: ${orderRef.isEmpty}');
        print('📦 transactionRef isEmpty: ${transactionRef.isEmpty}');
        print('📦 transactionData: $transactionData');
        if (transactionData != null) {
          print('   transactionData[\'ref\']: ${transactionData['ref']}');
        }
        print('═══════════════════════════════════════════════════════════');
      }

      // If status API succeeded but payment is NOT verified/paid,
      // retry briefly (do NOT auto-cancel; let user decide).
      if (!isVerified && _isPendingPaymentResponse(statusResponse)) {
        statusResponse = await _checkWithRetries(reference: reference);

        final bookingStatus2 =
            statusResponse['bookingStatus']?.toString() ?? '';
        final paymentData2 = statusResponse['data'] as Map<String, dynamic>?;
        final paymentStatus2 = paymentData2?['status'] as Map<String, dynamic>?;
        final statusText2 = paymentStatus2?['text']?.toString() ?? '';

        isVerified =
            statusText2.toLowerCase() == 'paid' ||
            bookingStatus2.toUpperCase() == 'CONFIRMED';
      }

      // Call payments/success API only if verified and we have both refs
      if (isVerified && orderRef.isNotEmpty && transactionRef.isNotEmpty) {
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════════');
          print('🔄 [PaymentScreen] CALLING confirmPaymentSuccess API NOW...');
          print('   orderRef: $orderRef');
          print('   transactionRef: $transactionRef');
          print('═══════════════════════════════════════════════════════════');
        }

        try {
          final successResponse = await paymentProvider.confirmPaymentSuccess(
            orderRef: orderRef,
            transactionRef: transactionRef,
          );

          if (kDebugMode) {
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print(
              '✅ [PaymentScreen] confirmPaymentSuccess API Response Received',
            );
            print('   success: ${successResponse['success']}');
            print('   message: ${successResponse['message']}');
            print('   full response: $successResponse');
            print(
              '═══════════════════════════════════════════════════════════',
            );
          }

          // Check if the API call was successful
          if (successResponse['success'] != true) {
            if (kDebugMode) {
              print(
                '⚠️ [PaymentScreen] confirmPaymentSuccess returned success=false',
              );
              print('   Error: ${successResponse['message']}');
            }
          } else {
            if (kDebugMode) {
              print(
                '✅✅✅ [PaymentScreen] payments/success API CALLED SUCCESSFULLY ✅✅✅',
              );
            }
          }
        } catch (e, stackTrace) {
          // Log error but don't block the flow since payment is already verified
          if (kDebugMode) {
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('❌ [PaymentScreen] EXCEPTION in confirmPaymentSuccess');
            print('   Error: $e');
            print('   Stack trace: $stackTrace');
            print(
              '═══════════════════════════════════════════════════════════',
            );
          }
        }
      } else {
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════════');
          print(
            '⚠️ [PaymentScreen] SKIPPING confirmPaymentSuccess - MISSING REFS',
          );
          print('   orderRef.isEmpty: ${orderRef.isEmpty}');
          print('   transactionRef.isEmpty: ${transactionRef.isEmpty}');
          print('   orderRef: "$orderRef"');
          print('   transactionRef: "$transactionRef"');
          print('═══════════════════════════════════════════════════════════');
        }
      }

      // Clear pending booking from local storage since payment is verified and successful
      try {
        await SecureStorageService.clearPendingBooking();
        if (kDebugMode) {
          print('✅ [PaymentScreen] Cleared pending booking from local storage');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
        }
      }

      // Only update UI if widget is still mounted
      if (!mounted) {
        if (kDebugMode) {
          print(
            '⚠️ [PaymentScreen] Widget unmounted after success API call, skipping UI updates',
          );
        }
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      // Show payment status UI (keep it open until user action)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _showPaymentStatusDialog(statusResponse);
        }
      });

      // Payment successful - don't auto-navigate, let user click button
      // Removed automatic navigation - user will click button in dialog
    } else {
      // Payment status check failed
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print(
          '❌ [PaymentScreen] Payment Status Check Faileddddddddddddddddddddddddddddddddddddddddddddddddddddd',
        );
        print('═══════════════════════════════════════════════════════════');
        print('📦 statusResponse: $statusResponse');
        print('📦 success: ${statusResponse['success']}');
        print('📦 message: ${statusResponse['message']}');
        print('📦 isNetworkError: ${statusResponse['isNetworkError']}');
        print('═══════════════════════════════════════════════════════════');
      }

      if (statusResponse['isNetworkError'] == true) {
        if (kDebugMode) {
          print(
            '⚠️ [PaymentScreen] Network error detected - showing NetworkErrorDialog',
          );
        }
        NetworkErrorDialog.show(context);
      } else {
        final rawErrorMessage =
            statusResponse['message']?.toString() ??
            'Failed to verify payment status. Please try again.';
        final errorMessage = _sanitizePaymentErrorMessage(rawErrorMessage);

        // Get status from API response
        final paymentStatus =
            statusResponse['status']?.toString().toUpperCase() ?? '';
        final bookingStatus =
            statusResponse['bookingStatus']?.toString().toUpperCase() ?? '';

        if (kDebugMode) {
          print('⚠️ [PaymentScreen] Payment verification failed');
          print('   Error message: $errorMessage');
          print('   Payment status: $paymentStatus');
          print('   Booking status: $bookingStatus');
          print('   Showing payment error dialog');
        }

        // If user cancelled, always call cancel API with CANCELLED status first
        if (initialCancelled) {
          if (reference.isNotEmpty) {
            try {
              if (kDebugMode) {
                print(
                  '🔄 [PaymentScreen] Calling cancelPayment API for user cancelled payment',
                );
                print('   reference: $reference');
              }
              await paymentProvider.cancelPayment(
                orderRef: reference,
                status: 'CANCELLED',
              );
              if (kDebugMode) {
                print(
                  '✅ [PaymentScreen] cancelPayment API called successfully with CANCELLED status',
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ [PaymentScreen] Error calling cancelPayment API: $e');
              }
              // Continue to show dialog even if cancel API fails
            }
          }

          // Clear pending booking from local storage since payment is cancelled
          try {
            await SecureStorageService.clearPendingBooking();
            if (kDebugMode) {
              print(
                '✅ [PaymentScreen] Cleared pending booking from local storage (cancelled)',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
            }
          }

          _showPaymentCancelledDialog();
          return;
        }

        // Call cancel API for failure statuses (CANCELLED, FAILED, DECLINED, REJECTED, EXPIRED)
        // Skip PENDING status as it might still complete
        // Only call if initialCancelled is false (already handled above)
        final shouldCancelPayment =
            paymentStatus.isNotEmpty &&
            paymentStatus != 'PENDING' &&
            paymentStatus != 'SUCCESS' &&
            (paymentStatus == 'CANCELLED' ||
                paymentStatus == 'FAILED' ||
                paymentStatus == 'DECLINED' ||
                paymentStatus == 'REJECTED' ||
                paymentStatus == 'EXPIRED' ||
                paymentStatus == 'UNKNOWN');

        if (shouldCancelPayment && reference.isNotEmpty) {
          // Map status to cancel API status (cancelPayment only accepts 'CANCELLED' or 'FAILED')
          final cancelApiStatus = paymentStatus == 'CANCELLED'
              ? 'CANCELLED'
              : 'FAILED';

          try {
            if (kDebugMode) {
              print(
                '🔄 [PaymentScreen] Calling cancelPayment API for status: $paymentStatus',
              );
              print('   reference: $reference');
              print('   cancelApiStatus: $cancelApiStatus');
            }
            await paymentProvider.cancelPayment(
              orderRef: reference,
              status: cancelApiStatus,
            );
            if (kDebugMode) {
              print(
                '✅ [PaymentScreen] cancelPayment API called successfully with status: $cancelApiStatus',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ [PaymentScreen] Error calling cancelPayment API: $e');
            }
            // Continue to show dialog even if cancel API fails
          }

          // Clear pending booking from local storage since payment is cancelled/failed
          try {
            await SecureStorageService.clearPendingBooking();
            if (kDebugMode) {
              print(
                '✅ [PaymentScreen] Cleared pending booking from local storage (status: $paymentStatus)',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
            }
          }
        }
        if (initialFailed) {
          // Call cancel API if not already called (paymentStatus might not match)
          if (!shouldCancelPayment && reference.isNotEmpty) {
            try {
              if (kDebugMode) {
                print(
                  '🔄 [PaymentScreen] Calling cancelPayment API for user failed payment',
                );
                print('   reference: $reference');
              }
              await paymentProvider.cancelPayment(
                orderRef: reference,
                status: 'FAILED',
              );
              if (kDebugMode) {
                print(
                  '✅ [PaymentScreen] cancelPayment API called successfully with FAILED status',
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ [PaymentScreen] Error calling cancelPayment API: $e');
              }
              // Continue to show dialog even if cancel API fails
            }
          }

          // Clear pending booking from local storage since payment failed
          try {
            await SecureStorageService.clearPendingBooking();
            if (kDebugMode) {
              print(
                '✅ [PaymentScreen] Cleared pending booking from local storage (failed)',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ [PaymentScreen] Error clearing pending booking: $e');
            }
          }

          _showPaymentFailedDialog();
          return;
        }

        // Otherwise, show the SAME status dialog UI (not verified) and wait for user action.
        final synthetic = <String, dynamic>{
          'bookingStatus': 'PENDING',
          'data': <String, dynamic>{
            'ref': reference,
            'status': <String, dynamic>{'text': 'NOT VERIFIED'},
            'transaction': <String, dynamic>{'message': errorMessage},
          },
        };

        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _showPaymentStatusDialog(synthetic);
          }
        });
      }
    }
  }

  void _showError(String message) {
    // Use iOS-style dialog on BOTH platforms (Android matches iOS).
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).maybePop(); // back to summary
            },
          ),
        ],
      ),
    );
  }

  void _showErrorWithRetry(String message) {
    // Use iOS-style dialog on BOTH platforms (Android matches iOS).
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Payment Unavailable'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Retry'),
            onPressed: () {
              Navigator.pop(dialogContext);
              _initializePayment();
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).maybePop(); // back to summary
            },
          ),
        ],
      ),
    );
  }

  bool _isCancelMessage(String? message) {
    final m = (message ?? '').toLowerCase();
    return m.contains('cancel') ||
        m.contains('cancelled') ||
        m.contains('canceled');
  }

  String _sanitizePaymentErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('404') ||
        lower.contains('not found') ||
        lower.contains('route not found')) {
      return 'Payment service is currently unavailable. Please try again later.';
    }
    return message;
  }

  void _showPaymentCancelledDialog() {
    const accent = Color(0xFF94A3B8); // slate
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.18),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.65),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAYMENT CANCELLED',
                                style: AppTheme.bebasNeue(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'You cancelled the payment.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (mounted) {
                            // Navigate to home screen
                            final rootNavigator = Navigator.of(
                              context,
                              rootNavigator: true,
                            );
                            rootNavigator.pushNamedAndRemoveUntil(
                              Routes.customerHome,
                              (route) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                          foregroundColor: AppTheme.textColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'CLOSE',
                          style: AppTheme.bebasNeue(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentFailedDialog() {
    const accent = Color(0xFFEF4444); // red
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.18),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.65),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAYMENT FAILED',
                                style: AppTheme.bebasNeue(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Payment failed. Please try again.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              if (mounted) {
                                // Navigate to home screen
                                final rootNavigator = Navigator.of(
                                  context,
                                  rootNavigator: true,
                                );
                                rootNavigator.pushNamedAndRemoveUntil(
                                  Routes.customerHome,
                                  (route) => false,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              foregroundColor: AppTheme.textColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'CLOSE',
                              style: AppTheme.bebasNeue(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _initializePayment();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'RETRY',
                              style: AppTheme.bebasNeue(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentStatusDialog(Map<String, dynamic> statusResponse) {
    final bookingStatus = statusResponse['bookingStatus']?.toString() ?? '';
    final paymentData = statusResponse['data'] as Map<String, dynamic>?;
    final paymentStatus = paymentData?['status'] as Map<String, dynamic>?;
    final transaction = paymentData?['transaction'] as Map<String, dynamic>?;
    final card = paymentData?['card'] as Map<String, dynamic>?;
    final paymethod = paymentData?['paymethod']?.toString() ?? '';

    final statusText = paymentStatus?['text']?.toString() ?? '';
    final gatewayAmountRaw = paymentData?['amount']?.toString() ?? '';
    final gatewayCurrency = paymentData?['currency']?.toString() ?? '';
    final orderRef =
        paymentData?['orderRef']?.toString() ??
        paymentData?['ref']?.toString() ??
        '';
    final transactionRef =
        transaction?['ref']?.toString() ??
        paymentData?['transactionRef']?.toString() ??
        orderRef;
    final transactionDate = transaction?['date']?.toString() ?? '';
    final transactionMessage = transaction?['message']?.toString() ?? '';
    final cardType = card?['type']?.toString() ?? '';
    final cardLast4 = card?['last4']?.toString() ?? '';

    // Preferred amount/currency should be what user selected on this screen.
    // Gateway status response may differ (or may even return another payment if ref is wrong),
    // so we show gateway amount only as a secondary field when it differs.
    final expectedAmountText =
        '${widget.arguments!.amount.toStringAsFixed(0)} ${widget.arguments!.currency}';
    final gatewayAmountText = gatewayAmountRaw.isNotEmpty
        ? '$gatewayAmountRaw ${gatewayCurrency.isNotEmpty ? gatewayCurrency : widget.arguments!.currency}'
        : '';
    final showGatewayAmount =
        gatewayAmountText.isNotEmpty && gatewayAmountText != expectedAmountText;

    final isSuccess =
        statusText.toLowerCase() == 'paid' ||
        bookingStatus.toUpperCase() == 'CONFIRMED';

    final accent = isSuccess
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return PopScope(
          canPop:
              false, // prevent Android back button from closing automatically
          onPopInvoked: (didPop) {
            if (!didPop && mounted) {
              // Navigate to home screen when back button is pressed
              Navigator.of(dialogContext).pop();
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              rootNavigator.pushNamedAndRemoveUntil(
                Routes.customerHome,
                (route) => false,
              );
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: 0.28),
                            AppTheme.cardColor,
                          ],
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withValues(alpha: 0.18),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.65),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              isSuccess
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSuccess
                                      ? 'PAYMENT VERIFIED'
                                      : 'PAYMENT NOT VERIFIED',
                                  style: AppTheme.bebasNeue(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSuccess
                                      ? 'Your payment has been confirmed.'
                                      : 'We could not confirm this payment.',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...[
                            Row(
                              children: [
                                Text(
                                  'AMOUNT',
                                  style: AppTheme.bebasNeue(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.4,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  expectedAmountText,
                                  style: AppTheme.bebasNeue(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (showGatewayAmount) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Gateway Amount: $gatewayAmountText',
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                statusText.isNotEmpty ? statusText : 'STATUS',
                                style: AppTheme.bebasNeue(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (bookingStatus.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Booking',
                                    value: bookingStatus,
                                  ),
                                if (bookingStatus.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (paymethod.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Method',
                                    value: paymethod,
                                  ),
                                if (paymethod.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (cardType.isNotEmpty && cardLast4.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Card',
                                    value: '$cardType •••• $cardLast4',
                                  ),
                                if (cardType.isNotEmpty && cardLast4.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (orderRef.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Order Ref',
                                    value: orderRef,
                                    isMono: true,
                                  ),
                                if (orderRef.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (transactionRef.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Txn Ref',
                                    value: transactionRef,
                                    isMono: true,
                                  ),
                                if (transactionRef.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (transactionDate.isNotEmpty)
                                  _paymentInfoRow(
                                    label: 'Date',
                                    value: transactionDate,
                                  ),
                                if (transactionMessage.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _paymentInfoRow(
                                    label: 'Message',
                                    value: transactionMessage,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    if (mounted) {
                                      // Navigate to home screen
                                      final rootNavigator = Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      );
                                      rootNavigator.pushNamedAndRemoveUntil(
                                        Routes.customerHome,
                                        (route) => false,
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.20,
                                      ),
                                    ),
                                    foregroundColor: AppTheme.textColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'CLOSE',
                                    style: AppTheme.bebasNeue(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    if (mounted) {
                                      // Navigate to my bookings page (tab index 3)
                                      final rootNavigator = Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      );
                                      rootNavigator.pushNamedAndRemoveUntil(
                                        Routes.customerHome,
                                        (route) => false,
                                        arguments:
                                            3, // Bookings tab index - shows MyBookingsScreen
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'VIEW BOOKINGS',
                                    style: AppTheme.bebasNeue(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  void _showPaymentErrorDialog(String errorMessage) {
    const accent = Color(0xFFF59E0B); // amber
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.25),
                          AppTheme.cardColor,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.18),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.65),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAYMENT STATUS',
                                style: AppTheme.bebasNeue(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'We couldn’t verify the payment status.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 14,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  if (mounted) {
                                    // Navigate to home screen
                                    final rootNavigator = Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    );
                                    rootNavigator.pushNamedAndRemoveUntil(
                                      Routes.customerHome,
                                      (route) => false,
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.20),
                                  ),
                                  foregroundColor: AppTheme.textColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'CLOSE',
                                  style: AppTheme.bebasNeue(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  if (mounted) {
                                    // Navigate to my bookings page (tab index 3)
                                    final rootNavigator = Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    );
                                    rootNavigator.pushNamedAndRemoveUntil(
                                      Routes.customerHome,
                                      (route) => false,
                                      arguments:
                                          3, // Bookings tab index - shows MyBookingsScreen
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'VIEW BOOKINGS',
                                  style: AppTheme.bebasNeue(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _paymentInfoRow({
    required String label,
    required String value,
    bool isMono = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label.toUpperCase(),
            style: AppTheme.bebasNeue(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: SelectableText(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 13,
              height: 1.2,
              fontFamily: isMono ? 'monospace' : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arguments == null) {
      return _buildErrorScreen('Invalid payment data');
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
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
          StandardBackButton(onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              'PAYMENT',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(width: 40), // Balance back button width
        ],
      ),
    );
  }

  Widget _buildIOSHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          StandardBackButton(onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              'PAYMENT',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(width: 40), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isProcessing) {
      return _buildPaymentInitializationView();
    }

    return _buildPaymentReadyView();
  }

  int _stepIndexFromStatus(String message) {
    final m = message.toLowerCase();
    if (m.contains('connecting')) return 0;
    if (m.contains('requesting') || m.contains('booking')) return 1;
    if (m.contains('initializ') || m.contains('session')) return 2;
    if (m.contains('opening') || m.contains('loading payment gateway'))
      return 3;
    if (m.contains('verifying')) return 4;
    return 2;
  }

  Widget _buildPaymentInitializationView() {
    final step = _stepIndexFromStatus(_statusMessage);
    final accent = AppTheme.primaryColor;

    Widget stepRow({
      required int index,
      required String title,
      required IconData icon,
    }) {
      final isDone = step > index;
      final isActive = step == index;
      final color = isDone
          ? const Color(0xFF22C55E)
          : isActive
          ? accent
          : Colors.white54;

      return Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bebasNeue(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: Colors.white,
              ),
            ),
          ),
          if (isActive)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.16),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.55),
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_clock_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INITIALIZING PAYMENT',
                              style: AppTheme.bebasNeue(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _statusMessage,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: (step + 1) / 5,
                    minHeight: 7,
                    color: accent,
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 16),
                  stepRow(
                    index: 0,
                    title: 'CONNECTING',
                    icon: Icons.wifi_tethering_rounded,
                  ),
                  const SizedBox(height: 12),
                  stepRow(
                    index: 1,
                    title: 'PREPARING BOOKING',
                    icon: Icons.receipt_long_rounded,
                  ),
                  const SizedBox(height: 12),
                  stepRow(
                    index: 2,
                    title: 'CREATING PAYMENT SESSION',
                    icon: Icons.security_rounded,
                  ),
                  const SizedBox(height: 12),
                  stepRow(
                    index: 3,
                    title: 'OPENING GATEWAY',
                    icon: Icons.open_in_new_rounded,
                  ),
                  const SizedBox(height: 12),
                  stepRow(
                    index: 4,
                    title: 'VERIFYING PAYMENT',
                    icon: Icons.verified_rounded,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'CANCEL',
                            style: AppTheme.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_initInProgress) return;
                            _initializePayment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'RETRY',
                            style: AppTheme.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentReadyView() {
    final accent = AppTheme.primaryColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.16),
                      border: Border.all(color: accent.withValues(alpha: 0.55)),
                    ),
                    child: Icon(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? CupertinoIcons.creditcard
                          : Icons.credit_card,
                      size: 32,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'TOTAL AMOUNT',
                    style: AppTheme.bebasNeue(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.arguments!.amount.toStringAsFixed(0)} ${widget.arguments!.currency}',
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'BACK',
                            style: AppTheme.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _initializePayment(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'START PAYMENT',
                            style: AppTheme.bebasNeue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Intentionally no debug banner text in UI.
                ],
              ),
            ),
          ),
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

// WebView Screen for Payment URL
class _PaymentWebViewScreen extends StatefulWidget {
  const _PaymentWebViewScreen({
    required this.paymentUrl,
    this.reference,
    required this.onPaymentComplete,
  });

  final String paymentUrl;
  final String? reference;
  final Function(bool success, String? message) onPaymentComplete;

  @override
  State<_PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<_PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _completionScheduled = false;
  bool _hasCompleted = false;

  void _completeOnce(bool success, String message) {
    if (_hasCompleted) return;
    _hasCompleted = true;

    if (!mounted) return;

    widget.onPaymentComplete(success, message);

    // Close ONLY the WebView screen.
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) async {
              // Check if we can go back in history
              final canGoBack = await _controller.canGoBack();
              setState(() {
                _isLoading = true;
                _canGoBack = canGoBack;
              });

              // Check URL on navigation start as well
              _checkPaymentStatus(url);
            },
            onPageFinished: (String url) async {
              // Check if we can go back in history
              final canGoBack = await _controller.canGoBack();
              setState(() {
                _isLoading = false;
                _canGoBack = canGoBack;
              });

              // Check for success/cancel URLs
              _checkPaymentStatus(url);
            },
            onNavigationRequest: (NavigationRequest request) {
              // Allow all navigation
              return NavigationDecision.navigate;
            },
            onWebResourceError: (WebResourceError error) {
              // Don't fail on minor errors, only critical ones
              if (error.errorCode == -2 || error.errorCode == -1009) {
                // Network error
                if (mounted) {
                  widget.onPaymentComplete(
                    false,
                    'Network error: Please check your internet connection',
                  );
                  Navigator.pop(context);
                }
              } else if (error.errorCode == -1001) {
                // Timeout
                if (mounted) {
                  widget.onPaymentComplete(
                    false,
                    'Payment page timeout. Please try again.',
                  );
                  Navigator.pop(context);
                }
              }
              // Other errors might be non-critical, continue
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      // Handle platform exception (unregistered view type)
      if (e.toString().contains('unregistered_view_type') ||
          e.toString().contains('PlatformException') ||
          e.toString().contains('channel-error')) {
        // Fallback: Open payment URL in external browser
        if (mounted) {
          _openPaymentUrlInBrowser(widget.paymentUrl);
        }
        return; // Don't re-throw, we handled it
      } else {
        // Re-throw if it's a different error
        rethrow;
      }
    }
  }

  void _checkPaymentStatus(String url) {
    if (_hasCompleted || _completionScheduled) return;

    // Normalize URL for checking
    final lowerUrl = url.toLowerCase();

    // Check for Telr success patterns
    final successPatterns = [
      'success',
      'completed',
      'approved',
      'paid',
      'transaction=success',
      'status=success',
      'result=success',
      'payment=success',
      'telr.com/success',
    ];

    // Check for Telr cancel/failure patterns
    final cancelPatterns = [
      'cancel',
      'cancelled',
      'failed',
      'declined',
      'rejected',
      'error',
      'transaction=failed',
      'status=failed',
      'result=failed',
      'payment=failed',
      'telr.com/cancel',
    ];

    bool isSuccess = successPatterns.any(
      (pattern) => lowerUrl.contains(pattern),
    );
    bool isCancel = cancelPatterns.any((pattern) => lowerUrl.contains(pattern));

    // IMPORTANT:
    // Do NOT close the WebView just because Telr navigated to another Telr page (e.g. details.html).
    // Those pages can still lead to the "Accept / Cancel" (3DS) screen.
    // Only close WebView when:
    // - We detect explicit success/cancel patterns, OR
    // - We leave Telr domains (merchant callback / deep link).
    final uri = Uri.tryParse(url);
    final host = (uri?.host ?? '').toLowerCase();
    final isTelrHost = host.endsWith('telr.com');
    final leftTelr = host.isNotEmpty && !isTelrHost;

    if (isSuccess) {
      _completionScheduled = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        _completeOnce(true, 'Payment completed successfully');
      });
    } else if (isCancel) {
      _completionScheduled = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        _completeOnce(false, 'Payment was cancelled or failed');
      });
    } else if (leftTelr) {
      // Returned to merchant callback (non-telr domain). Close WebView and verify in app.
      _completionScheduled = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        _completeOnce(true, 'Payment completed successfully');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Handle system back button (Android)
        if (_canGoBack) {
          await _controller.goBack();
        } else {
          // No history, close the WebView and cancel payment
          if (mounted) {
            Navigator.pop(context);
            // Notify payment was cancelled
            Future.delayed(const Duration(milliseconds: 100), () {
              widget.onPaymentComplete(false, 'Payment cancelled by user');
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: StandardBackButton(
            onPressed: () async {
              // Try to go back in WebView history first
              if (_canGoBack) {
                await _controller.goBack();
              } else {
                // No history, close the WebView
                if (mounted) {
                  // Close the WebView screen first
                  Navigator.pop(context);
                  // Then notify payment was cancelled
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.onPaymentComplete(
                      false,
                      'Payment cancelled by user',
                    );
                  });
                }
              }
            },
          ),
          title: Text(
            'Payment',
            style: AppTheme.bebasNeue(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF04CDFE),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading payment gateway...',
                        style: AppTheme.bebasNeue(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPaymentUrlInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show a message to user
        if (mounted) {
          _showBrowserPaymentMessage();
        }
      } else {
        if (mounted) {
          widget.onPaymentComplete(
            false,
            'Cannot open payment page. Please check your internet connection.',
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        widget.onPaymentComplete(false, 'Failed to open payment page: $e');
        Navigator.pop(context);
      }
    }
  }

  void _showBrowserPaymentMessage() {
    // Use iOS-style dialog on BOTH platforms (Android matches iOS).
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Payment in Browser'),
        content: const Text(
          'Payment page opened in your browser. '
          'Please complete the payment there and return to the app.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).maybePop(); // Close WebView screen
            },
          ),
        ],
      ),
    );
  }
}

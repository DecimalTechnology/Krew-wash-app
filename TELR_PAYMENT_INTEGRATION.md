# Telr Payment Gateway Integration - Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture & Flow](#architecture--flow)
3. [Code Structure](#code-structure)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [File-by-File Breakdown](#file-by-file-breakdown)
6. [Backend Requirements](#backend-requirements)
7. [Testing Guide](#testing-guide)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This document explains how the Telr payment gateway is integrated into the Flutter car wash application. The integration uses Telr's mobile SDK to process payments securely within the app.

### Key Features
- ✅ In-app payment processing (no browser navigation)
- ✅ Full-screen Telr payment UI
- ✅ Network error handling
- ✅ Automatic booking creation after successful payment
- ✅ Support for multiple response formats from backend

### Requirements Met
- **Flutter**: ≥ 3.19 (Dart ≥ 3) ✅
- **iOS**: ≥ 15.1 ✅ (configured in `ios/Podfile`)
- **Android**: minSdk ≥ 21, targetSdk ≥ 34 ✅ (configured in `android/app/build.gradle.kts`)

---

## Architecture & Flow

### Complete Payment Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER INITIATES PAYMENT                                       │
│    Location: BookingSummaryScreen                               │
│    Action: User clicks "CONFIRM & PROCEED TO PAYMENT"           │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. NAVIGATE TO PAYMENT SCREEN                                    │
│    Navigator.pushNamed(Routes.customerPayment)                   │
│    Passes: PaymentScreenArguments (amount, currency, bookingData)│
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. PAYMENT SCREEN INITIALIZES                                    │
│    PaymentScreen.initState()                                     │
│    → Automatically calls _initializePayment()                    │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. REQUEST PAYMENT SESSION FROM BACKEND                          │
│    PaymentProvider.initializePayment()                           │
│    ↓                                                              │
│    PaymentRepository.initializePayment()                         │
│    ↓                                                              │
│    HTTP POST: /api/v1/payments/initialize                        │
│    Body: {                                                        │
│      "amount": 100.0,                                            │
│      "currency": "AED",                                          │
│      "bookingData": { ... }                                      │
│    }                                                              │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. BACKEND RESPONDS WITH PAYMENT URLs                             │
│    Response Format (Telr Standard):                              │
│    {                                                              │
│      "success": true,                                            │
│      "data": {                                                    │
│        "_links": {                                                │
│          "auth": {                                                │
│            "href": "https://secure.telr.com/.../token"           │
│          },                                                       │
│          "self": {                                                │
│            "href": "https://secure.telr.com/.../order"           │
│          }                                                        │
│        }                                                          │
│      }                                                            │
│    }                                                              │
│                                                                   │
│    Alternative Format (Direct):                                  │
│    {                                                              │
│      "success": true,                                            │
│      "data": {                                                    │
│        "tokenUrl": "https://secure.telr.com/.../token",         │
│        "orderUrl": "https://secure.telr.com/.../order"           │
│      }                                                            │
│    }                                                              │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. EXTRACT URLs FROM RESPONSE                                    │
│    PaymentProvider extracts:                                     │
│    - tokenUrl from _links.auth.href (or data.tokenUrl)          │
│    - orderUrl from _links.self.href (or data.orderUrl)           │
│    Stores in: _tokenUrl and _orderUrl                             │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. LAUNCH TELR PAYMENT UI (IN-APP)                               │
│    TelrSdk.presentPayment(tokenUrl, orderUrl)                    │
│    ↓                                                              │
│    - Opens full-screen Telr payment interface                    │
│    - User enters card details                                    │
│    - User completes payment                                      │
│    - Payment UI automatically dismisses                          │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. PAYMENT RESULT                                                │
│    PaymentResponse {                                              │
│      success: true/false,                                        │
│      message: "Transaction ID or error message"                  │
│    }                                                              │
└─────────────────────────────────────────────────────────────────┘
                          ↓
        ┌──────────────────┴──────────────────┐
        ↓                                     ↓
┌──────────────────┐              ┌──────────────────┐
│ 9a. SUCCESS      │              │ 9b. FAILED       │
│    → Create booking             │    → Show error  │
│    POST /api/v1/bookings         │    → Navigate back│
│    Body: {                       │                  │
│      ...bookingData,             │                  │
│      "payment": {                │                  │
│        "transactionId": "...",   │                  │
│        "method": "telr",          │                  │
│        "status": "completed"     │                  │
│      }                            │                  │
│    }                              │                  │
└──────────────────┘              └──────────────────┘
```

---

## Code Structure

### File Organization

```
lib/
├── main.dart                                    # SDK initialization
├── features/
│   └── customer/
│       ├── data/
│       │   └── repositories/
│       │       └── payment_repository.dart      # HTTP calls to backend
│       └── presentation/
│           ├── providers/
│           │   └── payment_provider.dart       # State management & URL extraction
│           └── screens/
│               ├── booking_summary_screen.dart  # Initiates payment
│               └── payment_screen.dart          # Payment UI & flow control
└── core/
    └── utils/
        └── network_error_dialog.dart            # Network error handling
```

---

## Step-by-Step Implementation

### Step 1: SDK Initialization (`lib/main.dart`)

```dart
import 'package:telr_mobile_payment_sdk/telr_mobile_payment_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initialization ...
  
  // Initialize Telr SDK early in app lifecycle
  try {
    await TelrSdk.init(
      preferredLanguageCode: 'en',
      debugLoggingEnabled: true,
      samsungPayServiceId: null,
      samsungPayMerchantId: null,
    );
    print('✅ Telr SDK initialized successfully');
  } catch (e) {
    print('⚠️ Telr SDK initialization failed: $e');
    // Continue anyway - SDK might initialize later
  }
  
  runApp(const MyApp());
}
```

**Why early?** The SDK needs to be initialized before any payment operations. This ensures proper setup of native components.

---

### Step 2: Payment Repository (`lib/features/customer/data/repositories/payment_repository.dart`)

This file handles all HTTP communication with your backend.

#### Initialize Payment Method

```dart
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
    return decoded;
    
  } on SocketException catch (e) {
    // Network error - no internet connection
    return {
      'success': false,
      'message': 'Network error: Please check your internet connection',
      'isNetworkError': true,
    };
  } on TimeoutException catch (e) {
    // Request timeout
    return {
      'success': false,
      'message': 'Network error: Request timeout. Please try again',
      'isNetworkError': true,
    };
  } on http.ClientException catch (e) {
    // HTTP client error
    return {
      'success': false,
      'message': 'Network error: Please check your internet connection',
      'isNetworkError': true,
    };
  } catch (e) {
    // Other errors
    return {'success': false, 'message': 'Failed to initialize payment: $e'};
  }
}
```

**What it does:**
- Sends payment initialization request to backend
- Includes amount, currency, and booking data
- Handles network errors gracefully
- Returns response with `isNetworkError` flag for proper error handling

#### Create Booking Method

```dart
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
    return decoded;
    
  } catch (e) {
    // Similar error handling as above
    return {'success': false, 'message': 'Failed to create booking: $e'};
  }
}
```

**What it does:**
- Creates booking after successful payment
- Includes payment transaction details
- Links payment to booking record

---

### Step 3: Payment Provider (`lib/features/customer/presentation/providers/payment_provider.dart`)

This file manages state and extracts URLs from backend response.

```dart
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();
  
  String? _tokenUrl;
  String? _orderUrl;
  bool _isInitializing = false;
  String? _errorMessage;

  // Getters
  String? get tokenUrl => _tokenUrl;
  String? get orderUrl => _orderUrl;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> bookingData,
  }) async {
    _isInitializing = true;
    _tokenUrl = null;
    _orderUrl = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.initializePayment(
        amount: amount,
        currency: currency,
        bookingData: bookingData,
      );

      if (response['success'] == true) {
        // Extract URLs from backend response
        Map<String, dynamic>? data = response['data'] as Map<String, dynamic>?;

        if (data != null) {
          // Try Telr format first (_links structure)
          final links = data['_links'] as Map<String, dynamic>?;
          if (links != null) {
            final auth = links['auth'] as Map<String, dynamic>?;
            final self = links['self'] as Map<String, dynamic>?;
            _tokenUrl = auth?['href'] as String?;
            _orderUrl = self?['href'] as String?;
          }

          // Fallback to direct format (tokenUrl and orderUrl)
          if (_tokenUrl == null || _orderUrl == null) {
            _tokenUrl = data['tokenUrl'] as String? ?? _tokenUrl;
            _orderUrl = data['orderUrl'] as String? ?? _orderUrl;
          }

          // If still not found, try root level
          if (_tokenUrl == null || _orderUrl == null) {
            _tokenUrl = response['tokenUrl'] as String? ?? _tokenUrl;
            _orderUrl = response['orderUrl'] as String? ?? _orderUrl;
          }
        }

        if (_tokenUrl == null || _orderUrl == null) {
          _errorMessage = 'Payment URLs not found in response. Expected tokenUrl and orderUrl from backend.';
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
        _errorMessage = response['message']?.toString() ?? 'Failed to initialize payment';
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
}
```

**Key Features:**
- **URL Extraction**: Supports multiple response formats (Telr standard `_links` format and direct format)
- **State Management**: Manages loading states and error messages
- **Error Handling**: Properly handles network errors and missing URLs

---

### Step 4: Payment Screen (`lib/features/customer/presentation/screens/payment_screen.dart`)

This is the main UI component that orchestrates the payment flow.

#### Initialization

```dart
class PaymentScreen extends StatefulWidget {
  final PaymentScreenArguments? arguments;
  // ...
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _statusMessage = 'Initializing payment...';

  @override
  void initState() {
    super.initState();
    // Automatically start payment flow when screen loads
    _initializePayment();
  }
}
```

#### Payment Initialization

```dart
Future<void> _initializePayment() async {
  if (widget.arguments == null) {
    _showError('Invalid payment data');
    return;
  }

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

    final response = await paymentProvider.initializePayment(
      amount: widget.arguments!.amount,
      currency: widget.arguments!.currency,
      bookingData: widget.arguments!.bookingData,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Check for network errors
    if (response['isNetworkError'] == true) {
      if (mounted) {
        NetworkErrorDialog.show(context);
      }
      return;
    }

    if (response['success'] == true &&
        paymentProvider.tokenUrl != null &&
        paymentProvider.orderUrl != null) {
      setState(() {
        _statusMessage = 'Opening payment gateway...';
      });
      // Proceed with Telr payment
      await _processPayment(paymentProvider);
    } else {
      String errorMsg = response['message']?.toString() ?? 'Failed to initialize payment';
      _showError(errorMsg);
    }
  } catch (e, stackTrace) {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      // Check if it's a network error
      if (NetworkErrorUtils.isNetworkError(e)) {
        NetworkErrorDialog.show(context);
      } else {
        _showError('Failed to initialize payment: $e');
      }
    }
  }
}
```

#### Process Payment (Telr SDK Call)

```dart
Future<void> _processPayment(PaymentProvider paymentProvider) async {
  if (paymentProvider.tokenUrl == null || paymentProvider.orderUrl == null) {
    _showError('Payment initialization failed. Missing payment URLs.');
    return;
  }

  try {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Loading payment gateway...';
    });

    // Call Telr SDK with tokenURL and orderURL
    // This opens the full-screen Telr payment UI INSIDE your app
    final result = await TelrSdk.presentPayment(
      paymentProvider.tokenUrl!,
      paymentProvider.orderUrl!,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result.success) {
      // Payment successful - create booking
      final transactionId = result.message.isNotEmpty
          ? result.message
          : DateTime.now().millisecondsSinceEpoch.toString();
      await _handlePaymentSuccess(result.message, transactionId);
    } else {
      // Payment cancelled or failed
      _showError(
        result.message.isNotEmpty
            ? result.message
            : 'Payment was cancelled or failed',
      );
    }
  } on PlatformException catch (e) {
    // Handle platform-specific errors
    setState(() {
      _isProcessing = false;
    });
    _showError('Payment error: ${e.message ?? e.code}');
  } catch (e) {
    setState(() {
      _isProcessing = false;
    });
    _showError('Payment error: $e');
  }
}
```

#### Handle Payment Success

```dart
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
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.customerHome,
          (route) => false,
        );
      }
    });
  } else {
    _showError(
      bookingResponse['message']?.toString() ?? 'Failed to create booking',
    );
  }
}
```

---

### Step 5: Booking Summary Screen (`lib/features/customer/presentation/screens/booking_summary_screen.dart`)

This screen initiates the payment flow when user clicks "CONFIRM & PROCEED TO PAYMENT".

```dart
void _navigateToPayment(BuildContext context, double total) {
  if (arguments == null) return;

  final package = arguments!.package;
  final addOns = arguments!.selectedAddOns;
  final dates = arguments!.selectedDates;
  final vehicle = arguments!.selectedVehicle;

  // Prepare booking data
  final bookingData = {
    'package': package,
    'addOns': addOns,
    'dates': dates.map((d) => d.toIso8601String()).toList(),
    'vehicle': vehicle,
    'totalAmount': total,
  };

  // Navigate to payment screen
  Navigator.pushNamed(
    context,
    Routes.customerPayment,
    arguments: PaymentScreenArguments(
      amount: total,
      currency: 'AED',
      bookingData: bookingData,
      package: package,
      selectedAddOns: addOns,
      selectedDates: dates,
      selectedVehicle: vehicle,
    ),
  );
}
```

---

## File-by-File Breakdown

### 1. `lib/main.dart`
**Purpose**: Initialize Telr SDK on app startup

**Key Code**:
```dart
await TelrSdk.init(
  preferredLanguageCode: 'en',
  debugLoggingEnabled: true,
  samsungPayServiceId: null,
  samsungPayMerchantId: null,
);
```

---

### 2. `lib/features/customer/data/repositories/payment_repository.dart`
**Purpose**: HTTP communication with backend

**Methods**:
- `initializePayment()` - Gets tokenURL and orderURL from backend
- `createBooking()` - Creates booking after successful payment

**Error Handling**: Catches `SocketException`, `TimeoutException`, `http.ClientException`

---

### 3. `lib/features/customer/presentation/providers/payment_provider.dart`
**Purpose**: State management and URL extraction

**Key Features**:
- Extracts URLs from multiple response formats
- Manages loading states
- Stores tokenUrl and orderUrl for Telr SDK

---

### 4. `lib/features/customer/presentation/screens/payment_screen.dart`
**Purpose**: Main payment UI and flow control

**Flow**:
1. Auto-initializes payment on screen load
2. Calls backend to get payment URLs
3. Launches Telr SDK payment UI
4. Handles payment result
5. Creates booking on success

---

### 5. `lib/features/customer/presentation/screens/booking_summary_screen.dart`
**Purpose**: Initiates payment flow

**Action**: Navigates to PaymentScreen with booking data

---

## Backend Requirements

### Endpoint 1: Initialize Payment

**URL**: `POST /api/v1/payments/initialize`

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Request Body**:
```json
{
  "amount": 100.0,
  "currency": "AED",
  "bookingData": {
    "package": { ... },
    "addOns": [ ... ],
    "dates": [ ... ],
    "vehicle": { ... },
    "totalAmount": 100.0
  }
}
```

**Response Format (Telr Standard)**:
```json
{
  "success": true,
  "data": {
    "_links": {
      "auth": {
        "href": "https://secure.telr.com/gateway/token/abc123"
      },
      "self": {
        "href": "https://secure.telr.com/gateway/order/xyz789"
      }
    }
  }
}
```

**Response Format (Alternative - Direct)**:
```json
{
  "success": true,
  "data": {
    "tokenUrl": "https://secure.telr.com/gateway/token/abc123",
    "orderUrl": "https://secure.telr.com/gateway/order/xyz789"
  }
}
```

**Error Response**:
```json
{
  "success": false,
  "message": "Error message here"
}
```

---

### Endpoint 2: Create Booking

**URL**: `POST /api/v1/bookings`

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Request Body**:
```json
{
  "package": { ... },
  "addOns": [ ... ],
  "dates": [ ... ],
  "vehicle": { ... },
  "totalAmount": 100.0,
  "payment": {
    "transactionId": "TXN123456789",
    "method": "telr",
    "status": "completed"
  }
}
```

**Response**:
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "bookingId": "BOOK123",
    ...
  }
}
```

---

## Testing Guide

### Test Scenarios

#### 1. Successful Payment Flow
1. Navigate to booking summary
2. Click "CONFIRM & PROCEED TO PAYMENT"
3. Verify payment screen loads
4. Verify backend call is made
5. Verify Telr payment UI appears
6. Complete payment with test card
7. Verify booking is created
8. Verify navigation to home screen

#### 2. Network Error Handling
1. Turn off internet connection
2. Try to proceed to payment
3. Verify network error dialog appears
4. Turn on internet
5. Retry payment

#### 3. Payment Cancellation
1. Proceed to payment
2. Cancel payment in Telr UI
3. Verify error message appears
4. Verify user can go back

#### 4. Backend Error Handling
1. Mock backend to return error
2. Verify error message is displayed
3. Verify user can retry

### Test Cards (Telr Test Environment)

Use Telr's test card numbers for testing:
- **Card Number**: Check Telr documentation for test cards
- **CVV**: Any 3 digits
- **Expiry**: Any future date

---

## Troubleshooting

### Issue: "Payment URLs not found in response"

**Cause**: Backend response doesn't contain tokenUrl and orderUrl

**Solution**: 
1. Check backend response format
2. Ensure backend calls Telr's createOrder API
3. Verify response includes `_links.auth.href` and `_links.self.href`

---

### Issue: "Network error" dialog appears

**Cause**: No internet connection or backend unreachable

**Solution**:
1. Check internet connection
2. Verify backend is running
3. Check API endpoint URL in `api.dart`

---

### Issue: Telr payment UI doesn't appear

**Cause**: SDK not initialized or URLs invalid

**Solution**:
1. Verify SDK initialization in `main.dart`
2. Check tokenUrl and orderUrl are valid HTTPS URLs
3. Verify URLs are reachable from device

---

### Issue: Payment succeeds but booking not created

**Cause**: Backend booking endpoint error

**Solution**:
1. Check backend logs
2. Verify booking endpoint accepts payment data
3. Check transaction ID is being passed correctly

---

### Issue: iOS build fails

**Cause**: iOS version mismatch

**Solution**:
1. Verify `ios/Podfile` has `platform :ios, '15.1'`
2. Run `cd ios && pod install`
3. Clean build: `flutter clean && flutter pub get`

---

### Issue: Android build fails

**Cause**: SDK version mismatch

**Solution**:
1. Verify `android/app/build.gradle.kts` has:
   - `compileSdk = 34`
   - `targetSdk = 34`
   - `minSdk = 21` (or higher)
2. Sync Gradle files

---

## Important Notes

### Security
- ✅ All URLs use HTTPS
- ✅ Tokens stored securely using `SecureStorageService`
- ✅ No sensitive data logged in production

### User Experience
- ✅ Payment UI is full-screen and in-app (no browser)
- ✅ Loading states shown during processing
- ✅ Clear error messages for users
- ✅ Automatic navigation after success

### Error Handling
- ✅ Network errors detected and handled
- ✅ User-friendly error dialogs
- ✅ Proper error messages from backend

---

## Summary

The Telr payment integration works as follows:

1. **User initiates payment** → BookingSummaryScreen
2. **Navigate to PaymentScreen** → Automatically starts payment flow
3. **Request payment session** → Backend returns tokenUrl and orderUrl
4. **Extract URLs** → PaymentProvider extracts from response
5. **Launch Telr SDK** → Full-screen payment UI appears (in-app)
6. **User completes payment** → Telr SDK processes payment
7. **Handle result** → Create booking on success, show error on failure
8. **Navigate** → Return to home screen on success

The entire flow happens **within your app** - the Telr payment UI is presented as a full-screen overlay, not in a browser.

---

## Support

For issues or questions:
1. Check this documentation
2. Review Telr SDK documentation
3. Check backend API responses
4. Review error logs in debug mode

---

**Last Updated**: 2024
**Version**: 1.0.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telr_mobile_payment_sdk/telr_mobile_payment_sdk.dart';
import 'core/config/firebase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make app edge-to-edge (extends behind system bars)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Initialize Telr SDK
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
    print(
      '   This is normal on first run. The SDK will initialize when needed.',
    );
    // Continue anyway - SDK might initialize later when payment is triggered
  }

  runApp(const MyApp());
}

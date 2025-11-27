import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  runApp(const MyApp());
}

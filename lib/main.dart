import 'package:flutter/material.dart';
import 'core/config/firebase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  runApp(const MyApp());
}

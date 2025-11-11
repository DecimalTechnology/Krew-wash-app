import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (kDebugMode) {
          print('Firebase initialized successfully');
        }
      } else {
        if (kDebugMode) {
          print('Firebase already initialized');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      // Don't rethrow the error to allow the app to run without Firebase
      // In production, you might want to handle this differently
    }
  }
}

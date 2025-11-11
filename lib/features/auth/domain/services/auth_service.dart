import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Phone Authentication
  String? _verificationId;

  // Get current user stream
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        photoURL: firebaseUser.photoURL,
      );
    });
  }

  // Get current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
    );
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    print('🚀 Starting Google Sign In...');
    try {
      print('📱 Calling Google Sign In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google sign in was cancelled by user');
        return {'success': false, 'message': 'Google sign in was cancelled'};
      }

      print('✅ Google user obtained: ${googleUser.email}');
      print('👤 Display name: ${googleUser.displayName}');
      print('🖼️ Photo URL: ${googleUser.photoUrl}');

      print('🔐 Getting Google authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🎫 Access Token: ${googleAuth.accessToken}');
      print('🆔 ID Token: ${googleAuth.idToken}');

      print('🔑 Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ Firebase sign in successful!');
        print('🆔 Firebase UID: ${userCredential.user!.uid}');
        print('📧 Firebase Email: ${userCredential.user!.email}');
        print('👤 Firebase Display Name: ${userCredential.user!.displayName}');
        print('📱 Firebase Phone: ${userCredential.user!.phoneNumber}');
        print('🖼️ Firebase Photo: ${userCredential.user!.photoURL}');

        final result = {
          'success': true,
          'user': {
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'phoneNumber': userCredential.user!.phoneNumber,
            'photoURL': userCredential.user!.photoURL,
          },
          'tokens': {
            'accessToken': googleAuth.accessToken,
            'idToken': googleAuth.idToken,
          },
        };

        print('📦 Returning result: $result');
        return result;
      } else {
        print('❌ Firebase user is null after sign in');
        return {'success': false, 'message': 'Google sign in failed'};
      }
    } catch (e) {
      print('💥 Error in Google sign in: $e');
      print('📊 Error type: ${e.runtimeType}');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Phone Authentication
  Future<PhoneAuthResult> sendPhoneVerificationCode({
    required String phoneNumber,
  }) async {
    try {
      final completer = Completer<PhoneAuthResult>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          if (kDebugMode) {
            print('Phone verification auto-completed');
          }
          if (!completer.isCompleted) {
            completer.complete(
              PhoneAuthResult.success(verificationId: 'auto-verified'),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Phone verification failed: ${e.message}');
          }
          if (!completer.isCompleted) {
            completer.complete(
              PhoneAuthResult.failure(
                errorMessage: e.message ?? 'Verification failed',
              ),
            );
          }
        },
        codeSent: (String id, int? resendToken) {
          _verificationId = id;
          if (kDebugMode) {
            print('SMS code sent. Verification ID: $id');
          }
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult.success(verificationId: id));
          }
        },
        codeAutoRetrievalTimeout: (String id) {
          _verificationId = id;
          if (kDebugMode) {
            print('Code auto-retrieval timeout. Verification ID: $id');
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('Phone verification error: $e');
      }
      return PhoneAuthResult.failure(
        errorMessage: 'Failed to send verification code: $e',
      );
    }
  }

  Future<AuthResult> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = UserModel.fromFirebaseUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          phoneNumber: userCredential.user!.phoneNumber,
          photoURL: userCredential.user!.photoURL,
        );

        // Save user to Firestore (disabled for testing)
        // await saveUserToFirestore(user);

        return AuthResult.success(user: user, method: AuthMethod.phone);
      } else {
        return AuthResult.failure(
          errorMessage: 'Phone verification failed',
          method: AuthMethod.phone,
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: e.message ?? 'An unexpected error occurred',
        method: AuthMethod.phone,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred: $e',
        method: AuthMethod.phone,
      );
    }
  }

  // Save user data to Firestore
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      // Check if Firestore is available
      await _firestore.collection('users').doc(user.uid).set({
        '_id': user.uid,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'photo': user.photo,
        'isVerified': user.isVerified,
        'verificationMethod': user.verificationMethod,
        'isDeleted': user.isDeleted,
        'isActive': user.isActive,
        'role': user.role,
        'createdAt':
            user.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'updatedAt':
            user.updatedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('User data saved to Firestore: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user to Firestore: $e');
        print('Continuing without Firestore...');
        // Don't throw the error - allow the app to continue without Firestore
        // In production, you might want to handle this differently
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Delete account error: $e');
      }
      return false;
    }
  }
}

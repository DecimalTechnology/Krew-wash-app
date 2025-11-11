import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/platform_auth_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS ? _buildIOSAuthScreen() : _buildAndroidAuthScreen();
  }

  Widget _buildIOSAuthScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginScreen/car.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header with Logo
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                            left: 24,
                            right: 24,
                          ),
                          child: Column(
                            children: [
                              // Logo with iOS-style rounded corners
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ), // More rounded for iOS
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00D4AA,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/Logo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'KREW',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontFamily:
                                      '.SF Pro Display', // iOS system font
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'CAR WASH',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white70,
                                  letterSpacing: 4,
                                  fontFamily: '.SF Pro Text', // iOS system font
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push auth form to bottom
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),

                        // Auth Form at Bottom
                        Container(
                          margin: const EdgeInsets.all(24),
                          child: const PlatformAuthWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidAuthScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginScreen/car.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header with Logo
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                            left: 24,
                            right: 24,
                          ),
                          child: Column(
                            children: [
                              // Logo with Material Design
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Material Design
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00D4AA,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/Logo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'KREW',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'CAR WASH',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white70,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push auth form to bottom
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),

                        // Auth Form at Bottom
                        Container(
                          margin: const EdgeInsets.all(24),
                          child: const PlatformAuthWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

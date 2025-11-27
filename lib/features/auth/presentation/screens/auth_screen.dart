import 'package:flutter/material.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: isIOS ? _buildIOSAuthScreen() : _buildAndroidAuthScreen(),
    );
  }

  Widget _buildIOSAuthScreen() => _buildUnifiedAuthScreen();

  Widget _buildAndroidAuthScreen() => _buildUnifiedAuthScreen();

  Widget _buildUnifiedAuthScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : screenHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image - absolutely positioned to fill
              Positioned.fill(
                child: Image.asset(
                  'assets/loginScreen/car.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Dark overlay
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.7)),
              ),
              // Content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: viewInsetsBottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return IntrinsicHeight(
                          child: Column(
                            children: [
                              // Top safe area spacer
                              SizedBox(height: topPadding),
                              // Header with Logo
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 40,
                                  left: 24,
                                  right: 24,
                                ),
                                child: Column(
                                  children: [
                                    // Logo with consistent styling across platforms
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00D4AA,
                                            ).withValues(alpha: 0.3),
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
                              const Spacer(),

                              // Auth Form at Bottom
                              Container(
                                margin: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 24,
                                  bottom: 24 + bottomPadding,
                                ),
                                child: const PlatformAuthWidget(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
  bool _isSignUp = false;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginScreen/Sign Up.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : screenHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
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
                                    child: PlatformAuthWidget(
                                      onSignUpStateChanged: (isSignUp) {
                                        setState(() {
                                          _isSignUp = isSignUp;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Title at top-left
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

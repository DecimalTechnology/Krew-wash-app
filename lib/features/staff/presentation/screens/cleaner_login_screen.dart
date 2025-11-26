import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/route_constants.dart';
// TODO: Uncomment when implementing actual login
// import '../../../auth/presentation/providers/auth_provider.dart';
// import 'package:provider/provider.dart';

class CleanerLoginScreen extends StatefulWidget {
  const CleanerLoginScreen({super.key});

  @override
  State<CleanerLoginScreen> createState() => _CleanerLoginScreenState();
}

class _CleanerLoginScreenState extends State<CleanerLoginScreen> {
  final _cleanerIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _cleanerIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildMainContent(isIOS: true),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildMainContent(isIOS: false),
    );
  }

  Widget _buildMainContent({required bool isIOS}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final mediaQuery = MediaQuery.of(context);

    // Responsive calculations
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
    final isTablet = screenWidth > 600;
    final isTallScreen = screenHeight > 800;

    // Responsive values
    final horizontalPadding = isSmallScreen
        ? screenWidth * 0.06
        : isMediumScreen
        ? screenWidth * 0.08
        : isTablet
        ? screenWidth * 0.12
        : screenWidth * 0.08;

    final topPadding = mediaQuery.padding.top + (isSmallScreen ? 16 : 32);
    final topSpacing = isSmallScreen
        ? screenHeight * 0.25
        : isTallScreen
        ? screenHeight * 0.35
        : screenHeight * 0.3;

    final titleSpacing = isSmallScreen
        ? 24.0
        : isTallScreen
        ? 48.0
        : 40.0;
    final fieldSpacing = isSmallScreen ? 16.0 : 20.0;
    final buttonSpacing = isSmallScreen ? 24.0 : 32.0;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/cleaner/image 3.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        // Dark overlay for better text readability
        color: Colors.black.withOpacity(0.3),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: topPadding,
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topSpacing),
              // LOGIN Title
              _buildLoginTitle(
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              SizedBox(height: titleSpacing),
              // CLEANER ID Field
              _buildCleanerIdField(isIOS, isSmallScreen: isSmallScreen),
              SizedBox(height: fieldSpacing),
              // PASSWORD Field
              _buildPasswordField(isIOS, isSmallScreen: isSmallScreen),
              SizedBox(height: buttonSpacing),
              // LOGIN Button
              _buildLoginButton(isIOS, isSmallScreen: isSmallScreen),
              const SizedBox(height: 16),
              // Temporary button for testing
              _buildTempTestButton(isIOS, isSmallScreen: isSmallScreen),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTitle({
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    final fontSize = isSmallScreen
        ? 28.0
        : isTablet
        ? 44.0
        : 36.0;
    final blurRadius = isSmallScreen ? 15.0 : 20.0;
    final blurRadius2 = isSmallScreen ? 25.0 : 30.0;

    return Text(
      'LOGIN',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF04CDFE),
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: const Color(0xFF04CDFE).withOpacity(0.6),
            blurRadius: blurRadius,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: const Color(0xFF04CDFE).withOpacity(0.4),
            blurRadius: blurRadius2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanerIdField(bool isIOS, {required bool isSmallScreen}) {
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final fieldPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final borderRadius = isSmallScreen ? 10.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8, left: 4),
          child: Text(
            'CLEANER ID',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
        ),
        isIOS
            ? CupertinoTextField(
                controller: _cleanerIdController,
                placeholder: '',
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: fieldPadding,
              )
            : TextField(
                controller: _cleanerIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: const BorderSide(
                      color: Color(0xFF04CDFE),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: fieldPadding,
                ),
              ),
      ],
    );
  }

  Widget _buildPasswordField(bool isIOS, {required bool isSmallScreen}) {
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final fieldPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final borderRadius = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8, left: 4),
          child: Text(
            'PASSWORD',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
        ),
        isIOS
            ? CupertinoTextField(
                controller: _passwordController,
                placeholder: '',
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: fieldPadding,
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: Colors.white.withOpacity(0.7),
                    size: iconSize,
                  ),
                ),
              )
            : TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: const BorderSide(
                      color: Color(0xFF04CDFE),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: fieldPadding,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                      size: iconSize,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildLoginButton(bool isIOS, {required bool isSmallScreen}) {
    final buttonHeight = isSmallScreen ? 48.0 : 52.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final borderRadius = isSmallScreen ? 10.0 : 12.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(borderRadius),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04CDFE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? SizedBox(
                      height: isSmallScreen ? 18 : 20,
                      width: isSmallScreen ? 18 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
    );
  }

  Widget _buildTempTestButton(bool isIOS, {required bool isSmallScreen}) {
    final buttonHeight = isSmallScreen ? 44.0 : 48.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final borderRadius = isSmallScreen ? 10.0 : 12.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(borderRadius),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.staffHome);
              },
              child: Text(
                'TEST - GO TO STAFF HOME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.staffHome);
              },
              child: Text(
                'TEST - GO TO STAFF HOME',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
    );
  }

  Future<void> _handleLogin() async {
    if (_cleanerIdController.text.trim().isEmpty) {
      _showError('Please enter your Cleaner ID');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement cleaner/staff login API call
      // final authProvider = context.read<AuthProvider>();
      // final result = await authProvider.loginAsStaff(
      //   cleanerId: _cleanerIdController.text.trim(),
      //   password: _passwordController.text,
      // );

      // For now, this is a placeholder
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // TODO: Navigate to staff home screen on success
      // Navigator.pushReplacementNamed(context, Routes.staffHome);

      _showError('Login functionality to be implemented');
    } catch (e) {
      if (!mounted) return;
      _showError('Login failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    }
  }
}

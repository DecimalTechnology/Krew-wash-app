import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/network_error_dialog.dart';
import '../providers/staff_provider.dart';

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
        color: Colors.black.withValues(alpha: 0.3),
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
              SizedBox(height: 24),
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
      style: AppTheme.bebasNeue(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF04CDFE),
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.6),
            blurRadius: blurRadius,
            offset: const Offset(0, 0),
          ),
          Shadow(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.4),
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
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        isIOS
            ? CupertinoTextField(
                controller: _cleanerIdController,
                placeholder: '',
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.next,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: fieldPadding,
              )
            : TextField(
                controller: _cleanerIdController,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
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
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        isIOS
            ? CupertinoTextField(
                controller: _passwordController,
                placeholder: '',
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.7),
                    size: iconSize,
                  ),
                ),
              )
            : TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w400,
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
                      style: AppTheme.bebasNeue(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
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
      final staffProvider = context.read<StaffProvider>();
      final result = await staffProvider.loginCleaner(
        cleanerId: _cleanerIdController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Show success message
        _showSuccess('Login successful!');

        // Always go through AuthWrapper after auth changes (keeps navigation consistent)
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(Routes.authWrapper, (route) => false);
      } else {
        // Check if it's a network error
        if (result['isNetworkError'] == true) {
          NetworkErrorDialog.show(context);
        } else {
          _showError(result['message'] ?? 'Login failed');
        }
      }
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
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

  void _showSuccess(String message) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF04CDFE),
        ),
      );
    }
  }
}

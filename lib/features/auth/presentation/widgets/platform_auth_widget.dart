import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/otp_verification_screen.dart';
import '../../../../core/widgets/country_code_picker.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/network_error_utils.dart';

class PlatformAuthWidget extends StatefulWidget {
  final Function(bool)? onSignUpStateChanged;

  const PlatformAuthWidget({super.key, this.onSignUpStateChanged});

  @override
  State<PlatformAuthWidget> createState() => _PlatformAuthWidgetState();
}

class _PlatformAuthWidgetState extends State<PlatformAuthWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSignUp = true; // Start with sign-up page

  bool get isSignUp => _isSignUp;
  CountryCode _selectedCountryCode = const CountryCode(
    name: 'United Arab Emirates',
    code: 'AE',
    dialCode: '+971',
    flag: '🇦🇪',
  );

  @override
  void initState() {
    super.initState();
    // Notify initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSignUpStateChanged?.call(_isSignUp);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo for Sign Up
              if (_isSignUp) ...[
                Center(
                  child: Image.asset(
                    'assets/Logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 24),
              ],

              // SIGN IN heading for Sign In
              if (!_isSignUp)
                Text(
                  'SIGN IN',
                  textAlign: TextAlign.center,
                  style: AppTheme.bebasNeue(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF04CDFE),
                    letterSpacing: 1.5,
                  ),
                ),
              if (!_isSignUp) SizedBox(height: 24),

              if (_isSignUp) ...[
                // Sign Up Fields
                _buildNameField(isIOS),
                SizedBox(height: 16),
                _buildEmailField(isIOS),
                SizedBox(height: 16),
                _buildPhoneField(isIOS),
              ] else ...[
                // Sign In Fields
                _buildEmailOrPhoneField(isIOS),
              ],
              SizedBox(height: 20),

              // Social Login Buttons
              _buildSocialButtons(isIOS),
              SizedBox(height: 20),

              // Primary Button
              _buildPrimaryButton(isIOS, authProvider),
              SizedBox(height: 20),

              // Toggle Text
              _buildToggleText(isIOS),
              SizedBox(height: 20),

              // Login as Cleaner Button (only for Sign In)
              if (!_isSignUp) _buildLoginAsCleanerButton(isIOS),

              // Error Message
              if (authProvider.errorMessage != null) ...[
                SizedBox(height: 16),
                _buildErrorMessage(isIOS, authProvider.errorMessage!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameField(bool isIOS) {
    return isIOS
        ? CupertinoTextField(
            controller: _nameController,
            placeholder: 'NAME',
            clearButtonMode: OverlayVisibilityMode.editing,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : TextField(
            controller: _nameController,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'NAME',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _nameController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          );
  }

  Widget _buildEmailField(bool isIOS) {
    return isIOS
        ? CupertinoTextField(
            controller: _emailController,
            placeholder: 'EMAIL',
            keyboardType: TextInputType.emailAddress,
            clearButtonMode: OverlayVisibilityMode.editing,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'EMAIL',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _emailController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _emailController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          );
  }

  Widget _buildPhoneField(bool isIOS) {
    return Row(
      children: [
        CountryCodePicker(
          onChanged: (country) {
            setState(() {
              _selectedCountryCode = country;
            });
          },
          initialSelection: _selectedCountryCode,
        ),
        SizedBox(width: 12),
        Expanded(
          child: isIOS
              ? CupertinoTextField(
                  controller: _phoneController,
                  placeholder: 'PHONE',
                  keyboardType: TextInputType.phone,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: AppTheme.textFieldStyle(color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                )
              : TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppTheme.textFieldStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'PHONE',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _phoneController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              _phoneController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmailOrPhoneField(bool isIOS) {
    // Check if the input looks like a phone number (starts with + or is all digits)
    final input = _emailController.text.trim();
    final looksLikePhone =
        input.isNotEmpty &&
        (input.startsWith('+') ||
            (RegExp(r'^[0-9]+$').hasMatch(input) && input.length >= 8));

    // Show country code picker if it looks like phone input
    if (looksLikePhone) {
      return Row(
        children: [
          CountryCodePicker(
            onChanged: (country) {
              setState(() {
                _selectedCountryCode = country;
              });
            },
            initialSelection: _selectedCountryCode,
          ),
          SizedBox(width: 12),
          Expanded(
            child: isIOS
                ? CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'PHONE',
                    keyboardType: TextInputType.phone,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    style: AppTheme.textFieldStyle(color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  )
                : TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.phone,
                    style: AppTheme.textFieldStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'PHONE',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                _emailController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
          ),
        ],
      );
    }

    // Show regular email/phone field (without country code)
    return isIOS
        ? CupertinoTextField(
            controller: _emailController,
            placeholder: 'EMAIL / PHONE',
            keyboardType: TextInputType.emailAddress,
            clearButtonMode: OverlayVisibilityMode.editing,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: (value) {
              setState(() {
                // Trigger rebuild when input changes to show/hide country picker
              });
            },
          )
        : TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTheme.textFieldStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'EMAIL / PHONE',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _emailController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _emailController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                // Trigger rebuild when input changes to show/hide country picker
              });
            },
          );
  }

  Widget _buildSocialButtons(bool isIOS) {
    // Google sign-in button is hidden
    return const SizedBox.shrink();
  }

  Widget _buildPrimaryButton(bool isIOS, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                if (_isSignUp) {
                  await _handleSignUp();
                } else {
                  await _handleSignIn();
                }
              },
              child: Center(
                child: authProvider.isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        _isSignUp ? 'GET STARTED' : 'LOGIN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (_isSignUp) {
                    await _handleSignUp();
                  } else {
                    await _handleSignIn();
                  }
                },
                child: Center(
                  child: authProvider.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isSignUp ? 'GET STARTED' : 'LOGIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildToggleText(bool isIOS) {
    return isIOS
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
                widget.onSignUpStateChanged?.call(_isSignUp);
              });
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.white),
                children: [
                  TextSpan(
                    text: _isSignUp
                        ? 'ALREADY HAVE AN ACCOUNT ? '
                        : 'NOT A MEMBER ? ',
                  ),
                  TextSpan(
                    text: _isSignUp ? 'LOGIN' : 'SIGNUP',
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _isSignUp = !_isSignUp;
                widget.onSignUpStateChanged?.call(_isSignUp);
              });
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.white),
                children: [
                  TextSpan(
                    text: _isSignUp
                        ? 'ALREADY HAVE AN ACCOUNT ? '
                        : 'NOT A MEMBER ? ',
                  ),
                  TextSpan(
                    text: _isSignUp ? 'LOGIN' : 'SIGNUP',
                    style: const TextStyle(
                      color: Color(0xFF04CDFE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildLoginAsCleanerButton(bool isIOS) {
    return Center(
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pushNamed(context, Routes.cleanerLogin);
              },
              child: Column(
                children: [
                  Text(
                    'LOGIN AS CLEANER',
                    style: AppTheme.bebasNeue(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF04CDFE),
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF04CDFE).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // Double underline
                  Stack(
                    children: [
                      Container(
                        height: 2,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF04CDFE).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        child: Container(
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF04CDFE,
                            ).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : TextButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.cleanerLogin);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Column(
                children: [
                  Text(
                    'LOGIN AS CLEANER',
                    style: AppTheme.bebasNeue(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF04CDFE),
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF04CDFE).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // Double underline
                  Stack(
                    children: [
                      Container(
                        height: 2,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF04CDFE).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        child: Container(
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF04CDFE,
                            ).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorMessage(bool isIOS, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  //////////
  ///\
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  // Sign Up Handler
  Future<void> _handleSignUp() async {
    final authProvider = context.read<AuthProvider>();

    // Verify all fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showErrorMessage('Please fill in all fields');
      return;
    }

    // Validate email format
    if (!authProvider.isValidEmail(_emailController.text)) {
      _showErrorMessage('Please enter a valid email address');
      return;
    }

    // Format phone number with country code
    final phoneNumber = _phoneController.text.trim().isEmpty
        ? ''
        : _selectedCountryCode.dialCode + _phoneController.text.trim();

    // Validate phone number format
    if (!authProvider.isValidPhoneNumber(phoneNumber)) {
      _showErrorMessage('Please enter a valid phone number');
      return;
    }

    final phoneandemailExists = await authProvider.checkPhoneExists(
      phoneNumber,
      _emailController.text,
    );

    // Debug: Log the response
    if (kDebugMode) {
      print('📱 Sign-Up Phone Check Response: $phoneandemailExists');
      print('📱 Status Code: ${phoneandemailExists['statusCode']}');
      print('📱 Success: ${phoneandemailExists['success']}');
    }

    // For SIGN-UP logic:
    // - If statusCode is 200 AND success=true: Phone does NOT exist -> Send OTP (proceed with sign-up)
    // - If statusCode is 409 OR message contains "already exists": Phone EXISTS -> Don't send OTP, show error
    final statusCode = phoneandemailExists['statusCode'] as int?;
    final success = phoneandemailExists['success'] as bool?;
    final errorMessage =
        phoneandemailExists['message']?.toString().toLowerCase() ?? '';
    final is200Success = statusCode == 200 && success == true;
    final is409Error = statusCode == 409;
    final messageIndicatesExists =
        errorMessage.contains('already exists') ||
        errorMessage.contains('phone number already exists');

    if (kDebugMode) {
      print(
        '📱 Sign-Up check: statusCode=$statusCode, success=$success, is200Success=$is200Success, is409Error=$is409Error, messageIndicatesExists=$messageIndicatesExists',
      );
    }

    // If phone does NOT exist (200 success), proceed with sign-up OTP
    if (is200Success) {
      if (kDebugMode) {
        print(
          '✅ Phone does NOT exist (200 success), proceeding with sign-up OTP',
        );
      }
      final otpMethod = await _showOtpMethodSelectionDialog();
      if (otpMethod == null) return;

      if (otpMethod == 'phone') {
        await _sendPhoneOtpForSignUp();
      } else {
        await _sendEmailOtpForSignUp();
      }
    } else if (is409Error || messageIndicatesExists) {
      // Phone already exists, show error
      if (kDebugMode) {
        print('❌ Phone already exists, cannot sign up');
      }
      final errorMsg =
          phoneandemailExists['message'] ??
          'This phone number or email is already registered. Please sign in instead.';
      _showErrorMessage(errorMsg);
    } else {
      // Other errors (network, etc.)
      final errorMsg =
          phoneandemailExists['message'] ??
          'Failed to check phone number. Please try again.';
      _showErrorMessage(errorMsg);
    }
  }

  // Send OTP based on selected method
  Future<String?> _showOtpMethodSelectionDialog() async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return await showCupertinoDialog<String>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Choose Verification Method'),
          content: Text('How would you like to receive the verification code?'),
          actions: [
            CupertinoDialogAction(
              child: Text('Phone Number'),
              onPressed: () => Navigator.pop(context, 'phone'),
            ),
            CupertinoDialogAction(
              child: Text('Email'),
              onPressed: () => Navigator.pop(context, 'email'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Choose Verification Method'),
          content: Text('How would you like to receive the verification code?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'phone'),
              child: Text('Phone Number'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'email'),
              child: Text('Email'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendEmailOtpForSignUp() async {
    try {
      final authProvider = context.read<AuthProvider>();

      final result = await authProvider.sendEmailOtp(
        email: _emailController.text,
      );

      if (result['success']) {
        _showSuccessMessage('OTP sent to your email');

        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber:
                    _selectedCountryCode.dialCode +
                    _phoneController.text.trim(),
                otpMethod: 'email',
                email: _emailController.text,
                name: _nameController.text,
                isSignUp: true,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage(result['message'] ?? 'Failed to send email OTP');
      }
    } catch (e) {
      _showErrorMessage('Failed to send email OTP: $e');
    }
  }

  ///////////////////////
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  // Sign In Handler
  Future<void> _handleSignIn() async {
    final authProvider = context.read<AuthProvider>();

    // Verify fields
    if (_emailController.text.isEmpty) {
      _showErrorMessage('Please enter your email or phone number');
      return;
    }

    // Determine if input is email or phone
    final input = _emailController.text.trim();
    final isEmail = authProvider.isValidEmail(input);
    final isPhone = authProvider.isValidPhoneNumber(input);

    // Print the input data for debugging
    if (kDebugMode) {
      print('\n🔐 ========== SIGN-IN ATTEMPT ==========');
      print('📝 Input: $input');
      print('📧 Is Email: $isEmail');
      print('📱 Is Phone: $isPhone');
    }

    if (!isEmail && !isPhone) {
      _showErrorMessage('Please enter a valid email or phone number');
      return;
    }

    // For phone sign-in, check if user exists
    if (isPhone) {
      try {
        // If input already has country code, use it; otherwise prepend selected country code
        final phoneNumber = input.trim().startsWith('+')
            ? input.trim()
            : _selectedCountryCode.dialCode + input.trim();

        // Format to E.164 for Firebase
        final formattedPhone = authProvider.formatPhoneNumber(phoneNumber);

        // Format for API (remove + sign)
        final phoneForApi = authProvider.formatPhoneNumberForApi(
          formattedPhone,
        );

        if (kDebugMode) {
          print('📱 Phone Sign-In:');
          print('   Original Input: $input');
          print('   Selected Country Code: ${_selectedCountryCode.dialCode}');
          print('   Phone with Country Code: $phoneNumber');
          print('   Formatted Phone (E.164): $formattedPhone');
          print('   Phone for API (no +): $phoneForApi');
        }

        final phoneExists = await authProvider.checkPhoneExists(
          formattedPhone, // Pass E.164 format, repository will format for API
          '', // Empty email for phone-only sign-in
        );

        // Debug: Log the full response to understand the structure
        if (kDebugMode) {
          print('📱 Phone check response: $phoneExists');
          print('📱 Status Code: ${phoneExists['statusCode']}');
          print('📱 Success: ${phoneExists['success']}');
        }

        // For SIGN-IN logic:
        // - If statusCode is 200 AND success=true: Phone does NOT exist -> Don't send OTP, ask to register
        // - If statusCode is 409: Phone EXISTS -> Send OTP for sign-in
        // - If message contains "already exists": Phone EXISTS -> Send OTP for sign-in
        // - If success=false and message is null: Phone EXISTS -> Send OTP for sign-in
        final statusCode = phoneExists['statusCode'] as int?;
        final success = phoneExists['success'] as bool?;
        final errorMessage =
            phoneExists['message']?.toString().toLowerCase() ?? '';
        final hasMessage = phoneExists['message'] != null;
        final is409Error = statusCode == 409;
        final is200Success = statusCode == 200 && success == true;
        final messageIndicatesExists =
            errorMessage.contains('already exists') ||
            errorMessage.contains('phone number already exists');

        // Phone exists if: 409 error OR "already exists" message OR (success=false and no message)
        // Phone does NOT exist if: 200 with success=true
        final phoneRegistered =
            is409Error ||
            messageIndicatesExists ||
            (success == false && !hasMessage);

        if (kDebugMode) {
          print(
            '📱 Phone registered check: hasMessage=$hasMessage, statusCode=$statusCode, success=$success, is409Error=$is409Error, is200Success=$is200Success, messageIndicatesExists=$messageIndicatesExists, phoneRegistered=$phoneRegistered',
          );
        }

        // If phone does NOT exist (200 success), don't send OTP - ask to register
        if (is200Success) {
          if (kDebugMode) {
            print(
              '❌ Phone does NOT exist (200 success), user needs to register first',
            );
          }
          _showPhoneNotRegisteredError();
          return;
        }

        // If phone exists, proceed with OTP for sign-in
        if (phoneRegistered || is409Error || messageIndicatesExists) {
          // Phone is registered (409 or "already exists" message means phone exists) - proceed with OTP for login
          if (kDebugMode) {
            print(
              '✅ Phone exists (409 or "already exists" message), proceeding with OTP for sign-in',
            );
          }
          await _sendPhoneOtpForSignIn(input);
        } else {
          // Check if it's a network error
          final errorMessage = phoneExists['message'] ?? '';
          // Debug: print error message to verify detection
          if (kDebugMode) {
            print('🔍 Checking error message: $errorMessage');
            print(
              '🔍 Is network error: ${NetworkErrorUtils.isNetworkErrorString(errorMessage)}',
            );
          }
          if (NetworkErrorUtils.isNetworkErrorString(errorMessage)) {
            // Network error - show network error message
            if (kDebugMode) {
              print('✅ Network error detected, showing network error message');
            }
            _showErrorMessage(NetworkErrorUtils.getNetworkErrorMessage());
          } else {
            // Phone is not registered, show error
            if (kDebugMode) {
              print('❌ Phone not registered, showing error message');
            }
            _showPhoneNotRegisteredError();
          }
        }
      } catch (e) {
        // Check if it's a network error
        if (NetworkErrorUtils.isNetworkError(e)) {
          // Network error - show network error message
          if (kDebugMode) {
            print(
              '✅ Network error detected in catch block, showing network error message',
            );
          }
          _showErrorMessage(NetworkErrorUtils.getNetworkErrorMessage());
        } else {
          _showErrorMessage('Failed to check phone number. Please try again.');
        }
      }
    } else if (isEmail) {
      // For email sign-in, send OTP directly (API will handle email lookup)
      // Print email being used for sign-in
      if (kDebugMode) {
        print('📧 Email Sign-In:');
        print('   Email: $input');
      }
      await _sendEmailOtpForSignIn(input);
    }

    if (kDebugMode) {
      print('🔐 ======================================\n');
    }
  }

  Future<void> _sendEmailOtpForSignIn(String email) async {
    try {
      final authProvider = context.read<AuthProvider>();

      // Print email OTP request
      if (kDebugMode) {
        print('\n📧 ========== EMAIL OTP REQUEST ==========');
        print('📧 Email: $email');
        print('📧 Sending OTP to email...');
      }

      final result = await authProvider.sendEmailOtp(email: email);

      if (kDebugMode) {
        print('📧 OTP Result: ${result['success']}');
        print('📧 Message: ${result['message']}');
        print('📧 =======================================\n');
      }

      if (result['success']) {
        _showSuccessMessage('OTP sent to your email');

        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: email, // Using email as contact info
                otpMethod: 'email',
                email: email,
                isSignUp: false,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage(result['message'] ?? 'Failed to send email OTP');
      }
    } catch (e) {
      _showErrorMessage('Failed to send email OTP: $e');
    }
  }

  Future<void> _sendPhoneOtpForSignUp() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final phoneNumber =
          _selectedCountryCode.dialCode + _phoneController.text.trim();

      // Format to E.164 for Firebase
      final formattedPhone = authProvider.formatPhoneNumber(phoneNumber);

      if (kDebugMode) {
        print('📱 Sign-Up: Sending OTP to phone...');
        print('📱 Phone: $phoneNumber');
        print('📱 Formatted Phone (E.164): $formattedPhone');
      }

      // Note: User existence check is already done in _handleSignUp
      // If we reach here, it means phone does NOT exist (200 success), so proceed with OTP
      final result = await authProvider.sendPhoneVerificationCode(
        phoneNumber: formattedPhone,
      );

      if (result.isSuccess) {
        _showSuccessMessage('OTP sent to your phone number');

        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneNumber,
                otpMethod: 'phone',
                verificationId: result.verificationId,
                email: _emailController.text,
                name: _nameController.text,
                isSignUp: true,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage(result.errorMessage ?? 'Failed to send OTP');
      }
    } catch (e) {
      // Check if it's a network error
      if (NetworkErrorUtils.isNetworkError(e)) {
        _showErrorMessage(NetworkErrorUtils.getNetworkErrorMessage());
      } else {
        _showErrorMessage('Failed to send OTP: $e');
      }
    }
  }

  Future<void> _sendPhoneOtpForSignIn(String inputPhoneNumber) async {
    try {
      final authProvider = context.read<AuthProvider>();
      // If input already has country code, use it; otherwise prepend selected country code
      final phoneNumber = inputPhoneNumber.trim().startsWith('+')
          ? inputPhoneNumber.trim()
          : _selectedCountryCode.dialCode + inputPhoneNumber.trim();

      // Format to E.164 for Firebase
      final formattedPhoneForFirebase = authProvider.formatPhoneNumber(
        phoneNumber,
      );

      // Format for API (remove + sign) - for debug purposes
      final phoneForApi = authProvider.formatPhoneNumberForApi(
        formattedPhoneForFirebase,
      );

      // Print phone OTP request
      if (kDebugMode) {
        print('\n📱 ========== PHONE OTP REQUEST ==========');
        print('📱 Input Phone: $inputPhoneNumber');
        print('📱 Selected Country Code: ${_selectedCountryCode.dialCode}');
        print('📱 Phone with Country Code: $phoneNumber');
        print('📱 Final Phone Number (E.164): $formattedPhoneForFirebase');
        print('📱 Phone for API (no +): $phoneForApi');
        print('📱 Sending OTP to phone...');
      }

      final result = await authProvider.sendPhoneVerificationCode(
        phoneNumber: formattedPhoneForFirebase,
      );

      if (kDebugMode) {
        print('📱 OTP Result: ${result.isSuccess}');
        print('📱 Verification ID: ${result.verificationId}');
        print('📱 Error Message: ${result.errorMessage}');
        print('📱 =======================================\n');
      }

      if (result.isSuccess) {
        _showSuccessMessage('OTP sent to your phone number');

        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: formattedPhoneForFirebase,
                otpMethod: 'phone',
                verificationId: result.verificationId,
                isSignUp: false,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage(result.errorMessage ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showErrorMessage('Failed to send OTP: $e');
    }
  }

  void _showSuccessMessage(String message) {
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
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
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
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showPhoneNotRegisteredError() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Phone Number Not Registered'),
          content: Text(
            'This phone number is not registered. Please sign up to create an account.',
          ),
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
          content: Text(
            'Phone number not registered. Please sign up to create an account.',
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Google Sign-In Functions (commented out - Google sign-in button is hidden)
  // Future<void> _handleSignUpWithGoogle() async {
  //   print('helooooooooooooooooo');
  //   try {
  //     final authProvider = context.read<AuthProvider>();

  //     final result = await authProvider.signInWithGoogle();

  //     if (result['success'] && result['user'] != null) {
  //       final userData = result['user'];
  //       print(userData['email']);
  //       print(userData['displayName']);
  //       print(userData['photoURL']);
  //       _showSuccessMessage('Google sign-up successful');

  //       // Register user with backend API
  //       final registerResult = await authProvider.registerUserAfterVerification(
  //         email: userData['email'] ?? '',
  //         name: userData['displayName'] ?? '',
  //         phoneNumber: "",
  //         photoURL: userData['photoURL'],
  //         verificationMethod: "google",
  //       );

  //       if (registerResult['success']) {
  //         _showSuccessMessage('Account created successfully');
  //         // Navigation will be handled by AuthProvider state change
  //       } else {
  //         _showErrorMessage(
  //           registerResult['message'] ?? 'Failed to create account',
  //         );
  //       }
  //     } else {
  //       _showErrorMessage(result['message'] ?? 'Google sign-up failed');
  //     }
  //   } catch (e) {
  //     _showErrorMessage('Google sign-up failed: $e');
  //   }
  // }

  // Future<void> _handleSignInWithGoogle() async {
  //   try {
  //     final authProvider = context.read<AuthProvider>();

  //     final result = await authProvider.signInWithGoogle();

  //     if (result['success'] && result['user'] != null) {
  //       _showSuccessMessage('Google sign-in successful');
  //       // Navigation will be handled by AuthProvider state change
  //     } else {
  //       _showErrorMessage(result['message'] ?? 'Google sign-in failed');
  //     }
  //   } catch (e) {
  //     _showErrorMessage('Google sign-in failed: $e');
  //   }
  // }
}

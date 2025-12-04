import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
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
                const SizedBox(height: 24),
              ],

              // SIGN IN heading for Sign In
              if (!_isSignUp)
                const Text(
                  'SIGN IN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF04CDFE),
                    letterSpacing: 1.5,
                  ),
                ),
              if (!_isSignUp) const SizedBox(height: 24),

              if (_isSignUp) ...[
                // Sign Up Fields
                _buildNameField(isIOS),
                const SizedBox(height: 16),
                _buildEmailField(isIOS),
                const SizedBox(height: 16),
                _buildPhoneField(isIOS),
              ] else ...[
                // Sign In Fields
                _buildEmailOrPhoneField(isIOS),
              ],
              const SizedBox(height: 20),

              // Social Login Buttons
              _buildSocialButtons(isIOS),
              const SizedBox(height: 20),

              // Primary Button
              _buildPrimaryButton(isIOS, authProvider),
              const SizedBox(height: 20),

              // Toggle Text
              _buildToggleText(isIOS),
              const SizedBox(height: 20),

              // Login as Cleaner Button (only for Sign In)
              if (!_isSignUp) _buildLoginAsCleanerButton(isIOS),

              // Error Message
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
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
            style: const TextStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'NAME',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00D4AA)),
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
            style: const TextStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'EMAIL',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00D4AA)),
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
        const SizedBox(width: 12),
        Expanded(
          child: isIOS
              ? CupertinoTextField(
                  controller: _phoneController,
                  placeholder: 'PHONE',
                  keyboardType: TextInputType.phone,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: const TextStyle(color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                )
              : TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'PHONE',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00D4AA)),
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
          const SizedBox(width: 12),
          Expanded(
            child: isIOS
                ? CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'PHONE',
                    keyboardType: TextInputType.phone,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    style: const TextStyle(color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  )
                : TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'PHONE',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00D4AA)),
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
            style: const TextStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'EMAIL / PHONE',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00D4AA)),
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
    return Column(
      children: [
        // Google Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    if (_isSignUp) {
                      await _handleSignUpWithGoogle();
                    } else {
                      await _handleSignInWithGoogle();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.g_mobiledata,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SIGN UP WITH GOOGLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      if (_isSignUp) {
                        await _handleSignUpWithGoogle();
                      } else {
                        await _handleSignInWithGoogle();
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.g_mobiledata,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SIGN UP WITH GOOGLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(bool isIOS, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.3),
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
                          fontWeight: FontWeight.bold,
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
                      ? const SizedBox(
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
                            fontWeight: FontWeight.bold,
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: '.SF Pro Text',
                ),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF04CDFE),
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF04CDFE).withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Double underline
                  Stack(
                    children: [
                      Container(
                        height: 2,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF04CDFE).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        child: Container(
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF04CDFE).withOpacity(0.6),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF04CDFE),
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF04CDFE).withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Double underline
                  Stack(
                    children: [
                      Container(
                        height: 2,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF04CDFE).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        child: Container(
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF04CDFE).withOpacity(0.6),
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
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
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

    if (phoneandemailExists['message'] == null) {
      final otpMethod = await _showOtpMethodSelectionDialog();
      if (otpMethod == null) return;

      if (otpMethod == 'phone') {
        await _sendPhoneOtpForSignUp();
      } else {
        await _sendEmailOtpForSignUp();
      }
    } else {
      _showErrorMessage(phoneandemailExists['message']);
    }
  }

  // Send OTP based on selected method
  Future<String?> _showOtpMethodSelectionDialog() async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return await showCupertinoDialog<String>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Choose Verification Method'),
          content: const Text(
            'How would you like to receive the verification code?',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Phone Number'),
              onPressed: () => Navigator.pop(context, 'phone'),
            ),
            CupertinoDialogAction(
              child: const Text('Email'),
              onPressed: () => Navigator.pop(context, 'email'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Verification Method'),
          content: const Text(
            'How would you like to receive the verification code?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'phone'),
              child: const Text('Phone Number'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'email'),
              child: const Text('Email'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
    print('hiiiiiiiiiiiiiiii');
    final authProvider = context.read<AuthProvider>();

    // Verify fields
    if (_emailController.text.isEmpty) {
      _showErrorMessage('Please enter your email or phone number');
      return;
    }

    // Determine if input is email or phone
    final input = _emailController.text;
    final isEmail = authProvider.isValidEmail(input);
    final isPhone = authProvider.isValidPhoneNumber(input);

    if (!isEmail && !isPhone) {
      _showErrorMessage('Please enter a valid email or phone number');
      return;
    }

    // For phone sign-in, check if user exists
    if (isPhone) {
      try {
        final phoneExists = await authProvider.checkPhoneExists(
          authProvider.formatPhoneNumber(input),
          '', // Empty email for phone-only sign-in
        );

        // Debug: Log the full response to understand the structure
        if (kDebugMode) {
          print('📱 Phone check response: $phoneExists');
        }

        // Check if phone is actually registered
        // The API returns message: null when phone exists (similar to sign-up flow)
        // If message is not null, it means phone doesn't exist or there's an error
        final hasMessage = phoneExists['message'] != null;
        final phoneRegistered = !hasMessage;

        if (kDebugMode) {
          print('📱 Phone registered check: hasMessage=$hasMessage, phoneRegistered=$phoneRegistered');
        }

        if (phoneRegistered) {
          // Phone is registered, proceed with OTP for login
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
      await _sendEmailOtpForSignIn(input);
    }
  }

  Future<void> _sendEmailOtpForSignIn(String email) async {
    try {
      final authProvider = context.read<AuthProvider>();

      final result = await authProvider.sendEmailOtp(email: email);

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

      final result = await authProvider.sendPhoneVerificationCode(
        phoneNumber: phoneNumber,
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
      _showErrorMessage('Failed to send OTP: $e');
    }
  }

  Future<void> _sendPhoneOtpForSignIn(String inputPhoneNumber) async {
    try {
      final authProvider = context.read<AuthProvider>();
      // If input already has country code, use it; otherwise prepend selected country code
      final phoneNumber = inputPhoneNumber.trim().startsWith('+')
          ? inputPhoneNumber.trim()
          : _selectedCountryCode.dialCode + inputPhoneNumber.trim();

      final result = await authProvider.sendPhoneVerificationCode(
        phoneNumber: phoneNumber,
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
          title: const Text('Success'),
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
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF00D4AA),
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
          title: const Text('Phone Number Not Registered'),
          content: const Text(
            'This phone number is not registered. Please sign up to create an account.',
          ),
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
        SnackBar(
          content: const Text(
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

  // Google Sign-In Functions
  Future<void> _handleSignUpWithGoogle() async {
    print('helooooooooooooooooo');
    try {
      final authProvider = context.read<AuthProvider>();

      final result = await authProvider.signInWithGoogle();

      if (result['success'] && result['user'] != null) {
        final userData = result['user'];
        print(userData['email']);
        print(userData['displayName']);
        print(userData['photoURL']);
        _showSuccessMessage('Google sign-up successful');

        // Register user with backend API
        final registerResult = await authProvider.registerUserAfterVerification(
          email: userData['email'] ?? '',
          name: userData['displayName'] ?? '',
          phoneNumber: "",
          photoURL: userData['photoURL'],
          verificationMethod: "google",
        );

        if (registerResult['success']) {
          _showSuccessMessage('Account created successfully');
          // Navigation will be handled by AuthProvider state change
        } else {
          _showErrorMessage(
            registerResult['message'] ?? 'Failed to create account',
          );
        }
      } else {
        _showErrorMessage(result['message'] ?? 'Google sign-up failed');
      }
    } catch (e) {
      _showErrorMessage('Google sign-up failed: $e');
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    try {
      final authProvider = context.read<AuthProvider>();

      final result = await authProvider.signInWithGoogle();

      if (result['success'] && result['user'] != null) {
        _showSuccessMessage('Google sign-in successful');
        // Navigation will be handled by AuthProvider state change
      } else {
        _showErrorMessage(result['message'] ?? 'Google sign-in failed');
      }
    } catch (e) {
      _showErrorMessage('Google sign-in failed: $e');
    }
  }
}

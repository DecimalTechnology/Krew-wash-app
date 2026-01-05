import 'dart:async';
import 'package:carwash_app/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/network_error_dialog.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otpMethod;
  final String? verificationId;
  final String? email;
  final String? name;
  final bool isSignUp;
  final VoidCallback? onVerified; // optional hook for profile updates

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.otpMethod,
    this.verificationId,
    this.email,
    this.name,
    this.isSignUp = false,
    this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _verificationCode = '';

  // Resend code functionality
  int _resendTimer = 60; // 60 seconds countdown
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS ? _buildIOSOtpScreen() : _buildAndroidOtpScreen();
  }

  Widget _buildIOSOtpScreen() {
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
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    StandardBackButton(onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              // Spacer to push content to center
              const Spacer(),

              // Verification content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'VERIFICATION',
                      style: AppTheme.bebasNeue(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Instructions
                    Text(
                      widget.otpMethod == 'email'
                          ? 'WE\'VE SEND YOU THE VERIFICATION CODE ON\n${widget.email}'
                          : 'WE\'VE SEND YOU THE VERIFICATION CODE ON\n${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1,

                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),

                    // OTP Input Fields
                    _buildOtpFields(true),
                    SizedBox(height: 24),

                    // Resend Code Button
                    _buildResendButton(true),
                    SizedBox(height: 24),

                    // Continue Button
                    _buildContinueButton(true),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidOtpScreen() {
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
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    StandardBackButton(onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              // Spacer to push content to center
              const Spacer(),

              // Verification content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'VERIFICATION',
                      style: AppTheme.bebasNeue(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Instructions
                    Text(
                      widget.otpMethod == 'email'
                          ? 'WE\'VE SEND YOU THE VERIFICATION CODE ON\n${widget.email}'
                          : 'WE\'VE SEND YOU THE VERIFICATION CODE ON\n${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),

                    // OTP Input Fields
                    _buildOtpFields(true),
                    SizedBox(height: 24),

                    // Resend Code Button
                    _buildResendButton(true),
                    SizedBox(height: 24),

                    // Continue Button
                    _buildContinueButton(true),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields(bool isIOS) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildIOSOtpField(index),
        );
      }),
    );
  }

  Widget _buildIOSOtpField(int index) {
    return CupertinoTextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      decoration: const BoxDecoration(),
      onChanged: (value) {
        if (value.isNotEmpty) {
          if (index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else {
            _focusNodes[index].unfocus();
          }
        } else if (value.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
        _updateVerificationCode();
      },
      onSubmitted: (value) {
        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      },
    );
  }


  Widget _buildContinueButton(bool isIOS) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed:
                authProvider.isLoading || _verificationCode.length != 6
                ? null
                : _verifyOtp,
            child: Center(
              child: authProvider.isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      'CONTINUE',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _updateVerificationCode() {
    setState(() {
      _verificationCode = _controllers
          .map((controller) => controller.text)
          .join();
    });
  }

  Widget _buildResendButton(bool isIOS) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canResend && !authProvider.isLoading
              ? _resendCode
              : null,
          child: Text(
            _canResend
                ? 'RESEND CODE'
                : 'RESEND CODE IN ${_resendTimer}s',
            style: AppTheme.bebasNeue(
              color: _canResend
                  ? AppTheme.primaryColor
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }

  Future<void> _resendCode() async {
    try {
      final authProvider = context.read<AuthProvider>();

      // Reset timer
      setState(() {
        _canResend = false;
        _resendTimer = 60;
      });

      // Start new timer
      _startResendTimer();

      if (widget.otpMethod == 'email') {
        // Send email OTP
        final result = await authProvider.sendEmailOtp(email: widget.email!);

        if (result['success'] == true) {
          _showSuccessMessage('New OTP sent to your email');
        } else {
          _showErrorMessage(result['message'] ?? 'Failed to resend email OTP');
          // Reset timer if failed
          setState(() {
            _canResend = true;
            _resendTimer = 0;
          });
          _timer?.cancel();
        }
      } else {
        // Send phone OTP
        final result = await authProvider.sendPhoneVerificationCode(
          phoneNumber: widget.phoneNumber,
        );

        if (result.isSuccess) {
          _showSuccessMessage('New OTP sent to your phone number');
        } else {
          _showErrorMessage(result.errorMessage ?? 'Failed to resend OTP');
          // Reset timer if failed
          setState(() {
            _canResend = true;
            _resendTimer = 0;
          });
          _timer?.cancel();
        }
      }
    } catch (e) {
      _showErrorMessage('Failed to resend OTP: $e');
      // Reset timer if failed
      setState(() {
        _canResend = true;
        _resendTimer = 0;
      });
      _timer?.cancel();
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationCode.length != 6) return;

    try {
      final authProvider = context.read<AuthProvider>();

      if (widget.otpMethod == 'email') {
        // Handle email OTP verification
        final result = await authProvider.verifyEmailOtp(
          email: widget.email!,
          otp: _verificationCode,
        );

        if (result['success'] == true) {
          // If this OTP is for a profile update (not sign up/login), use callback
          if (!widget.isSignUp && widget.onVerified != null) {
            widget.onVerified!();
            if (mounted) Navigator.pop(context);
            return;
          }
          if (widget.isSignUp && widget.email != null && widget.name != null) {
            // Register user after email verification
            final registerResult = await authProvider
                .registerUserAfterVerification(
                  email: widget.email!,
                  name: widget.name!,
                  phoneNumber: widget.phoneNumber,
                  verificationMethod: "email",
                );

            if (registerResult['success'] == true) {
              _showSuccessMessage('Account created successfully!');
              // Navigate to edit profile screen first
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.customerProfileDetails,
                  (route) => false,
                );
              }
            } else {
              _showErrorMessage(
                registerResult['message'] ?? 'Failed to create account',
              );
            }
          } else {
            // Login user after email verification
            print('🔐 Logging in user after email verification...');
            print('📧 Email: ${widget.email}');

            final loginResult = await authProvider.loginUserWithEmail(
              email: widget.email!,
            );

            print('📊 Email login result: $loginResult');

            if (loginResult['success'] == true) {
              _showSuccessMessage('Login successful!');

              // Sign out from Firebase immediately after successful login
              // Firebase is only used for OTP verification, not for storing user data
              try {
                await authProvider.signOutFromFirebaseOnly();
                if (kDebugMode) {
                  print(
                    '🔓 Signed out from Firebase after successful email login',
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error signing out from Firebase: $e');
                }
              }

              // Check if profile is complete before navigating
              if (mounted) {
                final isProfileComplete = authProvider.isProfileComplete();
                if (isProfileComplete) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.customerHome,
                    (route) => false,
                  );
                } else {
                  // Navigate to profile details screen if profile is incomplete
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.customerProfileDetails,
                    (route) => false,
                  );
                }
              }
            } else {
              // Check if it's a network error
              if (loginResult['isNetworkError'] == true) {
                NetworkErrorDialog.show(context);
              } else {
                _showErrorMessage(loginResult['message'] ?? 'Failed to login');
              }
            }
          }
        } else {
          // Check if it's a network error
          if (result['isNetworkError'] == true) {
            NetworkErrorDialog.show(context);
          } else {
            _showErrorMessage(
              result['message'] ?? 'Email OTP verification failed',
            );
          }
        }
      } else {
        // Handle phone OTP verification
        if (widget.verificationId == null) {
          _showErrorMessage('Verification ID is missing');
          return;
        }

        final result = await authProvider.verifyPhoneNumber(
          verificationId: widget.verificationId!,
          smsCode: _verificationCode,
        );

        if (result.isSuccess && result.user != null) {
          // Profile-update verification path
          if (!widget.isSignUp && widget.onVerified != null) {
            widget.onVerified!();
            if (mounted) Navigator.pop(context);
            return;
          }
          if (widget.isSignUp) {
            // Register user after phone verification
            final registerResult = await authProvider
                .registerUserAfterVerification(
                  email: widget.email ?? "",
                  name: widget.name ?? "",
                  phoneNumber: widget.phoneNumber,
                  verificationMethod: "phone",
                );

            if (registerResult['success'] == true) {
              _showSuccessMessage('Account created successfully!');

              // Sign out from Firebase immediately after successful registration
              // Firebase is only used for OTP verification, not for storing user data
              try {
                await authProvider.signOutFromFirebaseOnly();
                if (kDebugMode) {
                  print(
                    '🔓 Signed out from Firebase after successful registration',
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error signing out from Firebase: $e');
                }
              }

              // Navigate to edit profile screen first
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.customerProfileDetails,
                  (route) => false,
                );
              }
            } else {
              _showErrorMessage(
                registerResult['message'] ?? 'Failed to create account',
              );
            }
          } else {
            // Login user after phone verification
            print('🔐 Logging in user after phone verification...');
            print('📧 Email: ${result.user!.email}');
            print('📱 Phone: ${widget.phoneNumber}');
            print('🆔 UID: ${result.user!.uid}');

            final loginResult = await authProvider
                .loginUserAfterPhoneVerification(
                  uid: "",
                  email: result.user!.email ?? '',
                  phoneNumber: widget.phoneNumber,
                );

            if (loginResult['success'] == true) {
              _showSuccessMessage('Login successful!');

              // Sign out from Firebase immediately after successful login
              // Firebase is only used for OTP verification, not for storing user data
              try {
                await authProvider.signOutFromFirebaseOnly();
                if (kDebugMode) {
                  print('🔓 Signed out from Firebase after successful login');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error signing out from Firebase: $e');
                }
              }

              // Check if profile is complete before navigating
              if (mounted) {
                final isProfileComplete = authProvider.isProfileComplete();
                if (isProfileComplete) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.customerHome,
                    (route) => false,
                  );
                } else {
                  // Navigate to profile details screen if profile is incomplete
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.customerProfileDetails,
                    (route) => false,
                  );
                }
              }
            } else {
              final errorMessage = loginResult['message'] ?? 'Failed to login';

              // If backend login fails, sign out from Firebase to prevent auto-login on restart
              // This ensures the user is fully logged out when the backend doesn't recognize them
              try {
                await authProvider.signOut();
                if (kDebugMode) {
                  print(
                    '🔓 Signed out from Firebase after backend login failure',
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error signing out: $e');
                }
              }

              // Check if it's a network error
              if (loginResult['isNetworkError'] == true) {
                NetworkErrorDialog.show(context);
              } else {
                // Check if phone number is not registered
                if (errorMessage.toLowerCase().contains('not registered') ||
                    errorMessage.toLowerCase().contains('not found') ||
                    errorMessage.toLowerCase().contains('does not exist') ||
                    errorMessage.toLowerCase().contains('user not found')) {
                  _showPhoneNotRegisteredError();
                } else {
                  _showErrorMessage(errorMessage);
                }
              }
            }
          }
        } else {
          _showErrorMessage('Invalid verification code. Please try again.');
        }
      }
    } catch (e) {
      _showErrorMessage('Verification failed: $e');
    }
  }

  void _showSuccessMessage(String message) {
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
  }

  void _showErrorMessage(String message) {
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
  }

  void _showPhoneNotRegisteredError() {
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
  }
}

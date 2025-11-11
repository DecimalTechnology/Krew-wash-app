import 'dart:async';
import 'package:carwash_app/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4AA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
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
                    const Text(
                      'VERIFICATION',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4AA),
                        letterSpacing: 2,
                        fontFamily: '.SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 16),

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
                        fontFamily: '.SF Pro Text',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    _buildOtpFields(true),
                    const SizedBox(height: 24),

                    // Resend Code Button
                    _buildResendButton(true),
                    const SizedBox(height: 24),

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
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
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
                    const Text(
                      'VERIFICATION',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4AA),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    _buildOtpFields(false),
                    const SizedBox(height: 24),

                    // Resend Code Button
                    _buildResendButton(false),
                    const SizedBox(height: 24),

                    // Continue Button
                    _buildContinueButton(false),
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
          width: 45,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(isIOS ? 25 : 12),
          ),
          child: isIOS
              ? _buildIOSOtpField(index)
              : _buildAndroidOtpField(index),
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
        fontWeight: FontWeight.bold,
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

  Widget _buildAndroidOtpField(int index) {
    return TextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.zero,
      ),
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
                  onPressed:
                      authProvider.isLoading || _verificationCode.length != 6
                      ? null
                      : _verifyOtp,
                  child: Center(
                    child: authProvider.isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                            'CONTINUE',
                            style: TextStyle(
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
                    onTap:
                        authProvider.isLoading || _verificationCode.length != 6
                        ? null
                        : _verifyOtp,
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
                          : const Text(
                              'CONTINUE',
                              style: TextStyle(
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
        return isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _canResend && !authProvider.isLoading
                    ? _resendCode
                    : null,
                child: Text(
                  _canResend
                      ? 'RESEND CODE'
                      : 'RESEND CODE IN ${_resendTimer}s',
                  style: TextStyle(
                    color: _canResend
                        ? const Color(0xFF00D4AA)
                        : Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              )
            : TextButton(
                onPressed: _canResend && !authProvider.isLoading
                    ? _resendCode
                    : null,
                child: Text(
                  _canResend
                      ? 'RESEND CODE'
                      : 'RESEND CODE IN ${_resendTimer}s',
                  style: TextStyle(
                    color: _canResend
                        ? const Color(0xFF00D4AA)
                        : Colors.white.withOpacity(0.5),
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
              // Navigate to home screen
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.customerHome,
                  (route) => false,
                );
              }
            } else {
              _showErrorMessage(loginResult['message'] ?? 'Failed to login');
            }
          }
        } else {
          _showErrorMessage(
            result['message'] ?? 'Email OTP verification failed',
          );
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
              // Navigate to home screen
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.customerHome,
                  (route) => false,
                );
              }
            } else {
              final errorMessage = loginResult['message'] ?? 'Failed to login';
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
        } else {
          _showErrorMessage('Invalid verification code. Please try again.');
        }
      }
    } catch (e) {
      _showErrorMessage('Verification failed: $e');
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
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/network_error_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileOtpDialog extends StatefulWidget {
  final String phoneNumber;
  final String otpMethod;
  final String? verificationId;
  final String? email;
  final VoidCallback onVerified;
  final Future<Map<String, dynamic>> Function()? onResendEmail;
  final Future<dynamic> Function()? onResendPhone;

  const EditProfileOtpDialog({
    super.key,
    required this.phoneNumber,
    required this.otpMethod,
    this.verificationId,
    this.email,
    required this.onVerified,
    this.onResendEmail,
    this.onResendPhone,
  });

  @override
  State<EditProfileOtpDialog> createState() => _EditProfileOtpDialogState();
}

class _EditProfileOtpDialogState extends State<EditProfileOtpDialog> {
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
  bool _isVerifying = false;

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

  void _updateVerificationCode() {
    setState(() {
      _verificationCode = _controllers
          .map((controller) => controller.text)
          .join();
    });
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
        // Use custom resend function if provided, otherwise use auth provider
        if (widget.onResendEmail != null) {
          final result = await widget.onResendEmail!();
          if (result['success'] == true) {
            _showSuccessMessage('New OTP sent to your email');
          } else {
            _showErrorMessage(
              result['message'] ?? 'Failed to resend email OTP',
            );
            // Reset timer if failed
            setState(() {
              _canResend = true;
              _resendTimer = 0;
            });
            _timer?.cancel();
          }
        } else {
          final result = await authProvider.sendEmailOtp(email: widget.email!);
          if (result['success'] == true) {
            _showSuccessMessage('New OTP sent to your email');
          } else {
            _showErrorMessage(
              result['message'] ?? 'Failed to resend email OTP',
            );
            // Reset timer if failed
            setState(() {
              _canResend = true;
              _resendTimer = 0;
            });
            _timer?.cancel();
          }
        }
      } else {
        // Use custom resend function if provided, otherwise use auth provider
        if (widget.onResendPhone != null) {
          final result = await widget.onResendPhone!();
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
        } else {
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
    if (_verificationCode.length != 6 || _isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      if (widget.otpMethod == 'email') {
        // Handle email OTP verification
        final result = await authProvider.verifyEmailOtp(
          email: widget.email!,
          otp: _verificationCode,
        );

        if (result['success'] == true) {
          // Call the verified callback
          widget.onVerified();
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // Check if it's a network error
          if (result['isNetworkError'] == true) {
            if (mounted) {
              NetworkErrorDialog.show(context);
            }
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
          // Call the verified callback
          widget.onVerified();
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // Check if it's a network error
          if (result.errorMessage?.contains('network') == true ||
              result.errorMessage?.contains('internet') == true) {
            if (mounted) {
              NetworkErrorDialog.show(context);
            }
          } else {
            _showErrorMessage(
              result.errorMessage ?? 'Phone OTP verification failed',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying OTP: $e');
      }
      _showErrorMessage('Verification failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
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
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(isIOS ? 20 : 12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'VERIFICATION',
                style: AppTheme.bebasNeue(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF00D4AA),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                widget.otpMethod == 'email'
                    ? 'WE\'VE SENT YOU THE VERIFICATION CODE ON\n${widget.email}'
                    : 'WE\'VE SENT YOU THE VERIFICATION CODE ON\n${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // OTP Input Fields
              _buildOtpFields(isIOS),
              const SizedBox(height: 24),

              // Resend Code Button
              _buildResendButton(isIOS),
              const SizedBox(height: 24),

              // Continue Button
              _buildContinueButton(isIOS),
              const SizedBox(height: 8),

              // Cancel Button
              _buildCancelButton(isIOS),
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
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(isIOS ? 20 : 8),
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
        fontSize: 20,
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
    );
  }

  Widget _buildAndroidOtpField(int index) {
    return TextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w400,
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
    );
  }

  Widget _buildResendButton(bool isIOS) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed:
                    _canResend && !_isVerifying && !authProvider.isLoading
                    ? _resendCode
                    : null,
                child: Text(
                  _canResend
                      ? 'RESEND CODE'
                      : 'RESEND CODE IN ${_resendTimer}s',
                  style: AppTheme.bebasNeue(
                    color: _canResend
                        ? const Color(0xFF00D4AA)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              )
            : TextButton(
                onPressed:
                    _canResend && !_isVerifying && !authProvider.isLoading
                    ? _resendCode
                    : null,
                child: Text(
                  _canResend
                      ? 'RESEND CODE'
                      : 'RESEND CODE IN ${_resendTimer}s',
                  style: AppTheme.bebasNeue(
                    color: _canResend
                        ? const Color(0xFF00D4AA)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              );
      },
    );
  }

  Widget _buildContinueButton(bool isIOS) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4AA),
            borderRadius: BorderRadius.circular(isIOS ? 16 : 8),
          ),
          child: isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed:
                      (_isVerifying ||
                          authProvider.isLoading ||
                          _verificationCode.length != 6)
                      ? null
                      : _verifyOtp,
                  child: _isVerifying || authProvider.isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(
                          'VERIFY',
                          style: AppTheme.bebasNeue(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap:
                        (_isVerifying ||
                            authProvider.isLoading ||
                            _verificationCode.length != 6)
                        ? null
                        : _verifyOtp,
                    child: Center(
                      child: _isVerifying || authProvider.isLoading
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
                              'VERIFY',
                              style: AppTheme.bebasNeue(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
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

  Widget _buildCancelButton(bool isIOS) {
    return isIOS
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: AppTheme.bebasNeue(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          )
        : TextButton(
            onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: AppTheme.bebasNeue(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          );
  }
}

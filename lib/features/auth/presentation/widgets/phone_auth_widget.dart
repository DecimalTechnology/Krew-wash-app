import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PhoneAuthWidget extends StatefulWidget {
  final bool isSignIn;

  const PhoneAuthWidget({super.key, required this.isSignIn});

  @override
  State<PhoneAuthWidget> createState() => _PhoneAuthWidgetState();
}

class _PhoneAuthWidgetState extends State<PhoneAuthWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.isSignIn
                            ? 'Sign in with Phone'
                            : 'Sign up with Phone',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!_isCodeSent) ...[
                    // Phone number input
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+1234567890',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        prefixText: '+1 ',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Send code button
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
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
                              'Send Verification Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ] else ...[
                    // Verification code input
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        hintText: '123456',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.sms),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the verification code';
                        }
                        if (value.length != 6) {
                          return 'Please enter a 6-digit code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Verify code button
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
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
                              'Verify Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Resend code button
                    TextButton(
                      onPressed: authProvider.isLoading ? null : _resendCode,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Change phone number button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCodeSent = false;
                          _codeController.clear();
                        });
                      },
                      child: const Text(
                        'Change Phone Number',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],

                  // Error message
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final phoneNumber = '+1${_phoneController.text}';
      final result = await context
          .read<AuthProvider>()
          .sendPhoneVerificationCode(phoneNumber: phoneNumber);

      if (result.isSuccess) {
        setState(() {
          _isCodeSent = true;
          _verificationId = result.verificationId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your phone!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error handling is done in the provider
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_verificationId == null) return;

    try {
      final result = await context.read<AuthProvider>().verifyPhoneNumber(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error handling is done in the provider
    }
  }

  Future<void> _resendCode() async {
    await _sendVerificationCode();
  }
}

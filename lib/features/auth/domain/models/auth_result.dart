import 'user_model.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;
  final AuthMethod method;

  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    required this.method,
  });

  factory AuthResult.success({
    required UserModel user,
    required AuthMethod method,
  }) {
    return AuthResult(isSuccess: true, user: user, method: method);
  }

  factory AuthResult.failure({
    required String errorMessage,
    required AuthMethod method,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      method: method,
    );
  }
}

enum AuthMethod { email, google, phone }

class PhoneAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? verificationId;
  final int? resendToken;

  PhoneAuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.verificationId,
    this.resendToken,
  });

  factory PhoneAuthResult.success({
    required String verificationId,
    int? resendToken,
  }) {
    return PhoneAuthResult(
      isSuccess: true,
      verificationId: verificationId,
      resendToken: resendToken,
    );
  }

  factory PhoneAuthResult.failure({required String errorMessage}) {
    return PhoneAuthResult(isSuccess: false, errorMessage: errorMessage);
  }
}

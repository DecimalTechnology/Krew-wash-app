import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'network_error_utils.dart';

/// Utility class for showing network error dialogs
class NetworkErrorDialog {
  /// Shows a network error dialog based on the platform
  ///
  /// On iOS: Shows CupertinoAlertDialog
  /// On Android: Shows AlertDialog
  static void show(BuildContext context, {String? customMessage}) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final message = customMessage ?? NetworkErrorUtils.getNetworkErrorMessage();

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Network Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Network Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a network error snackbar (alternative to dialog)
  static void showSnackBar(BuildContext context, {String? customMessage}) {
    final message = customMessage ?? NetworkErrorUtils.getNetworkErrorMessage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Checks if error is network-related and shows appropriate dialog
  static void showIfNetworkError(BuildContext context, dynamic error) {
    if (NetworkErrorUtils.isNetworkError(error)) {
      show(context);
    }
  }

  /// Checks if error message is network-related and shows appropriate dialog
  static void showIfNetworkErrorString(
    BuildContext context,
    String? errorMessage,
  ) {
    if (NetworkErrorUtils.isNetworkErrorString(errorMessage)) {
      show(context);
    }
  }
}

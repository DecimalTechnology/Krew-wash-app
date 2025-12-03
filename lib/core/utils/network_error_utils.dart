/// Global utility class for detecting and handling network errors
class NetworkErrorUtils {
  /// Checks if an error is a network-related error
  ///
  /// This method detects various network error patterns including:
  /// - Socket exceptions
  /// - Connection timeouts
  /// - Host lookup failures
  /// - Route errors
  /// - HTTP client exceptions
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();

    // Network error patterns - check for these patterns in the error message
    final networkErrorPatterns = [
      'no route to host',
      'socketexception',
      'clientexception',
      'client exception',
      'network',
      'connection',
      'timeout',
      'failed host lookup',
      'errno = 113',
      'errno = 110',
      'errno = 111',
      'errno: 113',
      'errno: 110',
      'errno: 111',
      'connection refused',
      'connection reset',
      'connection timed out',
      'host lookup failed',
      'unable to resolve host',
      'check user request error',
      'check phone',
      'http exception',
      'io exception',
      'os error',
      'socket',
      'failed to check',
    ];

    // Check if any pattern matches
    final isNetwork = networkErrorPatterns.any(
      (pattern) => errorString.contains(pattern),
    );

    return isNetwork;
  }

  /// Checks if an error message string is a network error
  static bool isNetworkErrorString(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) return false;

    // Convert to lowercase for case-insensitive matching
    final errorLower = errorMessage.toLowerCase();

    // Network error patterns - check for these patterns in the error message
    final networkErrorPatterns = [
      'no route to host',
      'socketexception',
      'clientexception',
      'client exception',
      'network',
      'connection',
      'timeout',
      'failed host lookup',
      'errno = 113',
      'errno = 110',
      'errno = 111',
      'errno: 113',
      'errno: 110',
      'errno: 111',
      'connection refused',
      'connection reset',
      'connection timed out',
      'host lookup failed',
      'unable to resolve host',
      'check user request error',
      'check phone',
      'failed to check',
      'http exception',
      'io exception',
      'os error',
      'socket',
    ];

    // Check if any pattern matches
    final isNetwork = networkErrorPatterns.any(
      (pattern) => errorLower.contains(pattern),
    );

    return isNetwork;
  }

  /// Gets a user-friendly network error message
  static String getNetworkErrorMessage() {
    return 'Network connection error. Please check your internet connection and try again.';
  }

  /// Gets a user-friendly error message based on error type
  static String getErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return getNetworkErrorMessage();
    }
    return error.toString();
  }
}

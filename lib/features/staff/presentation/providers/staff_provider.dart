import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/models/staff_model.dart';
import '../../data/repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  StaffModel? _staff;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  // Dashboard data
  Map<String, dynamic>? _currentBooking;
  int _completedBookingCount = 0;
  int _upcomingBookingCount = 0;
  bool _isLoadingDashboard = false;
  String? _dashboardErrorMessage;

  // Getters
  StaffModel? get staff => _staff;
  bool get isAuthenticated => _staff != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Dashboard getters
  Map<String, dynamic>? get currentBooking => _currentBooking;
  int get completedBookingCount => _completedBookingCount;
  int get upcomingBookingCount => _upcomingBookingCount;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get dashboardErrorMessage => _dashboardErrorMessage;

  StaffProvider() {
    _initializeStaffAuth();
  }

  /// Initialize - restore staff from storage if available
  Future<void> _initializeStaffAuth() async {
    // Ensure splash screen shows for minimum duration (1.5 seconds)
    final initializationStart = DateTime.now();
    
    try {
      await _restoreStaffFromStorage();
    } finally {
      // Ensure minimum splash screen duration
      final elapsed = DateTime.now().difference(initializationStart);
      const minDuration = Duration(milliseconds: 1500);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Restore staff session from secure storage
  Future<void> _restoreStaffFromStorage() async {
    try {
      final staffDataJson = await SecureStorageService.getStaffData();
      final hasTokens = await SecureStorageService.isStaffLoggedIn();

      if (hasTokens && staffDataJson != null && staffDataJson.isNotEmpty) {
        try {
          final staffData = jsonDecode(staffDataJson) as Map<String, dynamic>;
          _staff = StaffModel.fromMap(staffData);
          if (kDebugMode) {
            print('✅ Staff restored from secure storage: ${_staff?.name}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing staff data from storage: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring staff from storage: $e');
      }
    }
  }

  /// Login cleaner with cleanerId and password
  Future<Map<String, dynamic>> loginCleaner({
    required String cleanerId,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await StaffRepository.loginCleaner(
        cleanerId: cleanerId,
        password: password,
      );

      if (result['success'] == true) {
        // Save staff data
        final staffData = result['data'] as Map<String, dynamic>;
        _staff = StaffModel.fromMap(staffData);

        // Save to secure storage
        final accessToken = result['accessToken'] as String?;
        if (accessToken != null) {
          await SecureStorageService.saveStaffTokens(accessToken: accessToken);
        }
        await SecureStorageService.saveStaffData(jsonEncode(_staff!.toMap()));

        if (kDebugMode) {
          print('✅ Staff login successful: ${_staff?.name}');
        }

        _setLoading(false);
        notifyListeners();
        return result;
      } else {
        _setError(result['message'] ?? 'Login failed');
        _setLoading(false);
        return result;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  /// Logout staff
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      // Clear all staff tokens and data from secure storage
      await SecureStorageService.clearStaffData();

      _staff = null;
      clearDashboardData(); // Clear dashboard data on logout
      _setLoading(false);
      notifyListeners();

      if (kDebugMode) {
        print('✅ Staff logged out successfully');
      }
    } catch (e) {
      _setError('Failed to logout');
      _setLoading(false);
    }
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Check if staff is logged in
  Future<bool> isLoggedInWithTokens() async {
    return await SecureStorageService.isStaffLoggedIn();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await SecureStorageService.getStaffAccessToken();
  }

  /// Fetch dashboard data (booking, completedBooking, upcomingBooking)
  Future<void> fetchDashboardData({bool force = false}) async {
    // Don't fetch if already loading
    if (_isLoadingDashboard) {
      return;
    }

    _isLoadingDashboard = true;
    _dashboardErrorMessage = null;
    notifyListeners();

    try {
      final accessToken = await SecureStorageService.getStaffAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _dashboardErrorMessage = 'Not authenticated';
        _isLoadingDashboard = false;
        notifyListeners();
        return;
      }

      final result = await StaffRepository.getDashboardData(
        accessToken: accessToken,
      );

      if (result['success'] == true) {
        // Store booking data
        _currentBooking = result['booking'] as Map<String, dynamic>?;
        _completedBookingCount = result['completedBooking'] as int? ?? 0;
        _upcomingBookingCount = result['upcomingBooking'] as int? ?? 0;

        if (kDebugMode) {
          print('\n✅ Dashboard data fetched and stored successfully');
          print(
            '   📋 Current Booking: ${_currentBooking != null ? _currentBooking!['bookingId'] ?? 'N/A' : 'None'}',
          );
          print('   ✅ Completed Bookings: $_completedBookingCount');
          print('   📅 Upcoming Bookings: $_upcomingBookingCount');

          if (_currentBooking != null) {
            print('\n   📋 Stored Booking Details:');
            print('      - Booking ID: ${_currentBooking!['bookingId']}');
            print('      - Status: ${_currentBooking!['status']}');
            print(
              '      - Vehicle: ${_currentBooking!['vehicleModel']} (${_currentBooking!['vehilceNumber'] ?? _currentBooking!['vehicleNumber']})',
            );
            final services = _currentBooking!['services'] as List? ?? [];
            if (services.isNotEmpty) {
              print('      - Services: ${services.join(', ')}');
            }
          }
          print('');
        }

        _dashboardErrorMessage = null;
      } else {
        _dashboardErrorMessage =
            result['message'] ?? 'Failed to fetch dashboard data';
        if (kDebugMode) {
          print('❌ Failed to fetch dashboard: ${_dashboardErrorMessage}');
        }
      }
    } catch (e) {
      _dashboardErrorMessage = 'An unexpected error occurred';
      if (kDebugMode) {
        print('❌ Error fetching dashboard: $e');
      }
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Clear dashboard data
  void clearDashboardData() {
    _currentBooking = null;
    _completedBookingCount = 0;
    _upcomingBookingCount = 0;
    _dashboardErrorMessage = null;
    notifyListeners();
  }
}

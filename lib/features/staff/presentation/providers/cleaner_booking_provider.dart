import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../data/repositories/cleaner_booking_repository.dart';
import '../../domain/models/booking_model.dart';

class CleanerBookingProvider extends ChangeNotifier {
  CleanerBookingProvider();

  final List<CleanerBooking> _assignedBookings = [];
  final List<CleanerBooking> _completedBookings = [];

  BookingPagination _assignedPagination = BookingPagination(
    page: 1,
    limit: 10,
    total: 0,
  );
  BookingPagination _completedPagination = BookingPagination(
    page: 1,
    limit: 10,
    total: 0,
  );

  CleanerBooking? _selectedBooking;

  bool _isAssignedLoading = false;
  bool _isCompletedLoading = false;
  bool _isDetailsLoading = false;
  String? _updatingSessionId; // Track which specific session is being updated

  bool _hasLoadedAssigned = false;
  bool _hasLoadedCompleted = false;

  String? _assignedError;
  String? _completedError;
  String? _detailsError;

  String _assignedSearch = '';
  String _completedSearch = '';

  // Getters
  List<CleanerBooking> get assignedBookings =>
      List.unmodifiable(_assignedBookings);
  List<CleanerBooking> get completedBookings =>
      List.unmodifiable(_completedBookings);
  CleanerBooking? get selectedBooking => _selectedBooking;

  BookingPagination get assignedPagination => _assignedPagination;
  BookingPagination get completedPagination => _completedPagination;

  bool get isAssignedLoading => _isAssignedLoading;
  bool get isCompletedLoading => _isCompletedLoading;
  bool get isDetailsLoading => _isDetailsLoading;
  bool isUpdatingSession(String sessionId) => _updatingSessionId == sessionId;

  String? get assignedError => _assignedError;
  String? get completedError => _completedError;
  String? get detailsError => _detailsError;

  String get assignedSearch => _assignedSearch;
  String get completedSearch => _completedSearch;

  int get todaysBookingsCount {
    final today = DateTime.now();
    return _assignedBookings
        .where((booking) => booking.isScheduledFor(today))
        .length;
  }

  Future<void> loadInitialData() async {
    if (_hasLoadedAssigned && _hasLoadedCompleted) return;
    await Future.wait([
      fetchAssignedBookings(force: !_hasLoadedAssigned),
      fetchCompletedBookings(force: !_hasLoadedCompleted),
    ]);
  }

  Future<void> fetchAssignedBookings({
    bool force = false,
    String? search,
  }) async {
    if (_isAssignedLoading) return;
    if (_hasLoadedAssigned && !force && search == null) return;

    _isAssignedLoading = true;
    _assignedError = null;
    if (search != null) {
      _assignedSearch = search;
    }
    notifyListeners();

    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      _assignedError = 'Missing access token. Please login again.';
      _isAssignedLoading = false;
      notifyListeners();
      return;
    }

    final response = await CleanerBookingRepository.fetchAssignedBookings(
      accessToken: token,
      search: _assignedSearch.isNotEmpty ? _assignedSearch : null,
    );

    if (response['success'] == true) {
      final dataList = response['data'] as List<dynamic>? ?? [];
      _assignedBookings
        ..clear()
        ..addAll(
          dataList.map(
            (raw) => CleanerBooking.fromMap(raw as Map<String, dynamic>),
          ),
        );
      _assignedPagination = BookingPagination.fromMap(
        response['pagination'] as Map<String, dynamic>?,
      );
      _hasLoadedAssigned = true;
    } else {
      _assignedError =
          response['message']?.toString() ?? 'Failed to load bookings';
    }

    _isAssignedLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompletedBookings({
    bool force = false,
    String? search,
  }) async {
    if (_isCompletedLoading) return;
    if (_hasLoadedCompleted && !force && search == null) return;

    _isCompletedLoading = true;
    _completedError = null;
    if (search != null) {
      _completedSearch = search;
    }
    notifyListeners();

    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      _completedError = 'Missing access token. Please login again.';
      _isCompletedLoading = false;
      notifyListeners();
      return;
    }

    final response = await CleanerBookingRepository.fetchCompletedBookings(
      accessToken: token,
      search: _completedSearch.isNotEmpty ? _completedSearch : null,
    );

    if (response['success'] == true) {
      final dataList = response['data'] as List<dynamic>? ?? [];
      _completedBookings
        ..clear()
        ..addAll(
          dataList.map(
            (raw) => CleanerBooking.fromMap(raw as Map<String, dynamic>),
          ),
        );
      _completedPagination = BookingPagination.fromMap(
        response['pagination'] as Map<String, dynamic>?,
      );
      _hasLoadedCompleted = true;
    } else {
      _completedError =
          response['message']?.toString() ?? 'Failed to load bookings';
    }

    _isCompletedLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookingDetails(String bookingId) async {
    if (_isDetailsLoading) return;
    _isDetailsLoading = true;
    _detailsError = null;
    notifyListeners();

    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      _detailsError = 'Missing access token. Please login again.';
      _isDetailsLoading = false;
      notifyListeners();
      return;
    }

    final response = await CleanerBookingRepository.fetchBookingById(
      accessToken: token,
      bookingId: bookingId,
    );

    if (response['success'] == true && response['data'] != null) {
      _selectedBooking = CleanerBooking.fromMap(
        response['data'] as Map<String, dynamic>,
      );
    } else {
      _detailsError =
          response['message']?.toString() ?? 'Failed to load booking';
    }

    _isDetailsLoading = false;
    notifyListeners();
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    _detailsError = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateSession({
    required String bookingId,
    required String sessionId,
    required String sessionType,
    String? addonId,
  }) async {
    if (_updatingSessionId != null) {
      return {'success': false, 'message': 'Update already in progress'};
    }

    _updatingSessionId = sessionId;
    notifyListeners();

    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      _updatingSessionId = null;
      notifyListeners();
      return {
        'success': false,
        'message': 'Missing access token. Please login again.',
      };
    }

    final response = await CleanerBookingRepository.updateSession(
      accessToken: token,
      bookingId: bookingId,
      sessionId: sessionId,
      sessionType: sessionType,
      addonId: addonId,
    );

    if (response['success'] == true && response['data'] != null) {
      try {
        // Handle case where data might be a String that needs parsing
        dynamic data = response['data'];
        Map<String, dynamic> bookingData;

        if (data is String) {
          bookingData = jsonDecode(data) as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          bookingData = data;
        } else {
          throw Exception('Invalid data type: ${data.runtimeType}');
        }

        // Update the selected booking if it matches
        if (_selectedBooking?.id == bookingId) {
          _selectedBooking = CleanerBooking.fromMap(bookingData);
        }
        // Also update in the assigned/completed lists if present
        _updateBookingInList(_assignedBookings, bookingId, bookingData);
        _updateBookingInList(_completedBookings, bookingId, bookingData);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error parsing booking data: $e');
        }
        _detailsError = 'Failed to parse updated booking data';
      }
    } else {
      // Store error message for snackbar display
      _detailsError =
          response['message']?.toString() ?? 'Failed to update session';
    }

    _updatingSessionId = null;
    notifyListeners();

    return response;
  }

  void _updateBookingInList(
    List<CleanerBooking> list,
    String bookingId,
    dynamic data,
  ) {
    final index = list.indexWhere((b) => b.id == bookingId);
    if (index != -1 && data != null) {
      list[index] = CleanerBooking.fromMap(data as Map<String, dynamic>);
    }
  }

  Future<void> refreshAll() async {
    _hasLoadedAssigned = false;
    _hasLoadedCompleted = false;
    await loadInitialData();
  }

  // Get session details
  Future<Map<String, dynamic>> getSession({
    required String bookingId,
    required String sessionId,
    required String sessionType,
    String? addonId,
  }) async {
    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Missing access token. Please login again.',
      };
    }

    final response = await CleanerBookingRepository.getSession(
      accessToken: token,
      bookingId: bookingId,
      sessionId: sessionId,
      sessionType: sessionType,
      addonId: addonId,
    );

    return response;
  }

  // Upload session image
  Future<Map<String, dynamic>> uploadSessionImage({
    required String bookingId,
    required String sessionId,
    required String sessionType,
    required String imagePath,
    String? addonId,
  }) async {
    final token = await SecureStorageService.getStaffAccessToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Missing access token. Please login again.',
      };
    }

    final response = await CleanerBookingRepository.uploadSessionImage(
      accessToken: token,
      bookingId: bookingId,
      sessionId: sessionId,
      sessionType: sessionType,
      imagePath: imagePath,
      addonId: addonId,
    );

    return response;
  }
}

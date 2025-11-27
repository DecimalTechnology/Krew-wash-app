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

  Future<void> refreshAll() async {
    _hasLoadedAssigned = false;
    _hasLoadedCompleted = false;
    await loadInitialData();
  }
}

import 'package:flutter/foundation.dart';

import '../../../staff/domain/models/booking_model.dart';
import '../../data/repositories/customer_booking_repository.dart';

class CustomerBookingProvider extends ChangeNotifier {
  CustomerBookingProvider({CustomerBookingRepository? repository})
    : _repository = repository ?? const CustomerBookingRepository();

  final CustomerBookingRepository _repository;

  final List<CleanerBooking> _bookings = [];
  CleanerBooking? _selectedBooking;

  bool _isLoading = false;
  bool _isDetailsLoading = false;
  String? _error;
  String? _detailsError;
  String _search = '';

  List<CleanerBooking> get bookings => List.unmodifiable(_bookings);
  CleanerBooking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  bool get isDetailsLoading => _isDetailsLoading;
  String? get error => _error;
  String? get detailsError => _detailsError;
  String get search => _search;

  Future<void> fetchBookings({bool force = false, String? search}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    if (search != null) _search = search;
    notifyListeners();

    final res = await _repository.getMyBookings(search: _search);
    if (res['success'] == true) {
      final list = (res['data'] as List?) ?? [];
      _bookings
        ..clear()
        ..addAll(
          list
              .whereType<Map>()
              .map((e) => CleanerBooking.fromMap(e.cast<String, dynamic>()))
              .toList(),
        );
    } else {
      _error = res['message']?.toString() ?? 'Failed to load bookings';
      _bookings.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookingDetails(String bookingId) async {
    if (_isDetailsLoading) return;
    _isDetailsLoading = true;
    _detailsError = null;
    notifyListeners();

    final res = await _repository.getBookingById(bookingId);
    if (res['success'] == true && res['data'] is Map) {
      _selectedBooking = CleanerBooking.fromMap(
        (res['data'] as Map).cast<String, dynamic>(),
      );
    } else {
      _detailsError = res['message']?.toString() ?? 'Failed to load booking';
      _selectedBooking = null;
    }

    _isDetailsLoading = false;
    notifyListeners();
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    _detailsError = null;
    notifyListeners();
  }

  /// Heuristic filter: treat bookings as "history" if status indicates completion/cancel,
  /// or if endDate is before now.
  bool isHistory(CleanerBooking booking) {
    final status = booking.status.toLowerCase();
    if (status.contains('complete') ||
        status.contains('completed') ||
        status.contains('cancel') ||
        status.contains('cancelled') ||
        status.contains('canceled') ||
        status.contains('failed')) {
      return true;
    }
    final end = booking.endDate;
    if (end != null && end.isBefore(DateTime.now())) return true;
    return false;
  }
}

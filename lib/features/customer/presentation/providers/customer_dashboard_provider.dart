import 'package:flutter/foundation.dart';
import '../../data/repositories/customer_dashboard_repository.dart';

class CustomerDashboardProvider extends ChangeNotifier {
  final CustomerDashboardRepository _repo = const CustomerDashboardRepository();

  // Dashboard data
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _buildings = [];
  bool _isLoadingDashboard = false;
  String? _dashboardErrorMessage;
  bool _isNetworkError = false;

  // Getters
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get packages => _packages;
  List<Map<String, dynamic>> get buildings => _buildings;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get dashboardErrorMessage => _dashboardErrorMessage;
  bool get isNetworkError => _isNetworkError;

  /// Fetch customer dashboard data (services, packages, buildings)
  Future<void> fetchDashboardData({bool force = false}) async {
    // Don't fetch if already loading
    if (_isLoadingDashboard) {
      return;
    }

    _isLoadingDashboard = true;
    _dashboardErrorMessage = null;
    _isNetworkError = false;
    notifyListeners();

    try {
      final result = await _repo.getDashboardData();

      if (result['success'] == true) {
        _services =
            (result['services'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _packages =
            (result['packages'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _buildings =
            (result['buildings'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        if (kDebugMode) {
          debugPrint(
            '\n✅ Customer Dashboard data fetched and stored successfully',
          );
          debugPrint('   📦 Services: ${_services.length}');
          debugPrint('   📋 Packages: ${_packages.length}');
          debugPrint('   🏢 Buildings: ${_buildings.length}');

          // Print detailed stored data
          if (_services.isNotEmpty) {
            debugPrint('\n   📦 Stored Services:');
            for (var service in _services) {
              debugPrint(
                '      - ${service['name']}: ${service['description']}',
              );
            }
          }

          if (_packages.isNotEmpty) {
            debugPrint('\n   📋 Stored Packages:');
            for (var package in _packages) {
              debugPrint(
                '      - ${package['name']} (${package['frequency']})',
              );
            }
          }

          if (_buildings.isNotEmpty) {
            debugPrint('\n   🏢 Stored Buildings:');
            for (var building in _buildings) {
              debugPrint('      - ${building['buildingName']}');
            }
          }
          debugPrint('');
        }

        _dashboardErrorMessage = null;
        _isNetworkError = false;
      } else {
        _dashboardErrorMessage =
            result['message'] ?? 'Failed to fetch dashboard data';
        _isNetworkError = result['isNetworkError'] == true;
        if (kDebugMode) {
          debugPrint('❌ Failed to fetch dashboard: $_dashboardErrorMessage');
          debugPrint('🌐 Is network error: $_isNetworkError');
        }
      }
    } catch (e) {
      _dashboardErrorMessage = 'An unexpected error occurred';
      _isNetworkError = false;
      if (kDebugMode) {
        debugPrint('❌ Error fetching dashboard: $e');
      }
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Clear dashboard data
  void clearDashboardData() {
    _services = [];
    _packages = [];
    _buildings = [];
    _dashboardErrorMessage = null;
    _isNetworkError = false;
    notifyListeners();
  }
}

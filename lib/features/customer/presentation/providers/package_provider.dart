import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/package_repository.dart';
import '../../domain/models/building_model.dart';

class PackageProvider extends ChangeNotifier {
  final PackageRepository _repo = const PackageRepository();

  String? _selectedCarTypeName;
  String? _selectedVehicleTypeId;
  int _selectedPackageIndex = -1;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _addOns = [];
  final Set<String> _selectedAddOnIds = {};

  // Vehicle types
  List<Map<String, String>> _vehicleTypes = [];
  bool _isFetchingVehicleTypes = false;

  // Building search state
  List<BuildingModel> _buildingResults = [];
  String? _selectedBuildingId;
  String? _selectedBuildingName;
  bool _isSearching = false;
  bool _isFetchingPackages = false;
  String _lastQuery = '';

  // Getters
  String get selectedCarType => _selectedCarTypeName ?? '';
  String? get selectedVehicleTypeId => _selectedVehicleTypeId;
  int get selectedPackageIndex => _selectedPackageIndex;
  List<Map<String, dynamic>> get packages => _packages;
  List<Map<String, dynamic>> get addOns => _addOns;
  List<Map<String, String>> get vehicleTypes => _vehicleTypes;
  bool get isFetchingVehicleTypes => _isFetchingVehicleTypes;
  Map<String, dynamic>? get selectedPackage =>
      _packages.isNotEmpty &&
          _selectedPackageIndex >= 0 &&
          _selectedPackageIndex < _packages.length
      ? _packages[_selectedPackageIndex]
      : null;
  Set<String> get selectedAddOnIds => _selectedAddOnIds;
  bool isAddOnSelected(String id) => _selectedAddOnIds.contains(id);
  List<BuildingModel> get buildingResults => _buildingResults;
  String? get selectedBuildingId => _selectedBuildingId;
  String? get selectedBuildingName => _selectedBuildingName;
  bool get isSearching => _isSearching;
  bool get isFetchingPackages => _isFetchingPackages;
  String get lastQuery => _lastQuery;

  Future<void> loadVehicleTypes() async {
    if (_vehicleTypes.isNotEmpty) return;
    _isFetchingVehicleTypes = true;
    notifyListeners();
    try {
      final types = await _repo.getVehicleTypes();
      _vehicleTypes = types;
      if (_vehicleTypes.isNotEmpty) {
        final first = _vehicleTypes.first;
        _selectedVehicleTypeId = first['id'];
        _selectedCarTypeName = first['name'];
      }
    } on TimeoutException {
      // Network timeout - keep existing types if any, otherwise empty
      if (_vehicleTypes.isEmpty) {
        _vehicleTypes = [];
      }
    } on SocketException {
      // Network error - keep existing types if any, otherwise empty
      if (_vehicleTypes.isEmpty) {
        _vehicleTypes = [];
      }
    } on http.ClientException {
      // Network error - keep existing types if any, otherwise empty
      if (_vehicleTypes.isEmpty) {
        _vehicleTypes = [];
      }
    } catch (e) {
      // Other errors - keep existing types if any, otherwise empty
      if (_vehicleTypes.isEmpty) {
        _vehicleTypes = [];
      }
    } finally {
      _isFetchingVehicleTypes = false;
      notifyListeners();
    }
  }

  void selectCarType({required String id, required String name}) {
    _selectedVehicleTypeId = id;
    _selectedCarTypeName = name;
    _selectedPackageIndex = -1;
    _selectedAddOnIds.clear();
    notifyListeners();
  }

  void selectPackage(int index) {
    if (index >= 0 && index < _packages.length) {
      _selectedPackageIndex = index;
      notifyListeners();
    }
  }

  void toggleAddOn(String addOnId) {
    if (addOnId.isEmpty) return;
    if (_selectedAddOnIds.contains(addOnId)) {
      _selectedAddOnIds.remove(addOnId);
    } else {
      _selectedAddOnIds.add(addOnId);
    }
    notifyListeners();
  }

  void resetSelection() {
    if (_vehicleTypes.isNotEmpty) {
      final first = _vehicleTypes.first;
      _selectedVehicleTypeId = first['id'];
      _selectedCarTypeName = first['name'];
    } else {
      _selectedVehicleTypeId = null;
      _selectedCarTypeName = null;
    }
    _selectedPackageIndex = -1;
    _packages = [];
    _addOns = [];
    _selectedAddOnIds.clear();
    notifyListeners();
  }

  Future<void> searchBuildings(String query) async {
    final trimmed = query.trim();
    // Allow empty search to show all buildings (useful for dropdown)
    _isSearching = true;
    _lastQuery = trimmed;
    _packages = [];
    _addOns = [];
    _selectedAddOnIds.clear();
    _selectedPackageIndex = -1;
    notifyListeners();
    try {
      _buildingResults = await _repo.searchBuildings(trimmed);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void selectBuilding({required String id, required String name}) {
    _selectedBuildingId = id;
    _selectedBuildingName = name;
    _packages = [];
    _addOns = [];
    _selectedAddOnIds.clear();
    _selectedPackageIndex = -1;
    notifyListeners();
  }

  Future<void> fetchPackagesForSelection({String? vehicleId}) async {
    final targetVehicleId = vehicleId ?? _selectedVehicleTypeId;
    if (_selectedBuildingId == null || targetVehicleId == null) return;

    // Update selection when explicit vehicleId provided
    if (vehicleId != null) {
      _selectedVehicleTypeId = vehicleId;
      final match = _vehicleTypes.firstWhere(
        (type) => type['id'] == vehicleId,
        orElse: () => <String, String>{},
      );
      if (match.isNotEmpty) {
        _selectedCarTypeName = match['name'];
      }
    }

    _isFetchingPackages = true;
    notifyListeners();
    try {
      final response = await _repo.getPackages(
        buildingId: _selectedBuildingId!,
        vehicleId: targetVehicleId,
      );
      _packages = response['packages'] ?? [];
      _addOns = response['addOns'] ?? [];
      _selectedPackageIndex = -1;
      _selectedAddOnIds.clear();
    } finally {
      _isFetchingPackages = false;
      notifyListeners();
    }
  }
}

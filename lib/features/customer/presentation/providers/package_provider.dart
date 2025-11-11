import 'package:flutter/material.dart';
import '../../data/repositories/package_repository.dart';
import '../../domain/models/building_model.dart';

class PackageProvider extends ChangeNotifier {
  final PackageRepository _repo = const PackageRepository();

  String? _selectedCarTypeName;
  String? _selectedVehicleTypeId;
  int _selectedPackageIndex = 0;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _addOns = [];

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
      _packages.isNotEmpty && _selectedPackageIndex < _packages.length
      ? _packages[_selectedPackageIndex]
      : null;
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
    } finally {
      _isFetchingVehicleTypes = false;
      notifyListeners();
    }
  }

  void selectCarType({required String id, required String name}) {
    _selectedVehicleTypeId = id;
    _selectedCarTypeName = name;
    _selectedPackageIndex = 0;
    notifyListeners();
  }

  void selectPackage(int index) {
    if (index >= 0 && index < _packages.length) {
      _selectedPackageIndex = index;
      notifyListeners();
    }
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
    _selectedPackageIndex = 0;
    _packages = [];
    _addOns = [];
    notifyListeners();
  }

  Future<void> searchBuildings(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _buildingResults = [];
      _isSearching = false;
      _lastQuery = '';
      _packages = [];
      _addOns = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    _lastQuery = trimmed;
    _packages = [];
    _addOns = [];
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
      _selectedPackageIndex = 0;
    } finally {
      _isFetchingPackages = false;
      notifyListeners();
    }
  }
}

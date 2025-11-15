import 'package:flutter/material.dart';

import '../../data/repositories/vehicle_repository.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleRepository _repository;

  VehicleProvider({VehicleRepository? repository})
    : _repository = repository ?? const VehicleRepository();

  List<Map<String, String>> _vehicleTypes = [];
  List<Map<String, String>> get vehicleTypes => _vehicleTypes;
  bool _isLoadingVehicleTypes = false;
  bool get isLoadingVehicleTypes => _isLoadingVehicleTypes;

  String? _selectedVehicleTypeId;
  String? get selectedVehicleTypeId => _selectedVehicleTypeId;

  String? _selectedVehicleTypeName;
  String? get selectedVehicleTypeName => _selectedVehicleTypeName;

  List<String> _vehicleModels = [];
  List<String> get vehicleModels => _vehicleModels;
  bool _isLoadingVehicleModels = false;
  bool get isLoadingVehicleModels => _isLoadingVehicleModels;

  String? _selectedVehicleModel;
  String? get selectedVehicleModel => _selectedVehicleModel;

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> get vehicles => _vehicles;
  bool _isLoadingVehicles = false;
  bool get isLoadingVehicles => _isLoadingVehicles;

  Future<void> loadVehicleTypes({bool forceRefresh = false}) async {
    if (_vehicleTypes.isNotEmpty && !forceRefresh) return;
    _isLoadingVehicleTypes = true;
    notifyListeners();
    try {
      final types = await _repository.getVehicleTypes();
      _vehicleTypes = types;
      if (!types.any((type) => type['id'] == _selectedVehicleTypeId)) {
        _selectedVehicleTypeId = null;
        _selectedVehicleTypeName = null;
        _vehicleModels = [];
        _selectedVehicleModel = null;
      }
    } finally {
      _isLoadingVehicleTypes = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicleModelsForType(String typeId) async {
    if (typeId.isEmpty) {
      _vehicleModels = [];
      _selectedVehicleModel = null;
      notifyListeners();
      return;
    }
    _isLoadingVehicleModels = true;
    _vehicleModels = [];
    _selectedVehicleModel = null;
    notifyListeners();
    try {
      final models = await _repository.getVehicleModelsByType(typeId);
      _vehicleModels = models;
    } finally {
      _isLoadingVehicleModels = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicles() async {
    _isLoadingVehicles = true;
    notifyListeners();
    try {
      final list = await _repository.getVehicles();
      _vehicles = list;
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  Future<void> selectVehicleType({
    required String id,
    required String name,
  }) async {
    if (_selectedVehicleTypeId == id) {
      _selectedVehicleTypeName = name;
      notifyListeners();
      return;
    }

    _selectedVehicleTypeId = id;
    _selectedVehicleTypeName = name;
    _vehicleModels = [];
    _selectedVehicleModel = null;
    notifyListeners();
    await loadVehicleModelsForType(id);
  }

  void selectVehicleModel(String model) {
    _selectedVehicleModel = model;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createVehicle({
    required String vehicleNumber,
    required String color,
    required String vehicleModel,
    required String parkingNumber,
    required String parkingArea,
  }) async {
    if (_selectedVehicleTypeId == null) {
      return {'success': false, 'message': 'Please select vehicle type'};
    }

    final response = await _repository.createVehicle(
      vehicleNumber: vehicleNumber,
      color: color,
      vehicleTypeId: _selectedVehicleTypeId!,
      vehicleModel: vehicleModel,
      parkingNumber: parkingNumber,
      parkingArea: parkingArea,
    );

    await loadVehicles();
    return response;
  }

  Future<Map<String, dynamic>> updateVehicle({
    required String vehicleId,
    required String vehicleNumber,
    required String color,
    required String vehicleModel,
    required String parkingNumber,
    required String parkingArea,
  }) async {
    if (_selectedVehicleTypeId == null) {
      return {'success': false, 'message': 'Please select vehicle type'};
    }

    final response = await _repository.updateVehicle(
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      color: color,
      vehicleTypeId: _selectedVehicleTypeId!,
      vehicleModel: vehicleModel,
      parkingNumber: parkingNumber,
      parkingArea: parkingArea,
    );

    await loadVehicles();
    return response;
  }

  Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    final response = await _repository.deleteVehicle(vehicleId);
    await loadVehicles();
    return response;
  }

  void reset() {
    _selectedVehicleTypeId = null;
    _selectedVehicleTypeName = null;
    _selectedVehicleModel = null;
    _vehicleModels = [];
    notifyListeners();
  }

  void clearVehicleSelection() {
    _selectedVehicleTypeId = null;
    _selectedVehicleTypeName = null;
    _selectedVehicleModel = null;
    _vehicleModels = [];
    notifyListeners();
  }
}

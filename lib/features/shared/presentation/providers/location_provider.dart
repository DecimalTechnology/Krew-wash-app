import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String? _currentLocation;
  String? _selectedBuilding;

  String? get currentLocation => _currentLocation;
  String? get selectedBuilding => _selectedBuilding;

  void setCurrentLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }

  void setSelectedBuilding(String building) {
    _selectedBuilding = building;
    notifyListeners();
  }
}

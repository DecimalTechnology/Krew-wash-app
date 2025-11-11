import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current location
  Future<void> getCurrentLocation() async {
    print('LocationProvider: Starting to get current location...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check and request permissions
      bool hasPermission = await _checkLocationPermission();
      print('LocationProvider: Permission granted: $hasPermission');
      if (!hasPermission) {
        _error = 'Location permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('LocationProvider: Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        _error = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      print('LocationProvider: Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      print(
        'LocationProvider: Position obtained: ${position.latitude}, ${position.longitude}',
      );
      _currentPosition = position;
      _error = null;
    } catch (e) {
      print('LocationProvider: Error getting location: $e');
      _error = 'Failed to get location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check and request location permission
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Start location tracking
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Get distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../../core/config/map_styles.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../providers/location_provider.dart';

class MapSectionWidget extends StatefulWidget {
  const MapSectionWidget({super.key});

  @override
  State<MapSectionWidget> createState() => _MapSectionWidgetState();
}

class _MapSectionWidgetState extends State<MapSectionWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.getCurrentLocation();

    if (locationProvider.currentPosition != null) {
      setState(() {
        _currentLocation = LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        );
        _addMarkers();
      });
    }
  }

  void _addMarkers() {
    if (_currentLocation != null) {
      // Add current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
        ),
      );

      // Add nearby car wash stations (sample locations)
      _markers.addAll(_getNearbyStations());
    }
  }

  Set<Marker> _getNearbyStations() {
    if (_currentLocation == null) return {};

    // Sample car wash station locations around the current position
    List<LatLng> stations = [
      LatLng(
        _currentLocation!.latitude + 0.01,
        _currentLocation!.longitude + 0.01,
      ),
      LatLng(
        _currentLocation!.latitude - 0.008,
        _currentLocation!.longitude + 0.015,
      ),
      LatLng(
        _currentLocation!.latitude + 0.012,
        _currentLocation!.longitude - 0.005,
      ),
      LatLng(
        _currentLocation!.latitude - 0.005,
        _currentLocation!.longitude - 0.012,
      ),
    ];

    return stations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng station = entry.value;

      return Marker(
        markerId: MarkerId('station_$index'),
        position: station,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Car Wash Station ${index + 1}',
          snippet: 'Available - Tap to book',
        ),
        onTap: () => _onStationTapped(index + 1),
      );
    }).toSet();
  }

  void _onStationTapped(int stationId) {
    // TODO: Navigate to booking screen with selected station
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Station $stationId selected'),
        backgroundColor: const Color(0xFF00AAD4),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 15.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.customerMapFullScreen);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        height: 350,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Google Map
              Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  if (locationProvider.isLoading) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00AAD4),
                          ),
                        ),
                      ),
                    );
                  }

                  if (locationProvider.error != null) {
                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_off,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Location Error',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              locationProvider.error!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _initializeMap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AAD4),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_currentLocation == null) {
                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00AAD4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading Map...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${_currentLocation?.latitude ?? "Getting..."}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Lng: ${_currentLocation?.longitude ?? "Getting..."}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GoogleMap(
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                      // ignore: deprecated_member_use
                      await controller.setMapStyle(MapStyles.darkMapStyle);
                      print(
                        'Real-time map created successfully with dark theme!',
                      );
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                    buildingsEnabled: true,
                    trafficEnabled: false,
                    onTap: (LatLng position) {
                      print(
                        'Map tapped at: ${position.latitude}, ${position.longitude}',
                      );
                    },
                  );
                },
              ),
              // Charging Stations Label
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00AAD4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'OVER 20+ CAR WASH STATIONS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // My Location Button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF00AAD4),
                  onPressed: _goToCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

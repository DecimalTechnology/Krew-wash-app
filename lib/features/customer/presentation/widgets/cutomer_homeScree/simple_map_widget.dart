import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/config/map_styles.dart';
import '../../../../../core/theme/app_theme.dart';

class SimpleMapWidget extends StatefulWidget {
  const SimpleMapWidget({super.key});

  @override
  State<SimpleMapWidget> createState() => _SimpleMapWidgetState();
}

class _SimpleMapWidgetState extends State<SimpleMapWidget> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  // Default location (Dubai, UAE)
  static const LatLng _defaultLocation = LatLng(25.2048, 55.2708);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Map
            GoogleMap(
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                // ignore: deprecated_member_use
                await controller.setMapStyle(MapStyles.darkMapStyle);
                setState(() {
                  _isMapReady = true;
                });
                print('Simple map created successfully with dark theme!');
              },
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 13.0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              buildingsEnabled: true,
              trafficEnabled: false,
              markers: {
                const Marker(
                  markerId: MarkerId('default_location'),
                  position: _defaultLocation,
                  infoWindow: InfoWindow(
                    title: 'Krew Car Wash - Dubai',
                    snippet: 'Tap to book your slot',
                  ),
                ),
              },
              onTap: (LatLng position) {
                print(
                  'Map tapped at: ${position.latitude}, ${position.longitude}',
                );
              },
            ),

            // Loading overlay
            if (!_isMapReady)
              Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00AAD4),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Map...',
                        style: AppTheme.bebasNeue(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    const Icon(
                      Icons.local_car_wash,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'CAR WASH STATIONS',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../providers/location_provider.dart';
import '../../../../core/config/map_styles.dart';

class FullScreenMapPage extends StatefulWidget {
  const FullScreenMapPage({super.key});

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};
  LatLng? _currentLocation;
  List<CarWashStation> _stations = [];
  List<CarWashStation> _filteredStations = [];
  bool _isSearching = false;
  String _selectedFilter = 'All';
  CarWashStation? _selectedStation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _createStations();
        _filteredStations = List.from(_stations);
        _addMarkers();
      });
    }
  }

  void _createStations() {
    if (_currentLocation == null) return;

    _stations = [
      CarWashStation(
        id: 'station_1',
        name: 'Krew Car Wash - Premium',
        address: '123 Main Street, Downtown',
        latitude: _currentLocation!.latitude + 0.01,
        longitude: _currentLocation!.longitude + 0.01,
        type: CarWashType.premium,
        rating: 4.8,
        price: 25.0,
        isAvailable: true,
        services: [
          'Exterior Wash',
          'Interior Cleaning',
          'Waxing',
          'Tire Shine',
        ],
      ),
      CarWashStation(
        id: 'station_2',
        name: 'Krew Car Wash - Express',
        address: '456 Oak Avenue, Uptown',
        latitude: _currentLocation!.latitude - 0.008,
        longitude: _currentLocation!.longitude + 0.015,
        type: CarWashType.express,
        rating: 4.5,
        price: 15.0,
        isAvailable: true,
        services: ['Quick Wash', 'Vacuum', 'Tire Shine'],
      ),
      CarWashStation(
        id: 'station_3',
        name: 'Krew Car Wash - Deluxe',
        address: '789 Park Lane, Midtown',
        latitude: _currentLocation!.latitude + 0.012,
        longitude: _currentLocation!.longitude - 0.005,
        type: CarWashType.deluxe,
        rating: 4.9,
        price: 35.0,
        isAvailable: false,
        services: [
          'Premium Wash',
          'Full Interior',
          'Waxing',
          'Polish',
          'Engine Cleaning',
        ],
      ),
      CarWashStation(
        id: 'station_4',
        name: 'Krew Car Wash - Basic',
        address: '321 River Road, Suburb',
        latitude: _currentLocation!.latitude - 0.005,
        longitude: _currentLocation!.longitude - 0.012,
        type: CarWashType.basic,
        rating: 4.2,
        price: 10.0,
        isAvailable: true,
        services: ['Basic Wash', 'Vacuum'],
      ),
      CarWashStation(
        id: 'station_5',
        name: 'Krew Car Wash - Premium Plus',
        address: '555 Beach Boulevard, Coastside',
        latitude: _currentLocation!.latitude + 0.015,
        longitude: _currentLocation!.longitude + 0.008,
        type: CarWashType.premium,
        rating: 4.7,
        price: 30.0,
        isAvailable: true,
        services: ['Full Service', 'Detailing', 'Ceramic Coating'],
      ),
    ];
  }

  void _addMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentLocation != null) {
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
    }

    // Add filtered station markers
    for (final station in _filteredStations) {
      final distance = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        station.latitude,
        station.longitude,
      );

      _markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: _getMarkerIcon(station),
          infoWindow: InfoWindow(
            title: station.name,
            snippet:
                '${station.rating}★ - \$${station.price} - ${distance.toStringAsFixed(1)}km',
          ),
          onTap: () => _showStationDetails(station),
        ),
      );
    }

    setState(() {});
  }

  BitmapDescriptor _getMarkerIcon(CarWashStation station) {
    Color markerColor;
    switch (station.type) {
      case CarWashType.premium:
        markerColor = Colors.purple;
        break;
      case CarWashType.deluxe:
        markerColor = Colors.orange;
        break;
      case CarWashType.express:
        markerColor = Colors.green;
        break;
      case CarWashType.basic:
        markerColor = Colors.blue;
        break;
    }

    return BitmapDescriptor.defaultMarkerWithHue(_colorToHue(markerColor));
  }

  double _colorToHue(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(_degreesToRadians(lat1)) *
            math.sin(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan(math.sqrt(a) / math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _searchStations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStations = List.from(_stations);
        _addMarkers();
      });
      return;
    }

    setState(() {
      _filteredStations = _stations
          .where(
            (station) =>
                station.name.toLowerCase().contains(query.toLowerCase()) ||
                station.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      _addMarkers();
    });
  }

  void _filterByType(String type) {
    setState(() {
      _selectedFilter = type;
      if (type == 'All') {
        _filteredStations = List.from(_stations);
      } else {
        _filteredStations = _stations
            .where(
              (station) =>
                  station.type.toString().split('.').last.toLowerCase() ==
                  type.toLowerCase(),
            )
            .toList();
      }
      _addMarkers();
    });
  }

  void _showStationDetails(CarWashStation station) {
    setState(() {
      _selectedStation = station;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStationDetailsSheet(station),
    );
  }

  Widget _buildStationDetailsSheet(CarWashStation station) {
    final distance = _calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      station.latitude,
      station.longitude,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_car_wash,
                        color: station.isAvailable ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              station.address,
                              style: AppTheme.bebasNeue(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: station.isAvailable
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          station.isAvailable ? 'Available' : 'Busy',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '${station.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF00AAD4),
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${station.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF00AAD4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Services Available:',
                    style: AppTheme.bebasNeue(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: station.services
                        .map((service) => _buildServiceChip(service))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Type:',
                    style: AppTheme.bebasNeue(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    station.type.toString().split('.').last.toUpperCase(),
                    style: AppTheme.bebasNeue(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: station.isAvailable
                          ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Booking ${station.name}...'),
                                  backgroundColor: const Color(0xFF00AAD4),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AAD4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        station.isAvailable ? 'Book Now' : 'Currently Busy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00AAD4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00AAD4).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00AAD4), size: 16),
          SizedBox(width: 6),
          Text(
            service,
            style: const TextStyle(
              color: Color(0xFF00AAD4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              if (locationProvider.isLoading || _currentLocation == null) {
                return Container(
                  color: Colors.grey[900],
                  child: Center(
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
                        SizedBox(height: 16),
                        Text(
                          'Location Error',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          locationProvider.error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AAD4),
                          ),
                          child: Text('Retry'),
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
                    'Full-screen map created successfully with dark theme!',
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
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                trafficEnabled: false,
              );
            },
          ),

          // Top Search Bar and Filters
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      StandardBackButton(
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search car wash stations...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _searchStations,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: const Color(0xFF00AAD4),
                        ),
                        onPressed: () {
                          if (_isSearching) {
                            _searchController.clear();
                            _searchStations('');
                          }
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Premium'),
                      _buildFilterChip('Deluxe'),
                      _buildFilterChip('Express'),
                      _buildFilterChip('Basic'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Buttons
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'location',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _goToCurrentLocation,
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF00AAD4),
                  ),
                ),
                SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'list',
                  mini: true,
                  backgroundColor: const Color(0xFF00AAD4),
                  onPressed: () {
                    _showStationsList();
                  },
                  child: const Icon(Icons.list, color: Colors.white),
                ),
              ],
            ),
          ),

          // Station Counter
          Positioned(
            bottom: 24,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_car_wash,
                    color: Color(0xFF00AAD4),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${_filteredStations.length} Stations',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _filterByType(label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF00AAD4),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }

  void _showStationsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Nearby Stations',
                    style: AppTheme.bebasNeue(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredStations.length} found',
                    style: AppTheme.bebasNeue(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredStations.length,
                itemBuilder: (context, index) {
                  final station = _filteredStations[index];
                  final distance = _calculateDistance(
                    _currentLocation!.latitude,
                    _currentLocation!.longitude,
                    station.latitude,
                    station.longitude,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: station.isAvailable
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Icon(
                        Icons.local_car_wash,
                        color: station.isAvailable ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      title: Text(
                        station.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text('${station.rating}'),
                              SizedBox(width: 12),
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF00AAD4),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text('${distance.toStringAsFixed(1)} km'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${station.price}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF00AAD4),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: station.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              station.isAvailable ? 'Open' : 'Busy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showStationDetails(station);
                        _goToStation(station);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToStation(CarWashStation station) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(station.latitude, station.longitude),
          zoom: 16.0,
        ),
      ),
    );
  }
}

// Data models
class CarWashStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final CarWashType type;
  final double rating;
  final double price;
  final bool isAvailable;
  final List<String> services;

  CarWashStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.rating,
    required this.price,
    required this.isAvailable,
    required this.services,
  });
}

enum CarWashType { basic, express, deluxe, premium }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../presentation/providers/vehicle_provider.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleProvider(repository: const VehicleRepository()),
      child: const _CarListView(),
    );
  }
}

class _CarListView extends StatefulWidget {
  const _CarListView();

  @override
  State<_CarListView> createState() => _CarListViewState();
}

class _CarListViewState extends State<_CarListView> {
  late final ScrollController _scrollController;
  Timer? _refreshDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VehicleProvider>();
      provider.loadVehicleTypes();
      provider.loadVehicles();
    });
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshVehicles(VehicleProvider provider) async {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 200), () {
      provider.loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        final vehicles = provider.vehicles;
        final isLoading = provider.isLoadingVehicles;

        final content = Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/CustomerHome/homebg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isIOS, screenWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshVehicles(provider),
                    color: const Color(0xFF04CDFE),
                    backgroundColor: Colors.black,
                    child: isLoading && vehicles.isEmpty
                        ? const _LoadingState()
                        : vehicles.isEmpty
                        ? const _EmptyState()
                        : SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                ...vehicles.map(
                                  (vehicle) => _VehicleCard(
                                    vehicle: vehicle,
                                    screenWidth: screenWidth,
                                    onDelete: () async {
                                      final vehicleId = vehicle['_id']
                                          ?.toString();
                                      if (vehicleId == null ||
                                          vehicleId.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Vehicle id missing'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        return;
                                      }

                                      final confirmed =
                                          await _showDeleteConfirmation(
                                            context,
                                          );
                                      if (confirmed != true) return;

                                      final response = await provider
                                          .deleteVehicle(vehicleId);
                                      final success =
                                          response['success'] == true;
                                      final message =
                                          (response['message'] ??
                                                  (success
                                                      ? 'Vehicle deleted successfully'
                                                      : 'Failed to delete vehicle'))
                                              .toString();

                                      if (!mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor: success
                                              ? const Color(0xFF00D4AA)
                                              : Colors.redAccent,
                                        ),
                                      );

                                      if (success) {
                                        await provider.loadVehicles();
                                        if (mounted) {
                                          await _showDeleteResult(
                                            context,
                                            response,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                _buildAddNewCarButton(context, isIOS),
                                SizedBox(height: screenWidth > 400 ? 40 : 30),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );

        return isIOS
            ? CupertinoPageScaffold(
                backgroundColor: Colors.black,
                child: content,
              )
            : Scaffold(backgroundColor: Colors.black, body: content);
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isIOS, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenWidth > 400 ? 50 : 40,
            height: screenWidth > 400 ? 50 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(screenWidth > 400 ? 25 : 20),
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: screenWidth > 400 ? 24 : 20,
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        screenWidth > 400 ? 25 : 20,
                      ),
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: screenWidth > 400 ? 24 : 20,
                      ),
                    ),
                  ),
          ),
          const Spacer(),
          Text(
            'MY CARS',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 400 ? 22 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildAddNewCarButton(BuildContext context, bool isIOS) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 1,
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.customerAddNewCar);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF04CDFE),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF04CDFE,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ADD NEW CAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.customerAddNewCar);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04CDFE),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF04CDFE,
                      ).withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      'ADD NEW CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Remove vehicle?'),
          content: const Text(
            'Are you sure you want to delete this vehicle from your list?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11162A),
        title: const Text(
          'Remove vehicle?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this vehicle from your list?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteResult(
    BuildContext context,
    Map<String, dynamic> response,
  ) async {
    final message =
        response['message']?.toString() ?? 'Vehicle deleted successfully';
    final data = response['data'];
    Map<String, dynamic>? dataMap;
    if (data is Map<String, dynamic>) {
      dataMap = data;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11162A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Response',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (dataMap != null && dataMap.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Vehicle Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dataMap.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (entry.value ?? '--').toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04CDFE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('CLOSE'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.screenWidth,
    required this.onDelete,
  });

  final Map<String, dynamic> vehicle;
  final double screenWidth;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final vehicleType = vehicle['type']?.toString().toUpperCase() ?? 'CAR';
    final vehicleNumber = vehicle['vehicleNumber']?.toString() ?? '--';
    final company = _extractCompany(vehicle);
    final model = vehicle['vehicleModel']?.toString() ?? '--';
    final color = vehicle['color']?.toString();
    final parkingNumber = vehicle['parkingNumber']?.toString();
    final parkingArea = vehicle['parkingArea']?.toString();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 24.0 : 20.0,
        vertical: screenWidth > 400 ? 20.0 : 16.0,
      ),
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF04CDFE).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: screenWidth > 400 ? 20 : 18,
                  ),
                  SizedBox(width: screenWidth > 400 ? 8 : 6),
                  Text(
                    vehicleType,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth > 400 ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete vehicle',
              ),
            ],
          ),
          SizedBox(height: screenWidth > 400 ? 20 : 16),
          _buildInfoRow('VEHICLE NUMBER', vehicleNumber, screenWidth),
          SizedBox(height: screenWidth > 400 ? 16 : 12),
          _buildInfoRow('COMPANY', company, screenWidth),
          SizedBox(height: screenWidth > 400 ? 16 : 12),
          _buildInfoRow('MODEL', model, screenWidth),
          if (color != null && color.isNotEmpty) ...[
            SizedBox(height: screenWidth > 400 ? 16 : 12),
            _buildInfoRow('COLOR', color, screenWidth),
          ],
          if ((parkingNumber != null && parkingNumber.isNotEmpty) ||
              (parkingArea != null && parkingArea.isNotEmpty)) ...[
            SizedBox(height: screenWidth > 400 ? 16 : 12),
            _buildInfoRow(
              'PARKING',
              [parkingNumber, parkingArea]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(' • '),
              screenWidth,
            ),
          ],
        ],
      ),
    );
  }

  String _extractCompany(Map<String, dynamic> vehicle) {
    final company = vehicle['company'];
    if (company != null && company.toString().isNotEmpty) {
      return company.toString();
    }
    final type = vehicle['type']?.toString() ?? '';
    if (type.isNotEmpty) {
      return type.split(' ').first;
    }
    return '--';
  }

  Widget _buildInfoRow(String label, String value, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth > 400 ? 16 : 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth > 400 ? 16 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFF04CDFE)),
            SizedBox(height: 16),
            Text(
              'Loading vehicles...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car_filled, color: Colors.white30, size: 48),
            SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Add New Car" to add your vehicle.',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

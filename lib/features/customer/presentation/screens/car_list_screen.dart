import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
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

        // Check if we're in MainNavigationScreen (as a tab) or pushed as separate screen
        // If pushed from profile screen using rootNavigator, we're above MainNavigationScreen
        // so bottom nav won't be visible. Check by seeing if we can pop from non-root navigator
        final nonRootNavigator = Navigator.of(context, rootNavigator: false);
        final isInMainNavAsTab = !nonRootNavigator.canPop();

        // Calculate bottom padding for button
        // Only add bottom nav bar height if we're in MainNavigationScreen as a tab
        final bottomNavBarHeight = isInMainNavAsTab
            ? (screenWidth < 350
                  ? 60.0 + 12.0 * 2
                  : screenWidth >= 350 && screenWidth < 400
                  ? 65.0 + 14.0 * 2
                  : screenWidth > 600
                  ? 80.0 + 20.0 * 2
                  : 70.0 + 16.0 * 2)
            : 0.0;
        final bottomPadding =
            bottomNavBarHeight + MediaQuery.of(context).padding.bottom + 16;

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
                // Show error message if there's a network error
                if (provider.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: isLoading && vehicles.isEmpty
                      ? _buildLoadingStateWithRefresh(context, isIOS, provider)
                      : vehicles.isEmpty
                      ? _buildEmptyStateWithRefresh(isIOS, provider, context)
                      : RefreshIndicator(
                          onRefresh: () async => _refreshVehicles(provider),
                          color: const Color(0xFF04CDFE),
                          backgroundColor: Colors.black,
                          child: SingleChildScrollView(
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
                                      }
                                    },
                                  ),
                                ),
                                _buildAddNewCarButton(context, isIOS),
                                SizedBox(height: bottomPadding),
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
    final provider = context.watch<VehicleProvider>();
    final isLoading = provider.isLoadingVehicles;

    return Padding(
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StandardBackButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final didPop = await navigator.maybePop();
              if (!didPop) {
                // Fallback to root navigator if this one cannot pop
                final rootNavigator = Navigator.of(
                  context,
                  rootNavigator: true,
                );
                if (rootNavigator != navigator) {
                  await rootNavigator.maybePop();
                }
              }
            },
          ),
          Expanded(
            child: Text(
              'MY CARS',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: screenWidth > 400 ? 22 : 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Refresh button
          if (isIOS)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: isLoading
                  ? null
                  : () {
                      provider.loadVehicles();
                    },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF04CDFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 10,
                      )
                    : const Icon(
                        CupertinoIcons.arrow_clockwise,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            )
          else
            IconButton(
              onPressed: isLoading
                  ? null
                  : () {
                      provider.loadVehicles();
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF04CDFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddNewCarButton(BuildContext context, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 1,
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      // Use rootNavigator to push above MainNavigationScreen
                      // This will hide the bottom navigation bar
                      final result = await Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(Routes.customerAddNewCar);
                      if (!mounted) return;
                      if (result == true) {
                        final provider = context.read<VehicleProvider>();
                        await provider.loadVehicles();
                      }
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
                      child: Center(
                        child: Text(
                          'ADD NEW CAR',
                          style: AppTheme.bebasNeue(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      // Use rootNavigator to push above MainNavigationScreen
                      // This will hide the bottom navigation bar
                      final result = await Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(Routes.customerAddNewCar);
                      if (!mounted) return;
                      if (result == true) {
                        final provider = context.read<VehicleProvider>();
                        await provider.loadVehicles();
                      }
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
                    child: Text(
                      'ADD NEW CAR',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStateWithRefresh(
    BuildContext context,
    bool isIOS,
    VehicleProvider provider,
  ) {
    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => provider.loadVehicles(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(color: Color(0xFF04CDFE)),
                    const SizedBox(height: 16),
                    Text(
                      'Loading vehicles...',
                      style: AppTheme.bebasNeue(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        color: const Color(0xFF04CDFE),
        onRefresh: () => provider.loadVehicles(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF04CDFE)),
                    const SizedBox(height: 16),
                    Text(
                      'Loading vehicles...',
                      style: AppTheme.bebasNeue(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyStateWithRefresh(
    bool isIOS,
    VehicleProvider provider,
    BuildContext context,
  ) {
    if (isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => provider.loadVehicles(),
          ),
          SliverFillRemaining(hasScrollBody: false, child: const _EmptyState()),
        ],
      );
    } else {
      return RefreshIndicator(
        color: const Color(0xFF04CDFE),
        onRefresh: () => provider.loadVehicles(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: const _EmptyState(),
          ),
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text('Remove vehicle?'),
          content: Text(
            'Are you sure you want to delete this vehicle from your list?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop(false);
                }
              },
              isDefaultAction: true,
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              isDestructiveAction: true,
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF11162A),
        title: Text(
          'Remove vehicle?',
          style: AppTheme.bebasNeue(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this vehicle from your list?',
          style: AppTheme.bebasNeue(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(dialogContext).pop(false);
              }
            },
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: Text(
              'DELETE',
              style: AppTheme.bebasNeue(color: Colors.redAccent),
            ),
          ),
        ],
      ),
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
    final color = vehicle['color']?.toString() ?? '';
    final parkingNumber = vehicle['parkingNumber']?.toString() ?? '--';

    // Build vehicle name (Company + Model)
    final vehicleName = [company, model]
        .where((value) => value.isNotEmpty && value != '--')
        .map((value) => value.toUpperCase())
        .join(' ');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 24.0 : 20.0,
        vertical: screenWidth > 400 ? 20.0 : 16.0,
      ),
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  vehicleName.isNotEmpty ? vehicleName : 'VEHICLE',
                  style: AppTheme.bebasNeue(
                    color: const Color(0xFF04CDFE),
                    fontSize: screenWidth > 400 ? 18 : 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete vehicle',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: screenWidth > 400 ? 20 : 16),
          _buildInfoRow('TYPE', vehicleType, screenWidth),
          SizedBox(height: screenWidth > 400 ? 12 : 10),
          _buildInfoRow('NUMBER', vehicleNumber, screenWidth),
          SizedBox(height: screenWidth > 400 ? 12 : 10),
          _buildInfoRow(
            'COLOR',
            color.isNotEmpty ? color.toUpperCase() : '--',
            screenWidth,
          ),
          SizedBox(height: screenWidth > 400 ? 12 : 10),
          _buildInfoRow('PARKING NUMBER', parkingNumber, screenWidth),
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
        Text(
          label,
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: screenWidth > 400 ? 14 : 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: screenWidth > 400 ? 14 : 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_car_filled,
            color: Colors.white30,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'No vehicles found',
            style: AppTheme.bebasNeue(color: Colors.white54, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first vehicle to get started.',
            style: AppTheme.bebasNeue(color: Colors.white38, fontSize: 14),
          ),
          SizedBox(height: 32),
          if (isIOS)
            Builder(
              builder: (buttonContext) => CupertinoButton(
                onPressed: () async {
                  // Use rootNavigator to push above MainNavigationScreen
                  // This will hide the bottom navigation bar
                  final result = await Navigator.of(
                    buttonContext,
                    rootNavigator: true,
                  ).pushNamed(Routes.customerAddNewCar);
                  if (result == true) {
                    final provider = buttonContext.read<VehicleProvider>();
                    await provider.loadVehicles();
                  }
                },
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                child: Text(
                  'ADD NEW CAR',
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )
          else
            Builder(
              builder: (buttonContext) => ElevatedButton(
                onPressed: () async {
                  // Use rootNavigator to push above MainNavigationScreen
                  // This will hide the bottom navigation bar
                  final result = await Navigator.of(
                    buttonContext,
                    rootNavigator: true,
                  ).pushNamed(Routes.customerAddNewCar);
                  if (result == true) {
                    final provider = buttonContext.read<VehicleProvider>();
                    await provider.loadVehicles();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04CDFE),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ADD NEW CAR',
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

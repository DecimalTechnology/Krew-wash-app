import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/route_constants.dart';
import '../../presentation/providers/package_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/building_model.dart';
import '../../data/repositories/package_repository.dart';
import 'package_details_screen.dart';

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedBuilding;
  bool _initializedFromProfile = false;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final packageProvider = context.read<PackageProvider>();
      await packageProvider.loadVehicleTypes();
      await _initializeWithSavedBuilding();
    });
  }

  Future<void> _initializeWithSavedBuilding() async {
    final authProvider = context.read<AuthProvider>();
    final packageProvider = context.read<PackageProvider>();

    Future<void> initFromUser() async {
      if (_initializedFromProfile) return;
      final user = authProvider.user;
      if (user?.buildingId == null || user!.buildingId!.isEmpty) return;
      _initializedFromProfile = true;

      final buildingId = user.buildingId!;
      String buildingName = 'Selected Building';
      try {
        final repo = const PackageRepository();
        final buildings = await repo.searchBuildings('');
        final match = buildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () =>
              BuildingModel(id: buildingId, buildingName: buildingName),
        );
        buildingName = match.buildingName;
      } catch (_) {}

      packageProvider.selectBuilding(id: buildingId, name: buildingName);
      if (mounted) {
        setState(() {
          _selectedBuilding = buildingName;
        });
      }

      String? vehicleId = packageProvider.selectedVehicleTypeId;
      if (vehicleId == null && packageProvider.vehicleTypes.isNotEmpty) {
        final firstType = packageProvider.vehicleTypes.first;
        vehicleId = firstType['id'];
        if (vehicleId != null && vehicleId.isNotEmpty) {
          packageProvider.selectCarType(
            id: vehicleId,
            name: firstType['name'] ?? '',
          );
        }
      }

      if (vehicleId != null && vehicleId.isNotEmpty) {
        await packageProvider.fetchPackagesForSelection(vehicleId: vehicleId);
      }
    }

    if (!authProvider.isInitializing && authProvider.user != null) {
      await initFromUser();
    } else {
      _authListener = () async {
        if (!authProvider.isInitializing && authProvider.user != null) {
          await initFromUser();
          if (_authListener != null) {
            authProvider.removeListener(_authListener!);
            _authListener = null;
          }
        }
      };
      authProvider.addListener(_authListener!);
    }
  }

  @override
  void dispose() {
    final authProvider = mounted ? context.read<AuthProvider>() : null;
    if (_authListener != null && authProvider != null) {
      authProvider.removeListener(_authListener!);
      _authListener = null;
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate screen ratio
    final screenRatio = screenWidth / screenHeight;
    final isWideScreen = screenRatio > 0.6; // Landscape or wide screens
    final isTallScreen = screenRatio < 0.5; // Very tall screens

    // Responsive sizing based on screen width, height, and ratio
    final isSmallScreen = screenWidth < 350 || screenHeight < 600;
    final isMediumScreen =
        (screenWidth >= 350 && screenWidth < 400) ||
        (screenHeight >= 600 && screenHeight < 700);
    final isLargeScreen =
        (screenWidth >= 400 && screenWidth < 600) ||
        (screenHeight >= 700 && screenHeight < 900);
    final isTablet = screenWidth > 600 || screenHeight > 900;
    final isUltraWide = screenWidth > 800;

    return isIOS
        ? _buildIOSPackageScreen(
            screenWidth,
            screenHeight,
            isSmallScreen,
            isMediumScreen,
            isLargeScreen,
            isTablet,
            isUltraWide,
            isWideScreen,
            isTallScreen,
          )
        : _buildAndroidPackageScreen(
            screenWidth,
            screenHeight,
            isSmallScreen,
            isMediumScreen,
            isLargeScreen,
            isTablet,
            isUltraWide,
            isWideScreen,
            isTallScreen,
          );
  }

  Widget _buildIOSPackageScreen(
    double screenWidth,
    double screenHeight,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
    bool isTablet,
    bool isUltraWide,
    bool isWideScreen,
    bool isTallScreen,
  ) {
    final horizontalPadding = _getResponsiveValue(
      small: 16.0,
      medium: 20.0,
      large: 24.0,
      tablet: 28.0,
      ultraWide: 32.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final verticalSpacing = _getResponsiveValue(
      small: 16.0,
      medium: 20.0,
      large: 24.0,
      tablet: 28.0,
      ultraWide: 32.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final packageCardPadding = _getResponsiveValue(
      small: 12.0,
      medium: 16.0,
      large: 20.0,
      tablet: 24.0,
      ultraWide: 28.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final fontSize = _getResponsiveValue(
      small: 14.0,
      medium: 16.0,
      large: 18.0,
      tablet: 20.0,
      ultraWide: 22.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    // Adjust for screen ratio
    final adjustedHorizontalPadding = isWideScreen
        ? horizontalPadding * 1.2
        : horizontalPadding;
    final adjustedVerticalSpacing = isTallScreen
        ? verticalSpacing * 0.8
        : verticalSpacing;
    final adjustedFontSize = isWideScreen ? fontSize * 1.1 : fontSize;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomScrollPadding =
        bottomInset + kBottomNavigationBarHeight + adjustedVerticalSpacing;

    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Package/packagebg.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xCC000000), // Black with 80% opacity at top
              Color(0x33000000), // Black with 20% opacity in middle
              Color(0xCC000000), // Black with 80% opacity at bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Sliver App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  pinned: false,
                  expandedHeight: 0,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  flexibleSpace: _buildSliverHeader(true),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Car Type Selection
                      _buildSearchAndAddressFields(
                        true,
                        adjustedHorizontalPadding,
                        adjustedVerticalSpacing,
                        adjustedFontSize,
                      ),
                      // Car Type Selection
                      _buildCarTypeSelection(
                        true,
                        adjustedHorizontalPadding,
                        adjustedFontSize,
                      ),

                      // Section Title
                      _buildSectionTitle(
                        true,
                        adjustedHorizontalPadding,
                        adjustedFontSize,
                      ),

                      // Package Options
                      _buildPackageOptions(
                        true,
                        adjustedHorizontalPadding,
                        adjustedVerticalSpacing,
                        packageCardPadding,
                        adjustedFontSize,
                      ),

                      SizedBox(height: adjustedVerticalSpacing),

                      _buildAddOnsSection(
                        isIOS: true,
                        horizontalPadding: adjustedHorizontalPadding,
                        fontSize: adjustedFontSize,
                      ),

                      SizedBox(height: adjustedVerticalSpacing),

                      _buildNextButton(
                        isIOS: true,
                        horizontalPadding: adjustedHorizontalPadding,
                        fontSize: adjustedFontSize,
                      ),

                      SizedBox(height: bottomScrollPadding),

                      // Proceed Button (scrollable) - positioned above bottom nav bar
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidPackageScreen(
    double screenWidth,
    double screenHeight,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
    bool isTablet,
    bool isUltraWide,
    bool isWideScreen,
    bool isTallScreen,
  ) {
    // Calculate responsive values (same as iOS)
    final horizontalPadding = _getResponsiveValue(
      small: 16.0,
      medium: 20.0,
      large: 24.0,
      tablet: 28.0,
      ultraWide: 32.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final verticalSpacing = _getResponsiveValue(
      small: 16.0,
      medium: 20.0,
      large: 24.0,
      tablet: 28.0,
      ultraWide: 32.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final packageCardPadding = _getResponsiveValue(
      small: 12.0,
      medium: 16.0,
      large: 20.0,
      tablet: 24.0,
      ultraWide: 28.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    final fontSize = _getResponsiveValue(
      small: 14.0,
      medium: 16.0,
      large: 18.0,
      tablet: 20.0,
      ultraWide: 22.0,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      isLargeScreen: isLargeScreen,
      isTablet: isTablet,
      isUltraWide: isUltraWide,
    );

    // Adjust for screen ratio
    final adjustedHorizontalPadding = isWideScreen
        ? horizontalPadding * 1.2
        : horizontalPadding;
    final adjustedVerticalSpacing = isTallScreen
        ? verticalSpacing * 0.8
        : verticalSpacing;
    final adjustedFontSize = isWideScreen ? fontSize * 1.1 : fontSize;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomScrollPadding =
        bottomInset + kBottomNavigationBarHeight + adjustedVerticalSpacing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Package/packagebg.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xCC000000), // Black with 80% opacity at top
              Color(0x33000000), // Black with 20% opacity in middle
              Color(0xCC000000), // Black with 80% opacity at bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Sliver App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  pinned: false,
                  expandedHeight: 0,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  flexibleSpace: _buildSliverHeader(false),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Car Type Selection
                      _buildSearchAndAddressFields(
                        false,
                        adjustedHorizontalPadding,
                        adjustedVerticalSpacing,
                        adjustedFontSize,
                      ),
                      // Car Type Selection
                      _buildCarTypeSelection(
                        false,
                        adjustedHorizontalPadding,
                        adjustedFontSize,
                      ),

                      // Section Title
                      _buildSectionTitle(
                        false,
                        adjustedHorizontalPadding,
                        adjustedFontSize,
                      ),

                      // Package Options
                      _buildPackageOptions(
                        false,
                        adjustedHorizontalPadding,
                        adjustedVerticalSpacing,
                        packageCardPadding,
                        adjustedFontSize,
                      ),

                      SizedBox(height: adjustedVerticalSpacing),

                      _buildAddOnsSection(
                        isIOS: false,
                        horizontalPadding: adjustedHorizontalPadding,
                        fontSize: adjustedFontSize,
                      ),

                      SizedBox(height: adjustedVerticalSpacing),

                      _buildNextButton(
                        isIOS: false,
                        horizontalPadding: adjustedHorizontalPadding,
                        fontSize: adjustedFontSize,
                      ),

                      SizedBox(height: bottomScrollPadding),

                      // Proceed Button (scrollable) - positioned above bottom nav bar
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndAddressFields(
    bool isIOS,
    double horizontalPadding,
    double verticalSpacing,
    double fontSize,
  ) {
    final provider = context.watch<PackageProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 400;

    final fieldHeight = isLargeScreen ? 52.0 : 46.0;
    final cornerRadius = isLargeScreen ? 14.0 : 12.0;
    final textSize = isLargeScreen ? (fontSize * 1.0) : (fontSize * 0.9);

    final buildingName = _selectedBuilding ?? provider.selectedBuildingName;
    final buildingText = (buildingName != null && buildingName.isNotEmpty)
        ? buildingName
        : 'Building not set';

    final showShimmer = provider.isFetchingVehicleTypes && buildingName == null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalSpacing * 0.6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showShimmer)
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                height: textSize,
                width: fontSize * 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            Text(
              'BUILDING NAME',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: textSize * 0.9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          SizedBox(
            height: isLargeScreen
                ? verticalSpacing * 0.6
                : verticalSpacing * 0.4,
          ),
          if (showShimmer)
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
            )
          else
            Container(
              height: fieldHeight,
              decoration: BoxDecoration(
                color: const Color(0x8001031C),
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 16 : 12,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                buildingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSection({
    required bool isIOS,
    required double horizontalPadding,
    required double fontSize,
  }) {
    final provider = context.watch<PackageProvider>();
    final addOns = provider.addOns;
    final isLoading = provider.isFetchingPackages;

    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize * 1.1,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );

    final cardPadding = EdgeInsets.symmetric(
      vertical: fontSize * 0.6,
      horizontal: fontSize * 0.8,
    );

    Widget buildPlaceholder() {
      return Column(
        children: List.generate(2, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: fontSize * 0.8),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                height: fontSize * 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF01061C),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }),
      );
    }

    List<Widget> buildAddOnCards() {
      if (addOns.isEmpty) {
        return [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: fontSize),
            child: const Text(
              'No add-ons available for this vehicle type.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ];
      }

      return addOns.map((addOn) {
        final addOnId = addOn['id']?.toString() ?? '';
        final isSelected =
            addOnId.isNotEmpty && provider.isAddOnSelected(addOnId);
        final name = addOn['name']?.toString() ?? 'ADD-ON';
        final description = addOn['description']?.toString() ?? '';
        final frequency = addOn['frequency']?.toString() ?? '';
        final price = addOn['price']?.toString() ?? '0 AED';

        return Padding(
          padding: EdgeInsets.only(bottom: fontSize * 0.8),
          child: GestureDetector(
            onTap: addOnId.isEmpty
                ? null
                : () {
                    provider.toggleAddOn(addOnId);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF041227)
                    : const Color(0xFF01061C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF04CDFE)
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF04CDFE,
                    ).withOpacity(isSelected ? 0.3 : 0.2),
                    blurRadius: isSelected ? 14 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: cardPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFF04CDFE),
                            fontSize: fontSize * 1.1,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (frequency.isNotEmpty) ...[
                          SizedBox(height: fontSize * 0.3),
                          Text(
                            frequency,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: fontSize * 0.75,
                            ),
                          ),
                        ],
                        if (description.isNotEmpty) ...[
                          SizedBox(height: fontSize * 0.4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: fontSize * 0.75,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EACH SERVICE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: fontSize * 0.7,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: fontSize * 0.3),
                      Text(
                        price,
                        style: TextStyle(
                          color: const Color(0xFF04CDFE),
                          fontSize: fontSize * 1.2,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: fontSize * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT ADD-ONS', style: titleStyle),
          SizedBox(height: fontSize * 0.8),
          if (isLoading && addOns.isEmpty)
            buildPlaceholder()
          else
            ...buildAddOnCards(),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(child: _buildHeaderContent(isIOS)),
    );
  }

  Widget _buildHeaderContent(bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarTypeSelection(
    bool isIOS,
    double horizontalPadding,
    double fontSize,
  ) {
    final provider = context.watch<PackageProvider>();
    final vehicleTypes = provider.vehicleTypes;
    final isLoadingTypes = provider.isFetchingVehicleTypes;
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;
    final isLargeScreen = screenWidth >= 400 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    final buttonHeight = isSmallScreen
        ? 50.0
        : isMediumScreen
        ? 55.0
        : isLargeScreen
        ? 60.0
        : isTablet
        ? 70.0
        : 65.0;

    final vehicleTextSize = isSmallScreen
        ? fontSize * 0.7
        : isMediumScreen
        ? fontSize * 0.8
        : isLargeScreen
        ? fontSize * 0.9
        : isTablet
        ? fontSize * 1.0
        : fontSize * 0.95;

    final iconSize = isSmallScreen
        ? fontSize * 0.8
        : isMediumScreen
        ? fontSize * 0.9
        : isLargeScreen
        ? fontSize * 1.0
        : isTablet
        ? fontSize * 1.1
        : fontSize * 1.05;

    final buttonSpacing = isSmallScreen
        ? fontSize * 0.1
        : isMediumScreen
        ? fontSize * 0.15
        : isLargeScreen
        ? fontSize * 0.2
        : isTablet
        ? fontSize * 0.25
        : fontSize * 0.22;

    final internalPadding = isSmallScreen
        ? fontSize * 0.6
        : isMediumScreen
        ? fontSize * 0.7
        : isLargeScreen
        ? fontSize * 0.8
        : isTablet
        ? fontSize * 1.0
        : fontSize * 0.9;

    Widget buildPlaceholder() {
      return Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonSpacing),
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.08),
                highlightColor: Colors.white.withOpacity(0.25),
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    Widget buildContent() {
      if (vehicleTypes.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: fontSize),
          alignment: Alignment.center,
          child: const Text(
            'No vehicle types available',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return Row(
        children: vehicleTypes.map((vehicleType) {
          final typeId = vehicleType['id'] ?? '';
          final typeName = vehicleType['name'] ?? '';
          final isSelected = provider.selectedVehicleTypeId == typeId;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonSpacing),
              child: GestureDetector(
                onTap: () async {
                  if (typeId.isEmpty) return;
                  provider.selectCarType(id: typeId, name: typeName);
                  if (provider.selectedBuildingId != null) {
                    await provider.fetchPackagesForSelection(vehicleId: typeId);
                  }
                },
                child: Container(
                  height: buttonHeight,
                  padding: EdgeInsets.symmetric(horizontal: internalPadding),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF04CDFE).withOpacity(0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF04CDFE)
                          : Colors.white.withOpacity(0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          typeName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: vehicleTextSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: fontSize * 0.4),
                      Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: fontSize * 0.8,
      ),
      child: isLoadingTypes && vehicleTypes.isEmpty
          ? buildPlaceholder()
          : buildContent(),
    );
  }

  Widget _buildSectionTitle(
    bool isIOS,
    double horizontalPadding,
    double fontSize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: fontSize * 0.8,
      ),
      child: Text(
        'SELECT YOUR PACKAGE',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize * 1.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPackageOptions(
    bool isIOS,
    double horizontalPadding,
    double verticalSpacing,
    double cardPadding,
    double fontSize,
  ) {
    final provider = context.watch<PackageProvider>();
    final isLoading = provider.isFetchingPackages;
    final dataSource = provider.packages;

    if (isLoading) {
      return _buildPackageLoadingState(
        horizontalPadding: horizontalPadding,
        verticalSpacing: verticalSpacing,
        cardPadding: cardPadding,
        fontSize: fontSize,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: dataSource.isEmpty
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: verticalSpacing),
              child: const Text(
                'No packages to show. Select a building to continue.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: dataSource.asMap().entries.map((entry) {
                final index = entry.key;
                final package = entry.value;
                final isSelected = provider.selectedPackageIndex == index;

                return Padding(
                  padding: EdgeInsets.only(bottom: verticalSpacing),
                  child: GestureDetector(
                    onTap: () {
                      provider.selectPackage(index);
                    },
                    child: Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00D4AA),
                                width: 2,
                              )
                            : Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Package Name and Description
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Package Name
                                Text(
                                  (package['name'] ?? 'Package').toUpperCase(),
                                  style: TextStyle(
                                    color: const Color(0xFF04CDFE),
                                    fontSize: fontSize * 1.1,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: fontSize * 0.5),
                                // Description
                                Text(
                                  package['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize * 0.85,
                                    fontWeight: FontWeight.normal,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: cardPadding),

                          // Right side - Frequency and Price
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Frequency
                                Text(
                                  (package['frequency'] ?? '').toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize * 0.9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                                SizedBox(height: fontSize * 0.5),
                                // Price
                                Text(
                                  package['price'] ?? '0 AED',
                                  style: TextStyle(
                                    color: const Color(0xFF04CDFE),
                                    fontSize: fontSize * 1.1,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPackageLoadingState({
    required double horizontalPadding,
    required double verticalSpacing,
    required double cardPadding,
    required double fontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: verticalSpacing),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: fontSize * 1.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: fontSize * 0.5),
                          Container(
                            height: fontSize * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(height: fontSize * 0.3),
                          Container(
                            height: fontSize * 0.7,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: cardPadding),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: fontSize * 0.8,
                            width: fontSize * 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(height: fontSize * 0.4),
                          Container(
                            height: fontSize * 0.9,
                            width: fontSize * 3.5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNextButton({
    required bool isIOS,
    required double horizontalPadding,
    required double fontSize,
  }) {
    final provider = context.watch<PackageProvider>();
    final hasPackageSelected =
        provider.selectedPackageIndex >= 0 && provider.selectedPackage != null;
    final hasAddOnSelected = provider.selectedAddOnIds.isNotEmpty;
    final shouldShowButton = hasPackageSelected || hasAddOnSelected;

    if (!shouldShowButton) {
      return const SizedBox.shrink();
    }

    final button = SizedBox(
      width: double.infinity,
      height: fontSize * 3.2,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04CDFE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'NEXT',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize * 0.95,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: isIOS ? button : button,
    );
  }

  void _handleNext() {
    final provider = context.read<PackageProvider>();
    final selectedPackage = provider.selectedPackage;
    final selectedAddOns = provider.addOns.where((addOn) {
      final id = addOn['id']?.toString();
      if (id == null) return false;
      return provider.selectedAddOnIds.contains(id);
    }).toList();

    Navigator.pushNamed(
      context,
      Routes.customerPackageDetails,
      arguments: PackageDetailsArguments(
        package: selectedPackage,
        selectedAddOns: selectedAddOns,
        buildingName: provider.selectedBuildingName,
        vehicleTypeName: provider.selectedCarType,
      ),
    );
  }

  double _getResponsiveValue({
    required double small,
    required double medium,
    required double large,
    required double tablet,
    required double ultraWide,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
    required bool isTablet,
    required bool isUltraWide,
  }) {
    if (isUltraWide) return ultraWide;
    if (isTablet) return tablet;
    if (isLargeScreen) return large;
    if (isMediumScreen) return medium;
    return small;
  }
}

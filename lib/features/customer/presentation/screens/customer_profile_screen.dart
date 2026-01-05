import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../presentation/providers/package_provider.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/package_repository.dart';
import '../../domain/models/building_model.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String? _buildingName;
  String? _lastBuildingId;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // First, try to get building ID from AuthProvider (most up-to-date)
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      String? buildingId = user?.buildingId;

      // If not available from AuthProvider, try ProfileRepository
      if (buildingId == null || buildingId.isEmpty) {
        final profileRepo = const ProfileRepository();
        final profileData = await profileRepo.getProfile();
        if (profileData['success'] != false) {
          buildingId = profileData['buildingId']?.toString();
        }
      }

      if (buildingId == null || buildingId.isEmpty) {
        return; // No building ID available
      }

      // At this point, buildingId is guaranteed to be non-null
      final buildingIdString = buildingId;

      // Check PackageProvider first (might already have the building name)
      if (mounted) {
        try {
          final packageProvider = context.read<PackageProvider>();
          if (packageProvider.selectedBuildingId == buildingIdString &&
              (packageProvider.selectedBuildingName ?? '').isNotEmpty) {
            setState(() {
              _buildingName = packageProvider.selectedBuildingName;
            });
            return;
          }
        } catch (_) {
          // Continue to fetch from API
        }
      }

      // Fetch building name by searching buildings
      // Try multiple search strategies to find the building
      final repo = const PackageRepository();
      List<BuildingModel> buildings = [];

      // Strategy 1: Try searching with building ID (in case API supports ID search)
      try {
        buildings = await repo.searchBuildings(buildingIdString);
        final building = buildings.firstWhere(
          (b) => b.id == buildingIdString,
          orElse: () => BuildingModel(id: buildingIdString, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _buildingName = building.buildingName;
          });
          return;
        }
      } catch (_) {
        // Continue to next strategy
      }

      // Strategy 2: Try searching with common characters to get all buildings
      // Try 'a' first (most common starting letter)
      try {
        buildings = await repo.searchBuildings('a');
        var building = buildings.firstWhere(
          (b) => b.id == buildingIdString,
          orElse: () => BuildingModel(id: buildingIdString, buildingName: ''),
        );
        if (building.buildingName.isEmpty) {
          // Try 'e' if 'a' didn't work
          buildings = await repo.searchBuildings('e');
          building = buildings.firstWhere(
            (b) => b.id == buildingIdString,
            orElse: () => BuildingModel(id: buildingIdString, buildingName: ''),
          );
        }
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _buildingName = building.buildingName;
          });
          return;
        }
      } catch (_) {
        // Continue to next strategy
      }

      // Strategy 3: Try empty search (might return all buildings)
      try {
        buildings = await repo.searchBuildings('');
        final building = buildings.firstWhere(
          (b) => b.id == buildingIdString,
          orElse: () => BuildingModel(id: buildingIdString, buildingName: ''),
        );
        if (building.buildingName.isNotEmpty && mounted) {
          setState(() {
            _buildingName = building.buildingName;
          });
        }
      } catch (_) {
        // Ignore errors - building name will remain null
      }
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;

    // Debug print to check screen size detection
    print(
      'Profile Screen - Screen width: $screenWidth, isLargeScreen: $isLargeScreen',
    );

    if (Platform.isIOS) {
      return _buildIOSScreen(context, isLargeScreen);
    } else {
      return _buildAndroidScreen(context, isLargeScreen);
    }
  }

  Widget _buildIOSScreen(BuildContext context, bool isLargeScreen) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Background Images
          _buildBackgroundImages(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildIOSHeader(context, isLargeScreen),

                  // Profile Title
                  _buildProfileTitle(isLargeScreen),

                  // Profile Avatar
                  _buildProfileAvatar(isLargeScreen),

                  // Profile Information Card
                  _buildProfileCard(isLargeScreen),

                  // Edit Profile Button
                  _buildEditProfileButton(context, isLargeScreen),

                  // History and My Cars Buttons (side by side)
                  _buildHistoryAndCarsButtons(context, isLargeScreen),

                  // Logout Button
                  _buildLogoutButton(context, isLargeScreen),

                  SizedBox(height: isLargeScreen ? 60 : 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidScreen(BuildContext context, bool isLargeScreen) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Images
          _buildBackgroundImages(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildAndroidHeader(context, isLargeScreen),

                  // Profile Title
                  _buildProfileTitle(isLargeScreen),

                  // Profile Avatar
                  _buildProfileAvatar(isLargeScreen),

                  // Profile Information Card
                  _buildProfileCard(isLargeScreen),

                  // Edit Profile Button
                  _buildEditProfileButton(context, isLargeScreen),

                  // History and My Cars Buttons (side by side)
                  _buildHistoryAndCarsButtons(context, isLargeScreen),

                  // Logout Button
                  _buildLogoutButton(context, isLargeScreen),

                  SizedBox(height: isLargeScreen ? 60 : 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isLargeScreen) {
    final isIOS = Platform.isIOS;
    // Dark maroon background and bright coral-red border/text
    const darkMaroon = Color(0xFF5A1A1A); // Dark deep red/maroon background
    const coralRed = Color(
      0xFFFF6B6B,
    ); // Bright coral-red for border, text, and icon

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showLogoutDialog(context, isIOS),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 16.0 : 12.0,
                  horizontal: isLargeScreen ? 24.0 : 16.0,
                ),
                decoration: BoxDecoration(
                  color: darkMaroon,
                  borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                  border: Border.all(color: coralRed, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_right_circle_fill,
                      color: coralRed,
                      size: isLargeScreen ? 20 : 18,
                    ),
                    SizedBox(width: isLargeScreen ? 12 : 8),
                    Text(
                      'LOGOUT',
                      style: AppTheme.bebasNeue(
                        color: coralRed,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ElevatedButton(
              onPressed: () => _showLogoutDialog(context, isIOS),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: coralRed,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 16.0 : 12.0,
                  horizontal: isLargeScreen ? 24.0 : 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                  side: BorderSide(color: coralRed, width: 1.5),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: coralRed,
                    size: isLargeScreen ? 20 : 18,
                  ),
                  SizedBox(width: isLargeScreen ? 12 : 8),
                  Text(
                    'LOGOUT',
                    style: AppTheme.bebasNeue(
                      color: coralRed,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isIOS) {
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                final rootNav = Navigator.of(context, rootNavigator: true);
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  rootNav.pushNamedAndRemoveUntil(
                    Routes.authWrapper,
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text('Logout', style: AppTheme.bebasNeue(color: Colors.white)),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.bebasNeue(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: Text(
                'Cancel',
                style: AppTheme.bebasNeue(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                final rootNav = Navigator.of(context, rootNavigator: true);
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  rootNav.pushNamedAndRemoveUntil(
                    Routes.authWrapper,
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                'Logout',
                style: AppTheme.bebasNeue(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBackgroundImages() {
    return Stack(
      children: [
        // Top Background - Car Interior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/CustomerProfile/image1.png'),
                fit: BoxFit.fitHeight,
                opacity: 0.3,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
        // Bottom Background - Car Exterior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/CustomerProfile/image2.png'),
                fit: BoxFit.fitWidth,
                opacity: 0.3,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIOSHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          StandardBackButton(
            onPressed: () {
              // Navigate to customer home screen with tab index 0
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                Routes.customerHome,
                (route) => false,
                arguments: 0, // Set bottom navbar index to 0 (Home tab)
              );
            },
          ),
          // Settings Icon
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.customerSettings);
            },
            child: Container(
              width: isLargeScreen ? 50 : 40,
              height: isLargeScreen ? 50 : 40,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              ),
              child: Icon(
                CupertinoIcons.settings,
                color: CupertinoColors.white,
                size: isLargeScreen ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          StandardBackButton(
            onPressed: () {
              // Navigate to customer home screen with tab index 0
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                Routes.customerHome,
                (route) => false,
                arguments: 0, // Set bottom navbar index to 0 (Home tab)
              );
            },
          ),
          // Settings Icon
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.customerSettings);
            },
            child: Container(
              width: isLargeScreen ? 50 : 40,
              height: isLargeScreen ? 50 : 40,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              ),
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: isLargeScreen ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTitle(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 20.0 : 10.0),
      child: Text(
        'PROFILE',
        style: AppTheme.bebasNeue(
          fontSize: isLargeScreen ? 28 : 24,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isLargeScreen) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final photoUrl = user?.photo;

        return Container(
          width: isLargeScreen ? 100 : 80,
          height: isLargeScreen ? 100 : 80,
          margin: EdgeInsets.symmetric(vertical: isLargeScreen ? 20.0 : 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isLargeScreen ? 50 : 40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: photoUrl != null && photoUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 50 : 40),
                  child: Image.network(
                    photoUrl,
                    width: isLargeScreen ? 100 : 80,
                    height: isLargeScreen ? 100 : 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isLargeScreen ? 50 : 40,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: isLargeScreen ? 50 : 40,
                ),
        );
      },
    );
  }

  Widget _buildProfileCard(bool isLargeScreen) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final name = user?.name ?? 'N/A';
        final phone = user?.phone != null ? '+${user!.phone}' : 'N/A';
        final email = user?.email ?? 'N/A';
        
        // Reload building data when buildingId changes
        final currentBuildingId = user?.buildingId;
        if (currentBuildingId != _lastBuildingId) {
          _lastBuildingId = currentBuildingId;
          // Reload building data when buildingId changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadProfileData();
            }
          });
        }
        
        final buildingName = _buildingName ?? 'N/A';

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24.0 : 16.0,
            vertical: isLargeScreen ? 16.0 : 8.0,
          ),
          padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF04CDFE).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow('NAME', name, isLargeScreen),
              SizedBox(height: isLargeScreen ? 12 : 8),
              _buildInfoRow('BUILDING NAME', buildingName, isLargeScreen),
              SizedBox(height: isLargeScreen ? 12 : 8),
              _buildInfoRow('PHONE', phone, isLargeScreen),
              SizedBox(height: isLargeScreen ? 12 : 8),
              _buildInfoRow('EMAIL', email, isLargeScreen),
              SizedBox(height: isLargeScreen ? 12 : 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLargeScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          // Push above MainNavigationScreen so bottom navbar is hidden
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(Routes.customerEditProfile);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16.0 : 12.0,
            horizontal: isLargeScreen ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00D4AA).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
              size: isLargeScreen ? 20 : 18,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              'EDIT PROFILE',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryAndCarsButtons(BuildContext context, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 8.0 : 6.0,
      ),
      child: Row(
        children: [
          // History Button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to bookings tab (index 3) in MainNavigationScreen
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(
                  Routes.customerHome,
                  (route) => false,
                  arguments: 3, // Bookings tab index
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 14.0 : 12.0,
                  horizontal: isLargeScreen ? 20.0 : 16.0,
                ),
                side: const BorderSide(color: Color(0xFF04CDFE), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                ),
              ),
              child: Text(
                'HISTORY',
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: isLargeScreen ? 14 : 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 16 : 12),
          // My Cars Button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Use rootNavigator to push above MainNavigationScreen
                // This will hide the bottom navigation bar
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(Routes.customerCarList);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 14.0 : 12.0,
                  horizontal: isLargeScreen ? 20.0 : 16.0,
                ),
                side: const BorderSide(color: Color(0xFF04CDFE), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                ),
              ),
              child: Text(
                'MY CARS',
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: isLargeScreen ? 14 : 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

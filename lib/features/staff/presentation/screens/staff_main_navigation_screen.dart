import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'staff_home_screen.dart';
import 'staff_upcoming_bookings_screen.dart';
import 'staff_booking_history_screen.dart';
import 'staff_profile_screen.dart';
import '../../../../core/theme/app_theme.dart';

class StaffMainNavigationScreen extends StatefulWidget {
  const StaffMainNavigationScreen({super.key});

  @override
  State<StaffMainNavigationScreen> createState() =>
      _StaffMainNavigationScreenState();
}

class _StaffMainNavigationScreenState extends State<StaffMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StaffHomeScreen(),
    const StaffUpcomingBookingsScreen(),
    const StaffBookingHistoryScreen(),
    const StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive sizing based on screen width
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
    final isTablet = screenWidth > 600;

    // Calculate responsive values
    final navBarMargin = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 14.0
        : isTablet
        ? 20.0
        : 16.0;
    final navBarHeight = isSmallScreen
        ? 60.0
        : isMediumScreen
        ? 65.0
        : isTablet
        ? 80.0
        : 70.0;
    final navBarRadius = isSmallScreen
        ? 20.0
        : isMediumScreen
        ? 22.0
        : isTablet
        ? 30.0
        : 25.0;
    final horizontalPadding = isSmallScreen
        ? 16.0
        : isMediumScreen
        ? 18.0
        : isTablet
        ? 25.0
        : 20.0;
    final verticalPadding = isSmallScreen
        ? 6.0
        : isMediumScreen
        ? 7.0
        : isTablet
        ? 10.0
        : 8.0;
    final iconSize = isSmallScreen
        ? 20.0
        : isMediumScreen
        ? 22.0
        : isTablet
        ? 28.0
        : 24.0;
    final navItemSize = isSmallScreen
        ? 40.0
        : isMediumScreen
        ? 45.0
        : isTablet
        ? 60.0
        : 50.0;

    return isIOS
        ? _buildIOSNavigationScreen(
            navBarMargin,
            navBarHeight,
            navBarRadius,
            horizontalPadding,
            verticalPadding,
            iconSize,
            navItemSize,
          )
        : _buildAndroidNavigationScreen(
            navBarMargin,
            navBarHeight,
            navBarRadius,
            horizontalPadding,
            verticalPadding,
            iconSize,
            navItemSize,
          );
  }

  Widget _buildIOSNavigationScreen(
    double navBarMargin,
    double navBarHeight,
    double navBarRadius,
    double horizontalPadding,
    double verticalPadding,
    double iconSize,
    double navItemSize,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Handle back button: move to previous tab (index - 1)
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex = _currentIndex - 1;
          });
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content - fills entire space
            Positioned.fill(child: _screens[_currentIndex]),

            // Positioned bottom navigation bar - fixed at bottom
            Positioned(
              left: navBarMargin,
              right: navBarMargin,
              bottom: navBarMargin + MediaQuery.of(context).padding.bottom,
              child: Container(
                height: navBarHeight,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(navBarRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIOSNavItem(
                        0,
                        CupertinoIcons.house,
                        CupertinoIcons.house_fill,
                        iconSize,
                        navItemSize,
                      ),
                      _buildIOSNavItem(
                        1,
                        CupertinoIcons.calendar,
                        CupertinoIcons.calendar,
                        iconSize,
                        navItemSize,
                      ),
                      _buildIOSNavItem(
                        2,
                        CupertinoIcons.list_bullet,
                        CupertinoIcons.list_bullet,
                        iconSize,
                        navItemSize,
                      ),
                      _buildIOSNavItem(
                        3,
                        CupertinoIcons.person,
                        CupertinoIcons.person_fill,
                        iconSize,
                        navItemSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidNavigationScreen(
    double navBarMargin,
    double navBarHeight,
    double navBarRadius,
    double horizontalPadding,
    double verticalPadding,
    double iconSize,
    double navItemSize,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Handle back button: move to previous tab (index - 1)
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex = _currentIndex - 1;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Main content - fills entire space
            Positioned.fill(child: _screens[_currentIndex]),

            // Positioned bottom navigation bar - fixed at bottom
            Positioned(
              left: navBarMargin,
              right: navBarMargin,
              bottom: navBarMargin + MediaQuery.of(context).padding.bottom,
              child: Container(
                height: navBarHeight,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(navBarRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAndroidNavItem(
                        0,
                        Icons.home_outlined,
                        Icons.home,
                        iconSize,
                        navItemSize,
                      ),
                      _buildAndroidNavItem(
                        1,
                        Icons.calendar_today_outlined,
                        Icons.calendar_today,
                        iconSize,
                        navItemSize,
                      ),
                      _buildAndroidNavItem(
                        2,
                        Icons.history_outlined,
                        Icons.history,
                        iconSize,
                        navItemSize,
                      ),
                      _buildAndroidNavItem(
                        3,
                        Icons.person_outline,
                        Icons.person,
                        iconSize,
                        navItemSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    double iconSize,
    double navItemSize,
  ) {
    final isActive = _currentIndex == index;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: navItemSize,
        height: navItemSize,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF04CDFE) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildAndroidNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    double iconSize,
    double navItemSize,
  ) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: navItemSize,
        height: navItemSize,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF04CDFE) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: iconSize,
        ),
      ),
    );
  }
}

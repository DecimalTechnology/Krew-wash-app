import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'customer_home_screen.dart';
import 'package_selection_screen.dart';
import 'my_bookings_screen.dart';
import 'customer_profile_screen.dart';
import 'car_list_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialTab});

  /// Optional initial tab index (0=Home, 1=Packages, 2=Cars, 3=Bookings, 4=Profile)
  final int? initialTab;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  // Create separate navigation keys for each tab to maintain independent navigation stacks
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _goToTab(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  // Store screens to keep them alive
  late final List<Widget> _screens;

  Widget _buildNavigatorWrapper(int index) {
    return _NavigatorWrapper(
      key: ValueKey('nav_$index'),
      navigatorKey: _navigatorKeys[index],
      screen: _screens[index],
    );
  }

  // Build navigator wrappers once to avoid re-creating nested Navigators
  late final List<Widget> _navigatorScreens;

  @override
  void initState() {
    super.initState();
    // Set initial tab from widget parameter, default to 0 (Home)
    _currentIndex =
        widget.initialTab != null &&
            widget.initialTab! >= 0 &&
            widget.initialTab! < 5
        ? widget.initialTab!
        : 0;
    _screens = [
      CustomerHomeScreen(onNavigateToPackages: () => _goToTab(1)),
      const PackageSelectionScreen(),
      const CarListScreen(),
      MyBookingsScreen(
        // Back from bookings should go to Car Listing tab
        onBack: () => _goToTab(2),
      ),
      const CustomerProfileScreen(),
    ];
    _navigatorScreens = List<Widget>.generate(
      _screens.length,
      (index) => _buildNavigatorWrapper(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive sizing based on screen width
    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Handle back button: try to pop from the current tab's navigator first
        final navigator = _navigatorKeys[_currentIndex].currentState;
        final didInnerPop = navigator != null
            ? await navigator.maybePop()
            : false;

        if (!didInnerPop && _currentIndex > 0) {
          // At root of this tab: move to previous tab
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
            // Main content - use IndexedStack to keep all navigators alive
            IndexedStack(index: _currentIndex, children: _navigatorScreens),

            // Blurred background container behind navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height:
                  navBarHeight +
                  (navBarMargin * 2) +
                  MediaQuery.of(context).padding.bottom,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Positioned bottom navigation bar - fixed at bottom
            Positioned(
              left: navBarMargin,
              right: navBarMargin,
              bottom: navBarMargin + MediaQuery.of(context).padding.bottom,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(navBarRadius),
                child: Container(
                  height: navBarHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(navBarRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
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
                          CupertinoIcons.square_grid_2x2,
                          CupertinoIcons.square_grid_2x2_fill,
                          iconSize,
                          navItemSize,
                        ),
                        _buildIOSNavItem(
                          2,
                          CupertinoIcons.car,
                          CupertinoIcons.car_fill,
                          iconSize,
                          navItemSize,
                        ),
                        _buildIOSNavItem(
                          3,
                          CupertinoIcons.calendar,
                          CupertinoIcons.calendar_today,
                          iconSize,
                          navItemSize,
                        ),
                        _buildIOSNavItem(
                          4,
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Handle back button: try to pop from the current tab's navigator first
        final navigator = _navigatorKeys[_currentIndex].currentState;
        final didInnerPop = navigator != null
            ? await navigator.maybePop()
            : false;

        if (!didInnerPop && _currentIndex > 0) {
          // At root of this tab: move to previous tab
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
            // Main content - use IndexedStack to keep all navigators alive
            IndexedStack(index: _currentIndex, children: _navigatorScreens),

            // Blurred background container behind navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height:
                  navBarHeight +
                  (navBarMargin * 2) +
                  MediaQuery.of(context).padding.bottom,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Positioned bottom navigation bar - fixed at bottom
            Positioned(
              left: navBarMargin,
              right: navBarMargin,
              bottom: navBarMargin + MediaQuery.of(context).padding.bottom,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(navBarRadius),
                child: Container(
                  height: navBarHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E1F).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(navBarRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
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
                          Icons.grid_view_outlined,
                          Icons.grid_view,
                          iconSize,
                          navItemSize,
                        ),
                        _buildAndroidNavItem(
                          2,
                          Icons.directions_car_outlined,
                          Icons.directions_car,
                          iconSize,
                          navItemSize,
                        ),
                        _buildAndroidNavItem(
                          3,
                          Icons.calendar_today_outlined,
                          Icons.calendar_today,
                          iconSize,
                          navItemSize,
                        ),
                        _buildAndroidNavItem(
                          4,
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
        // If tapping the same tab, pop to root if there's a navigation stack
        if (_currentIndex == index) {
          final navigator = _navigatorKeys[index].currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
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
        // If tapping the same tab, pop to root if there's a navigation stack
        if (_currentIndex == index) {
          final navigator = _navigatorKeys[index].currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
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

// Separate widget to ensure Navigator is properly initialized
class _NavigatorWrapper extends StatefulWidget {
  const _NavigatorWrapper({
    super.key,
    required this.navigatorKey,
    required this.screen,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget screen;

  @override
  State<_NavigatorWrapper> createState() => _NavigatorWrapperState();
}

class _NavigatorWrapperState extends State<_NavigatorWrapper> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: '/',
      onGenerateInitialRoutes:
          (NavigatorState navigator, String initialRouteName) {
            // Always generate the initial route to ensure Navigator has history
            return [
              MaterialPageRoute(
                builder: (context) => widget.screen,
                settings: const RouteSettings(name: '/'),
              ),
            ];
          },
      onGenerateRoute: (settings) {
        // If it's the initial route, return the root screen
        if (settings.name == null ||
            settings.name == '/' ||
            settings.name!.isEmpty) {
          return MaterialPageRoute(
            builder: (context) => widget.screen,
            settings: const RouteSettings(name: '/'),
          );
        }

        // For other routes, check if they exist in AppRoutes
        final routeBuilder = AppRoutes.routes[settings.name];
        if (routeBuilder != null) {
          return MaterialPageRoute(builder: routeBuilder, settings: settings);
        }

        // Fallback to app's route generator for dynamic routes
        return AppRoutes.generateRoute(settings);
      },
    );
  }
}

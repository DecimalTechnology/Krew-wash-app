import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_dashboard_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, this.onNavigateToPackages});

  /// Callback to switch to Package Selection tab (index 1)
  final VoidCallback? onNavigateToPackages;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _hasShownNetworkErrorDialog = false;

  @override
  void initState() {
    super.initState();

    // Fade animation for background elements
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Scale animation for interactive elements
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });

    // Fetch dashboard data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerDashboardProvider>();
      provider.fetchDashboardData();

      // Listen for network errors and show dialog
      provider.addListener(_handleDashboardError);
    });
  }

  void _handleDashboardError() {
    if (!mounted) return;

    final provider = context.read<CustomerDashboardProvider>();

    // Show network error dialog if there's a network error and we haven't shown it yet
    if (provider.isNetworkError &&
        provider.dashboardErrorMessage != null &&
        !_hasShownNetworkErrorDialog) {
      _hasShownNetworkErrorDialog = true;
      // Use a post-frame callback to ensure the dialog shows after the current build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNetworkErrorDialog(provider.dashboardErrorMessage!);
        }
      });
    } else if (!provider.isNetworkError) {
      // Reset flag when network error is resolved
      _hasShownNetworkErrorDialog = false;
    }
  }

  void _showNetworkErrorDialog(String errorMessage) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Network Error'),
          content: const Text(
            'Unable to connect to the server. Please check your internet connection and try again.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                _hasShownNetworkErrorDialog = false; // Reset flag for retry
                context.read<CustomerDashboardProvider>().fetchDashboardData(
                  force: true,
                );
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _hasShownNetworkErrorDialog =
                    false; // Reset flag when dismissed
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Network Error'),
          content: const Text(
            'Unable to connect to the server. Please check your internet connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hasShownNetworkErrorDialog = false; // Reset flag for retry
                context.read<CustomerDashboardProvider>().fetchDashboardData(
                  force: true,
                );
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hasShownNetworkErrorDialog =
                    false; // Reset flag when dismissed
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    try {
      context.read<CustomerDashboardProvider>().removeListener(
        _handleDashboardError,
      );
    } catch (e) {
      // Provider might already be disposed
    }

    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background with content - same image for both iOS and Android
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/CustomerHome/homebg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Header Section with fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildHeader(context),
                      ),

                      // Scrollable Content with slide animation
                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 0,
                                bottom:
                                    MediaQuery.of(context).padding.bottom +
                                    150, // Space for floating button - increased to allow content to scroll above
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),

                                  // User Info Section with animation
                                  _buildAnimatedSection(
                                    delay: 0,
                                    child: _buildUserInfo(context),
                                  ),

                                  const SizedBox(height: 60),

                                  // WE OFFER SERVICES Section with animation
                                  _buildAnimatedSection(
                                    delay: 100,
                                    child: _buildWeOfferServices(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Promotional Banner with animation - Full width
                                  _buildAnimatedSection(
                                    delay: 200,
                                    child: _buildPromotionalBanner(),
                                  ),

                                  const SizedBox(height: 16),

                                  // OUR PACKAGES Section with animation
                                  _buildAnimatedSection(
                                    delay: 300,
                                    child: _buildOurPackages(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Rating Section with animation
                                  _buildAnimatedSection(
                                    delay: 400,
                                    child: _buildRatingSection(),
                                  ),

                                  const SizedBox(height: 16),

                                  // WE ARE AVAILABLE AT Section with animation
                                  _buildAnimatedSection(
                                    delay: 500,
                                    child: _buildWeAreAvailableAt(),
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Floating button positioned above navigation bar with scale animation
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBookServiceButton(context, false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.asset(
              'assets/Logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          // Profile Button
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.customerProfile);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        String name = 'USER';
        if (user != null) {
          if (user.name?.trim().isNotEmpty == true) {
            name = user.name!.trim();
          } else if (user.email != null) {
            name = user.email!.split('@').first;
          }
        }

        // userId variable removed as ID field is no longer displayed

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'HI, ${name.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'FAST FRESH',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ID field removed but space maintained
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildWeOfferServices() {
    return Consumer<CustomerDashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final services = dashboardProvider.services;
        final isLoading = dashboardProvider.isLoadingDashboard;

        // Default icons for services
        IconData getServiceIcon(String serviceName) {
          final name = serviceName.toLowerCase();
          if (name.contains('wash') || name.contains('car')) {
            return Icons.local_car_wash;
          } else if (name.contains('vacuum') || name.contains('interior')) {
            return Icons.cleaning_services;
          }
          return Icons.local_car_wash;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'WE OFFER SERVICES',
              textAlign: TextAlign.center,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildServiceCardShimmer()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildServiceCardShimmer()),
                  ],
                ),
              )
            else if (services.isEmpty)
              Text(
                'No services available',
                style: AppTheme.bebasNeue(color: Colors.white70, fontSize: 14),
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < services.length && i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          title: (services[i]['name'] ?? 'Service')
                              .toString()
                              .toUpperCase(),
                          subtitle: (services[i]['description'] ?? '')
                              .toString()
                              .toUpperCase(),
                          icon: getServiceIcon(
                            services[i]['name']?.toString() ?? '',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      height: 110, // Fixed height for consistent sizing
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Very dark grey background
        borderRadius: BorderRadius.circular(16), // More rounded corners
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.1,
          ), // Subtle light grey border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.bebasNeue(
                    color: AppTheme.primaryColor, // Cyan color
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Right side - Icons with sparkles above
          Stack(
            alignment: Alignment.center,
            children: [
              // Car icon
              Icon(icon, color: AppTheme.primaryColor, size: 32),
              // Sparkle icons positioned above and to the right
              Positioned(
                top: -8,
                right: -4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width *
                0.05, // 5% of screen width on each side
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'This is Your time.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'BOOK YOUR SLOT TODAY...',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    if (widget.onNavigateToPackages != null) {
                      widget.onNavigateToPackages!();
                    } else {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.customerPackageSelection);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'EXPLORE IT',
                      style: AppTheme.bebasNeue(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getPackagePrice(Map<String, dynamic> package) {
    final basePrices = package['basePrices'] as List?;
    if (basePrices == null || basePrices.isEmpty) {
      return 'N/A';
    }
    // Find minimum price
    double minPrice = double.infinity;
    for (var price in basePrices) {
      final priceValue = (price as Map<String, dynamic>)['price'];
      if (priceValue != null) {
        final p = (priceValue is num)
            ? priceValue.toDouble()
            : double.tryParse(priceValue.toString()) ?? 0;
        if (p < minPrice) {
          minPrice = p;
        }
      }
    }
    return minPrice != double.infinity ? '${minPrice.toInt()} AED' : 'N/A';
  }

  Widget _buildOurPackages() {
    return Consumer<CustomerDashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final packages = dashboardProvider.packages;
        final isLoading = dashboardProvider.isLoadingDashboard;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OUR PACKAGES',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildPackageCardShimmer()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildPackageCardShimmer()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPackageCardFullWidthShimmer(),
                ],
              )
            else if (packages.isEmpty)
              Text(
                'No packages available',
                style: AppTheme.bebasNeue(color: Colors.white70, fontSize: 14),
              )
            else
              // Dynamic grid layout
              Column(
                children: [
                  // First 2 packages in grid
                  if (packages.length >= 2) ...[
                    Row(
                      children: [
                        Expanded(child: _buildPackageCard(packages[0])),
                        const SizedBox(width: 10),
                        Expanded(child: _buildPackageCard(packages[1])),
                      ],
                    ),
                  ] else if (packages.length == 1) ...[
                    // Only one package
                    _buildPackageCard(packages[0]),
                  ],
                  // Third package (if exists) in full width
                  if (packages.length == 3) ...[
                    const SizedBox(height: 10),
                    _buildPackageCardFullWidth(packages[2]),
                  ] else if (packages.length > 3) ...[
                    // More than 3 packages - continue with grid for remaining
                    for (int i = 2; i < packages.length; i += 2) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildPackageCard(packages[i])),
                          if (i + 1 < packages.length) ...[
                            const SizedBox(width: 10),
                            Expanded(child: _buildPackageCard(packages[i + 1])),
                          ] else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final name = (package['name'] ?? 'PACKAGE').toString().toUpperCase();
    final frequency = package['frequency']?.toString() ?? '';
    final price = getPackagePrice(package);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section - Dark grey/black background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.bebasNeue(
                    color: const Color(0xFF04CDFE),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
                if (frequency.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    frequency.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider line
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Bottom section - Lighter grey background with centered price
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color:
                  Colors.grey[900]?.withValues(alpha: 0.5) ?? Colors.grey[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                price,
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: 18,
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

  Widget _buildPackageCardFullWidth(Map<String, dynamic> package) {
    final name = (package['name'] ?? 'PACKAGE').toString().toUpperCase();
    final frequency = package['frequency']?.toString() ?? '';
    final price = getPackagePrice(package);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section - Dark grey/black background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTheme.bebasNeue(
                    color: const Color(0xFF04CDFE),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
                if (frequency.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    frequency.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider line
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Bottom section - Lighter grey background with centered price
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  Colors.grey[900]?.withValues(alpha: 0.5) ?? Colors.grey[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                price,
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: 24,
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

  Widget _buildRatingSection() {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Speedometer Icon
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.speed,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Rating Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'PROUDLY RATED',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    '4.8 STARS ON GOOGLE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeAreAvailableAt() {
    return Consumer<CustomerDashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final buildings = dashboardProvider.buildings;
        final isLoading = dashboardProvider.isLoadingDashboard;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WE ARE AVAILABLE AT',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      _buildBuildingCardShimmer(),
                    ],
                  ],
                ),
              )
            else if (buildings.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No buildings available',
                    style: AppTheme.bebasNeue(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (int i = 0; i < buildings.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      _buildBuildingCard(
                        buildingName:
                            (buildings[i]['buildingName'] ?? 'Building')
                                .toString()
                                .toUpperCase(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBuildingCard({required String buildingName}) {
    return Container(
      width: 180,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A1A,
        ), // Dark background matching service cards
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), // Subtle border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Location icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.location_city,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Building name
          Expanded(
            child: Text(
              buildingName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer loading widgets
  Widget _buildServiceCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.25),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF04CDFE), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCardFullWidthShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF04CDFE), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.25),
      child: Container(
        width: 180,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBookServiceButton(BuildContext context, bool isLargeScreen) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive button width (percentage of screen width)
    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;
    final isTablet = screenWidth > 600;

    final buttonWidth = isSmallScreen
        ? screenWidth *
              0.50 // 50% of screen width
        : isMediumScreen
        ? screenWidth *
              0.45 // 45% of screen width
        : isTablet
        ? screenWidth *
              0.35 // 35% of screen width
        : screenWidth * 0.40; // 40% of screen width

    return Center(
      child: SizedBox(
        width: buttonWidth,
        child: GestureDetector(
          onTap: () {
            // Use callback to switch tabs if available, otherwise fallback to navigation
            if (widget.onNavigateToPackages != null) {
              widget.onNavigateToPackages!();
            } else {
              Navigator.of(context).pushNamed(Routes.customerPackageSelection);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isLargeScreen ? 16 : 14,
              horizontal: isLargeScreen ? 16 : 14,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'BOOK YOUR SLOT',
                textAlign: TextAlign.center,
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 13 : 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

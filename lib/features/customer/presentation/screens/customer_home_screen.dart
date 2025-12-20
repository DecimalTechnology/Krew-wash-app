import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/cutomer_homeScree/top_section_widget.dart';
import '../widgets/cutomer_homeScree/user_info_card_widget.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
    // Scale controller kept for future interactive elements (currently unused).

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/CustomerHome/homebg.png"),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(
                      0x66000000,
                    ).withValues(alpha: _fadeAnimation.value),
                    const Color(
                      0x1A000000,
                    ).withValues(alpha: _fadeAnimation.value),
                    const Color(
                      0x66000000,
                    ).withValues(alpha: _fadeAnimation.value),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            children: [
                              // Top Section with Logo and Profile
                              const TopSectionWidget(),

                              // Spacer for user info card
                              SizedBox(height: isLargeScreen ? 220 : 200),

                              // Service Options
                              _buildServiceOptions(context),

                              // Spacer
                              SizedBox(height: isLargeScreen ? 30 : 20),

                              // Information Cards
                              _buildInformationCards(context),

                              // Spacer
                              SizedBox(height: isLargeScreen ? 20 : 16),

                              // Book Your Service Button
                              _buildBookServiceButton(context, isLargeScreen),

                              // Bottom spacing
                              SizedBox(height: isLargeScreen ? 30 : 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // User Information Card - Positioned over the background
                    Positioned(
                      left: 20,
                      top: 100,
                      right: 20,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(-0.2, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _fadeController,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              final name = auth.user?.name?.trim();
                              final email = auth.user?.email?.trim();
                              final fallbackName =
                                  (email != null && email.contains('@'))
                                  ? email.split('@').first
                                  : null;

                              return UserInfoCardWidget(
                                userName: (name != null && name.isNotEmpty)
                                    ? name
                                    : fallbackName,
                                userId: auth.user?.uid,
                                sessionText: 'SESSIONS',
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 20),
      child: Row(
        children: [
          // Complete Car Wash
          Expanded(
            child: _buildServiceCard(
              context,
              "COMPLETE\nCAR WASH",
              Icons.local_car_wash,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 15),
          // Vacuum Cleaning
          Expanded(
            child: _buildServiceCard(
              context,
              "VACUUM\nCLEANING",
              Icons.cleaning_services,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 20),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left Section - Tips & Tricks
            Expanded(
              child: _buildInfoSection(
                context,
                "FOLLOW\nTIPS & TRICKS",
                Icons.trending_up,
                Colors.white,
              ),
            ),
            // Vertical Divider
            Container(
              width: 1,
              height: 60,
              color: const Color(0xFF04CDFE).withValues(alpha: 0.5),
            ),
            // Right Section - Rating
            Expanded(
              child: _buildInfoSection(
                context,
                "PROUDLY RATED\n4.8 STARS\nON GOOGLE",
                Icons.speed,
                const Color(0xFF04CDFE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookServiceButton(BuildContext context, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 20),
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
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16 : 14,
            horizontal: isLargeScreen ? 24 : 20,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'BOOK YOUR SERVICE',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

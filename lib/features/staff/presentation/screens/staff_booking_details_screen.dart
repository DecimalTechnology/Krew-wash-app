import 'package:carwash_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../domain/models/booking_model.dart';
import '../providers/cleaner_booking_provider.dart';
import 'staff_service_details_screen.dart';
import 'report_issue_screen.dart';
import 'issue_chat_screen.dart';
import '../../data/repositories/chat_repository.dart';

class StaffBookingDetailsScreen extends StatefulWidget {
  final CleanerBooking booking;

  const StaffBookingDetailsScreen({super.key, required this.booking});

  @override
  State<StaffBookingDetailsScreen> createState() =>
      _StaffBookingDetailsScreenState();
}

class _StaffBookingDetailsScreenState extends State<StaffBookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch booking details on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingDetails();
    });
  }

  Future<void> _fetchBookingDetails() async {
    final bookingProvider = context.read<CleanerBookingProvider>();
    await bookingProvider.fetchBookingDetails(widget.booking.id);

    // Show snackbar if there's an error
    if (bookingProvider.detailsError != null && mounted) {
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        // For iOS, we can show an alert or use a snackbar
        // Using ScaffoldMessenger which works on both platforms
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.detailsError!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.detailsError!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clear selected booking when leaving the screen
    context.read<CleanerBookingProvider>().clearSelectedBooking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildContent(isIOS: true),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(isIOS: false),
    );
  }

  Widget _buildContent({required bool isIOS}) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final isMediumScreen = screenWidth >= 400 && screenWidth < 500;
        final isTablet = screenWidth > 600;

        final horizontalPadding = isSmallScreen
            ? 16.0
            : isMediumScreen
            ? 20.0
            : isTablet
            ? 32.0
            : 20.0;

        // Calculate navigation bar dimensions
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
        final systemBottomPadding = MediaQuery.of(context).padding.bottom;
        final bottomPadding =
            navBarMargin + navBarHeight + systemBottomPadding + 16;

        return Consumer<CleanerBookingProvider>(
          builder: (context, bookingProvider, _) {
            // Use selected booking from provider if available, otherwise use passed booking
            final booking = bookingProvider.selectedBooking ?? widget.booking;
            final isLoading = bookingProvider.isDetailsLoading;
            final error = bookingProvider.detailsError;

            if (isLoading && bookingProvider.selectedBooking == null) {
              return SafeArea(
                bottom: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: isIOS
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              );
            }

            if (error != null && bookingProvider.selectedBooking == null) {
              return SafeArea(
                bottom: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error,
                          style: AppTheme.bebasNeue(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        isIOS
                            ? CupertinoButton(
                                onPressed: () {
                                  bookingProvider.fetchBookingDetails(
                                    widget.booking.id,
                                  );
                                },
                                child: Text('Retry'),
                              )
                            : TextButton(
                                onPressed: () {
                                  bookingProvider.fetchBookingDetails(
                                    widget.booking.id,
                                  );
                                },
                                child: Text('Retry'),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              bottom: false,
              child: isIOS
                  ? CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: () async {
                            await _fetchBookingDetails();
                          },
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                _buildHeader(
                                  context,
                                  isIOS,
                                  isSmallScreen,
                                  horizontalPadding,
                                ),
                                SizedBox(height: 24),
                                // Vehicle Information Card
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: _buildVehicleInfoCard(
                                    context,
                                    booking,
                                    isIOS,
                                    isSmallScreen,
                                    isTablet,
                                  ),
                                ),
                                SizedBox(height: 24),
                                // Action Buttons Section
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: _buildActionButtons(
                                    context,
                                    booking,
                                    isIOS,
                                    isSmallScreen,
                                  ),
                                ),
                                SizedBox(height: 24),
                                // Services Section
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: _buildServicesSection(
                                    context,
                                    booking,
                                    isIOS,
                                    isSmallScreen,
                                    isTablet,
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _fetchBookingDetails();
                      },
                      color: const Color(0xFF04CDFE),
                      backgroundColor: Colors.black,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _buildHeader(
                              context,
                              isIOS,
                              isSmallScreen,
                              horizontalPadding,
                            ),
                            SizedBox(height: 24),
                            // Vehicle Information Card
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: _buildVehicleInfoCard(
                                context,
                                booking,
                                isIOS,
                                isSmallScreen,
                                isTablet,
                              ),
                            ),
                            SizedBox(height: 24),
                            // Action Buttons Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: _buildActionButtons(
                                context,
                                booking,
                                isIOS,
                                isSmallScreen,
                              ),
                            ),
                            SizedBox(height: 24),
                            // Services Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: _buildServicesSection(
                                context,
                                booking,
                                isIOS,
                                isSmallScreen,
                                isTablet,
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button in blue circular container on the left
          StandardBackButton(onPressed: () => Navigator.of(context).pop()),
          // Spacer to push heading to center
          const Spacer(),
          // Centered heading
          Column(
            children: [
              Text(
                'Booking Details',
                style: AppTheme.bebasNeue(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'BOOKING DETAILS',
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          // Spacer to balance the back button on the left
          const Spacer(),
          // Bell icon (notification) on the right
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                      // For now, show a placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications - Coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      CupertinoIcons.bell,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                      // For now, show a placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications - Coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(
    BuildContext context,
    CleanerBooking booking,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    // TODO: Get vehicle details from booking.vehicleId or booking.vehicle when available
    // For now, using placeholder data - replace with actual vehicle data when available
    final vehicleModel =
        'CHEVROLET AVEO U-VA'; // Replace with booking.vehicle?.vehicleModel
    final vehiclePlate =
        'JFM 624 J 12'; // Replace with booking.vehicle?.vehicleNumber
    final vehicleColor = 'BLACK'; // Replace with booking.vehicle?.color
    final location =
        booking.buildingInfo?.name ?? booking.user?.apartmentNumber ?? 'N/A';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 24,
        vertical: isSmallScreen ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 22 : 22),
        border: Border.all(
          color: const Color.fromARGB(255, 135, 132, 132),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicleModel.toUpperCase(),
            style: AppTheme.bebasNeue(
              color: const Color(0xFF04CDFE),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            vehiclePlate,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
          SizedBox(height: 16),
          _buildInfoRow('COLOUR', vehicleColor, isIOS, isSmallScreen),
          SizedBox(height: 12),
          _buildInfoRow('LOCATION', location, isIOS, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 80 : 100,
          child: Text(
            label,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CleanerBooking booking,
    bool isIOS,
    bool isSmallScreen,
  ) {
    // Check if there's an active issue for this booking
    final activeIssue = booking.activeIssue ?? false;

    if (activeIssue) {
      // When activeIssue is true, show only "VIEW ACTIVE ISSUE" button
      return _buildViewActiveIssueButton(
        context,
        isIOS,
        isSmallScreen,
        isActive: true,
        onPressed: () async {
          await _handleViewActiveIssue(context, booking, isIOS);
        },
      );
    } else {
      // When activeIssue is false, show only "REPORT AN ISSUE" button
      return _buildReportIssueButton(
        context,
        booking,
        isIOS,
        isSmallScreen,
        onPressed: () async {
          final result = await Navigator.of(context).push(
            isIOS
                ? CupertinoPageRoute(
                    builder: (_) => ReportIssueScreen(booking: booking),
                  )
                : MaterialPageRoute(
                    builder: (_) => ReportIssueScreen(booking: booking),
                  ),
          );

          // Refresh booking details when returning from report issue screen
          if (context.mounted && result != null) {
            await _fetchBookingDetails();
          }
        },
      );
    }
  }

  Widget _buildViewActiveIssueButton(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen, {
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    // When activeIssue is true, use different styling
    if (isActive) {
      return _buildActionButton(
        context,
        'VIEW ACTIVE ISSUE',
        const Color(0xFF4CAF50), // Green color for active issue
        isIOS,
        isSmallScreen,
        textColor: Colors.white,
        icon: Icons.warning_amber_rounded,
        onPressed: onPressed,
      );
    }

    // When activeIssue is false, use dark red design with red border
    return Container(
      height: isSmallScreen ? 44 : 48,
      decoration: BoxDecoration(
        color: const Color(0xFF330000), // Dark red background
        borderRadius: BorderRadius.circular(isIOS ? 12 : 10),
        border: Border.all(
          color: const Color(0xFFFF6666), // Light red border
          width: 1.5,
        ),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: const Color(0xFFFF6666),
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'VIEW ACTIVE ISSUE',
                    style: AppTheme.bebasNeue(
                      color: const Color(0xFFFF6666), // Light red text
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xFFFF6666),
                        size: isSmallScreen ? 16 : 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'VIEW ACTIVE ISSUE',
                        style: AppTheme.bebasNeue(
                          color: const Color(0xFFFF6666), // Light red text
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildReportIssueButton(
    BuildContext context,
    CleanerBooking booking,
    bool isIOS,
    bool isSmallScreen, {
    VoidCallback? onPressed,
  }) {
    // Dark grey background with white text and icon
    return Container(
      height: isSmallScreen ? 44 : 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Dark grey background
        borderRadius: BorderRadius.circular(isIOS ? 12 : 10),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'REPORT AN ISSUE',
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 16 : 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'REPORT AN ISSUE',
                        style: AppTheme.bebasNeue(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    bool isIOS,
    bool isSmallScreen, {
    VoidCallback? onPressed,
    Color? textColor,
    IconData? icon,
  }) {
    final finalTextColor = textColor ?? Colors.white;
    return Container(
      height: isSmallScreen ? 44 : 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isIOS ? 12 : 10),
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: finalTextColor,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTheme.bebasNeue(
                      color: finalTextColor,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: finalTextColor,
                          size: isSmallScreen ? 16 : 18,
                        ),
                        SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTheme.bebasNeue(
                          color: finalTextColor,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    CleanerBooking booking,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICES',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16),
        // Main Package Service
        if (booking.package != null)
          _buildServiceCard(
            context,
            booking.package!.packageId!.name,
            booking.package!.packageId!.isAddOn ? 'ADD-ON' : 'MAIN PACKAGE',
            booking.package!.sessions.where((s) => s.isCompleted).length,
            booking.package!.totalSessions,
            isIOS,
            isSmallScreen,
            isTablet,
            onTap: () {
              Navigator.of(context).push(
                isIOS
                    ? CupertinoPageRoute(
                        builder: (_) => StaffServiceDetailsScreen(
                          booking: booking,
                          serviceName: booking.package!.packageId!.name,
                          sessions: booking.package!.sessions,
                          totalSessions: booking.package!.totalSessions,
                        ),
                      )
                    : MaterialPageRoute(
                        builder: (_) => StaffServiceDetailsScreen(
                          booking: booking,
                          serviceName: booking.package!.packageId!.name,
                          sessions: booking.package!.sessions,
                          totalSessions: booking.package!.totalSessions,
                        ),
                      ),
              );
            },
          ),
        // Addon Services
        ...booking.addons.map((addon) {
          // Get addon name from addonId (you might need to fetch this)
          final addonName = 'ADD-ON SERVICE'; // Replace with actual addon name
          // Convert AddonSession to PackageSession for compatibility
          final packageSessions = addon.sessions.map((addonSession) {
            return PackageSession(
              id: addonSession.id,
              isCompleted: addonSession.isCompleted,
              date: addonSession.date,
              completedBy: addonSession.completedBy,
              images: addonSession.images,
            );
          }).toList();

          return _buildServiceCard(
            context,
            addonName,
            'ADD-ON',
            addon.sessions.where((s) => s.isCompleted).length,
            addon.totalSessions,
            isIOS,
            isSmallScreen,
            isTablet,
            onTap: () {
              Navigator.of(context).push(
                isIOS
                    ? CupertinoPageRoute(
                        builder: (_) => StaffServiceDetailsScreen(
                          booking: booking,
                          serviceName: addonName,
                          sessions: packageSessions,
                          totalSessions: addon.totalSessions,
                          addonId:
                              addon.addonId, // Pass addonId for addon sessions
                        ),
                      )
                    : MaterialPageRoute(
                        builder: (_) => StaffServiceDetailsScreen(
                          booking: booking,
                          serviceName: addonName,
                          sessions: packageSessions,
                          totalSessions: addon.totalSessions,
                          addonId:
                              addon.addonId, // Pass addonId for addon sessions
                        ),
                      ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String serviceName,
    String type,
    int completedCount,
    int totalCount,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 18 : 24,
          vertical: isSmallScreen ? 20 : 26,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isIOS ? 15 : 15),
          border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName.toUpperCase(),
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    type,
                    style: AppTheme.bebasNeue(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$completedCount/$totalCount COMPLETED',
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleViewActiveIssue(
    BuildContext context,
    CleanerBooking booking,
    bool isIOS,
  ) async {
    try {
      // Show loading indicator
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const CupertinoAlertDialog(content: CupertinoActivityIndicator()),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );
      }

      // Try to get existing chat for this booking
      final chatResult = await ChatRepository.getChatByBookingId(
        bookingId: booking.id,
      );

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;

      if (chatResult['success'] == true) {
        // Extract chat data from response
        final chatData = chatResult['data'] as Map<String, dynamic>?;
        final chatId = chatData?['_id']?.toString() ?? '';
        final issueType = chatData?['issue']?.toString() ?? 'ACTIVE ISSUE';
        final description = chatData?['description']?.toString() ?? '';

        // Navigate to chat screen and refresh booking details when returning
        final result = await Navigator.of(context).push(
          isIOS
              ? CupertinoPageRoute(
                  builder: (_) => IssueChatScreen(
                    booking: booking,
                    issueType: issueType,
                    description: description,
                    chatData: chatData,
                    roomId: chatId,
                  ),
                )
              : MaterialPageRoute(
                  builder: (_) => IssueChatScreen(
                    booking: booking,
                    issueType: issueType,
                    description: description,
                    chatData: chatData,
                    roomId: chatId,
                  ),
                ),
        );

        // Refresh booking details when returning from chat screen
        if (context.mounted && result != null) {
          await _fetchBookingDetails();
        }
      } else {
        // If getting chat fails, try using initiateChat which might return existing chat
        final initiateResult = await ChatRepository.initiateChat(
          bookingId: booking.id,
          description: 'Viewing active issue',
          issue: 'ACTIVE ISSUE',
        );

        if (!context.mounted) return;

        if (initiateResult['success'] == true) {
          final chatData = initiateResult['data'] as Map<String, dynamic>?;
          final chatId = chatData?['_id']?.toString() ?? '';
          final issueType = chatData?['issue']?.toString() ?? 'ACTIVE ISSUE';
          final description = chatData?['description']?.toString() ?? '';

          // Navigate to chat screen and refresh booking details when returning
          final result = await Navigator.of(context).push(
            isIOS
                ? CupertinoPageRoute(
                    builder: (_) => IssueChatScreen(
                      booking: booking,
                      issueType: issueType,
                      description: description,
                      chatData: chatData,
                      roomId: chatId,
                    ),
                  )
                : MaterialPageRoute(
                    builder: (_) => IssueChatScreen(
                      booking: booking,
                      issueType: issueType,
                      description: description,
                      chatData: chatData,
                      roomId: chatId,
                    ),
                  ),
          );

          // Refresh booking details when returning from chat screen
          if (context.mounted && result != null) {
            await _fetchBookingDetails();
          }
        } else {
          // Show error message
          final errorMessage =
              initiateResult['message'] ?? 'Failed to load active issue chat';
          if (isIOS) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text('Error'),
                content: Text(errorMessage),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading indicator if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;

      // Show error message
      final errorMessage = 'Error loading active issue: ${e.toString()}';
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

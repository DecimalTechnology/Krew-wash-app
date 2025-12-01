import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../domain/models/booking_model.dart';
import '../providers/cleaner_booking_provider.dart';
import 'staff_service_details_screen.dart';

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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        isIOS
                            ? CupertinoButton(
                                onPressed: () {
                                  bookingProvider.fetchBookingDetails(
                                    widget.booking.id,
                                  );
                                },
                                child: const Text('Retry'),
                              )
                            : TextButton(
                                onPressed: () {
                                  bookingProvider.fetchBookingDetails(
                                    widget.booking.id,
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                  ],
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
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
          ),
          // Spacer to push heading to center
          const Spacer(),
          // Centered heading
          Column(
            children: [
              Text(
                'Booking Details',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BOOKING DETAILS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
                ),
              ),
            ],
          ),
          // Spacer to balance the back button on the left
          const Spacer(),
          // Invisible placeholder to balance the back button
          const SizedBox(width: 32),
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
            style: TextStyle(
              color: const Color(0xFF04CDFE),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vehiclePlate,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          const SizedBox(height: 16),
          _buildInfoRow('COLOUR', vehicleColor, isIOS, isSmallScreen),
          const SizedBox(height: 12),
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
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
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
          ),
        ),
        const SizedBox(height: 16),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$completedCount/$totalCount COMPLETED',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../providers/cleaner_booking_provider.dart';
import 'staff_booking_details_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

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

        // Responsive calculations
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

        // Calculate navigation bar dimensions (matching navigation screen)
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

        // Calculate bottom padding to allow scrolling above nav bar
        final systemBottomPadding = MediaQuery.of(context).padding.bottom;
        final bottomPadding =
            navBarMargin + navBarHeight + systemBottomPadding + 16;

        return SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Welcome Header
                      _buildWelcomeHeader(
                        context,
                        isIOS,
                        isSmallScreen,
                        isTablet,
                        horizontalPadding,
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards
                            _buildSummaryCards(
                              context,
                              isIOS,
                              isSmallScreen,
                              isTablet,
                            ),
                            SizedBox(height: 32),
                            // Today's Schedule Section
                            _buildTodaysScheduleSection(
                              context,
                              isIOS,
                              isSmallScreen,
                              isTablet,
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
    double horizontalPadding,
  ) {
    return Consumer<StaffProvider>(
      builder: (context, staffProvider, _) {
        final staff = staffProvider.staff;
        final userName = staff?.name.toUpperCase() ?? 'CLEANER';
        final userId = staff?.cleanerId ?? 'ID: N/A';
        final headerHeight = isSmallScreen
            ? 240.0
            : isTablet
            ? 320.0
            : 270.0;

        return SizedBox(
          height: headerHeight,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  heightFactor: 1,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/cleaner/homescreen.png',
                      height: headerHeight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.92),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalPadding,
                top: isSmallScreen ? 22 : 30,
                right: horizontalPadding + (isSmallScreen ? 120 : 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: AppTheme.bebasNeue(
                        color: const Color(0xFF7FB6D4),
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userName,
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? 28
                            : isTablet
                            ? 42
                            : 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'ID : $userId',
                      style: AppTheme.bebasNeue(
                        color: const Color(0xFF04CDFE),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            '2',
            'TODAY\'S WORKS',
            isIOS,
            isSmallScreen,
            isTablet,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            '2',
            'UPCOMING',
            isIOS,
            isSmallScreen,
            isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String number,
    String label,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Container(
      height: isSmallScreen ? 110 : 120,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: AppTheme.bebasNeue(
                color: const Color(0xFF04CDFE),
                fontSize: isSmallScreen
                    ? 36
                    : isTablet
                    ? 54
                    : 44,
                fontWeight: FontWeight.w700,

                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysScheduleSection(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY\'S SCHEDULE',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16),
        _buildScheduleCard(context, isIOS, isSmallScreen, isTablet),
      ],
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 24,
        vertical: isSmallScreen ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with vehicle info and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHEVROLET AMED U-WA',
                      style: AppTheme.bebasNeue(
                        color: const Color(0xFF04CDFE),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JFM 824 J 12',
                      style: AppTheme.bebasNeue(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ID : ',
                            style: AppTheme.bebasNeue(
                              color: const Color(0xFF04CDFE),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          TextSpan(
                            text: 'BOOKING 01',
                            style: AppTheme.bebasNeue(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF04CDFE), width: 1),
                ),
                child: Text(
                  'PENDING',
                  style: AppTheme.bebasNeue(
                    color: const Color(0xFF04CDFE),
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.08), thickness: 1),
          SizedBox(height: 18),
          // Service details
          _buildDetailRow(
            context,
            'SERVICE',
            'MONTHLY CAR WASH + INTERIOR CLEANING',
            isIOS,
            isSmallScreen,
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            context,
            'LOCATION',
            'PARKING A15',
            isIOS,
            isSmallScreen,
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            context,
            'DATE & TIME',
            'NOV 19, 10:00 AM',
            isIOS,
            isSmallScreen,
            isHighlighted: true,
          ),
          SizedBox(height: 20),
          // View Details Button
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: isTablet ? 260 : 220,
              height: isSmallScreen ? 40 : 44,
              child: Consumer<CleanerBookingProvider>(
                builder: (context, bookingProvider, _) {
                  final firstBooking =
                      bookingProvider.assignedBookings.isNotEmpty
                      ? bookingProvider.assignedBookings.first
                      : null;

                  return isIOS
                      ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: const Color(0xFF04CDFE),
                          borderRadius: BorderRadius.circular(24),
                          onPressed: () {
                            if (firstBooking != null) {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => StaffBookingDetailsScreen(
                                    booking: firstBooking,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'VIEW DETAILS',
                            style: AppTheme.bebasNeue(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 13 : 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.1,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04CDFE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (firstBooking != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StaffBookingDetailsScreen(
                                    booking: firstBooking,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'VIEW DETAILS',
                            style: AppTheme.bebasNeue(
                              fontSize: isSmallScreen ? 13 : 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.1,
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    bool isIOS,
    bool isSmallScreen, {
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 80 : 100,
          child: Text(
            label,
            style: AppTheme.bebasNeue(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bebasNeue(
              color: isHighlighted ? const Color(0xFF04CDFE) : Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,

              height: 1.4,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

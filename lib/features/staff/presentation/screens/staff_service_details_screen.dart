import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../domain/models/booking_model.dart';
import '../providers/cleaner_booking_provider.dart';
import 'staff_session_details_screen.dart';

class StaffServiceDetailsScreen extends StatelessWidget {
  final CleanerBooking booking;
  final String serviceName;
  final List<PackageSession> sessions;
  final int totalSessions;
  final String?
  addonId; // null for package sessions, addonId for addon sessions

  const StaffServiceDetailsScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.sessions,
    required this.totalSessions,
    this.addonId,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return Material(
      color: Colors.black,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: _buildContent(isIOS: true),
      ),
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
            final currentBooking = bookingProvider.selectedBooking ?? booking;

            // Get sessions based on whether it's an addon or package
            final List<PackageSession> currentSessions;
            if (addonId != null) {
              // For addon sessions, get from the addon
              final addon = currentBooking.addons.firstWhere(
                (a) => a.addonId == addonId,
                orElse: () =>
                    booking.addons.firstWhere((a) => a.addonId == addonId),
              );
              currentSessions = addon.sessions.map((addonSession) {
                return PackageSession(
                  id: addonSession.id,
                  isCompleted: addonSession.isCompleted,
                  date: addonSession.date,
                  completedBy: addonSession.completedBy,
                  images: addonSession.images,
                );
              }).toList();
            } else {
              // For package sessions, get from package
              currentSessions = currentBooking.package?.sessions ?? sessions;
            }

            final completedCount = currentSessions
                .where((s) => s.isCompleted)
                .length;

            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  _buildHeader(
                    context,
                    isIOS,
                    isSmallScreen,
                    horizontalPadding,
                  ),
                  // Sessions Overview
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _buildSessionsOverview(
                      completedCount,
                      totalSessions,
                      isIOS,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sessions List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      itemCount: totalSessions,
                      itemBuilder: (context, index) {
                        final sessionNumber = index + 1;
                        final session = index < currentSessions.length
                            ? currentSessions[index]
                            : null;
                        final isCompleted = session?.isCompleted ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildSessionCard(
                            context,
                            currentBooking,
                            currentSessions,
                            sessionNumber,
                            session,
                            isCompleted,
                            isIOS,
                            isSmallScreen,
                            isTablet,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                serviceName.toUpperCase(),
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

  Widget _buildSessionsOverview(
    int completedCount,
    int totalSessions,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SESSIONS',
          style: TextStyle(
            color: const Color(0xFF04CDFE),
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
          ),
        ),
        Text(
          '$completedCount/$totalSessions COMPLETED',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    CleanerBooking booking,
    List<PackageSession> currentSessions,
    int sessionNumber,
    PackageSession? session,
    bool isCompleted,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () {
        if (session != null) {
          Navigator.of(context).push(
            isIOS
                ? CupertinoPageRoute(
                    builder: (_) => StaffSessionDetailsScreen(
                      booking: booking,
                      serviceName: serviceName,
                      session: session,
                      sessionNumber: sessionNumber,
                      totalSessions: totalSessions,
                      completedCount: currentSessions
                          .where((s) => s.isCompleted)
                          .length,
                      addonId: addonId,
                      sessionType: addonId != null ? 'addon' : 'package',
                    ),
                  )
                : MaterialPageRoute(
                    builder: (_) => StaffSessionDetailsScreen(
                      booking: booking,
                      serviceName: serviceName,
                      session: session,
                      sessionNumber: sessionNumber,
                      totalSessions: totalSessions,
                      completedCount: currentSessions
                          .where((s) => s.isCompleted)
                          .length,
                      addonId: addonId,
                      sessionType: addonId != null ? 'addon' : 'package',
                    ),
                  ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 18 : 24,
          vertical: isSmallScreen ? 20 : 26,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
          border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SESSION $sessionNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                      ),
                    ),
                  )
                else
                  Consumer<CleanerBookingProvider>(
                    builder: (context, bookingProvider, _) {
                      final isUpdating = session != null
                          ? bookingProvider.isUpdatingSession(session.id)
                          : false;

                      return GestureDetector(
                        onTap: () async {
                          if (session != null && !isUpdating) {
                            // Check if it's an addon session (true) or package session (false)
                            final isAddon = addonId != null;

                            final result = await bookingProvider.updateSession(
                              bookingId: booking.id,
                              sessionId: session.id,
                              sessionType: isAddon ? 'addon' : 'package',
                              addonId:
                                  addonId, // null for package, addonId for addon
                            );
                            if (result['success'] == true) {
                              // Refresh booking details
                              await bookingProvider.fetchBookingDetails(
                                booking.id,
                              );
                              // Show success message
                              if (context.mounted) {
                                _showMessage(
                                  context,
                                  'Session marked as completed',
                                  isError: false,
                                );
                              }
                            } else {
                              // Show error message
                              if (context.mounted) {
                                _showMessage(
                                  context,
                                  result['message'] ??
                                      'Failed to update session',
                                  isError: true,
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF04CDFE).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF04CDFE),
                              width: 1,
                            ),
                          ),
                          child: isUpdating
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: isIOS
                                      ? const CupertinoActivityIndicator(
                                          color: Color(0xFF04CDFE),
                                          radius: 6,
                                        )
                                      : const CircularProgressIndicator(
                                          color: Color(0xFF04CDFE),
                                          strokeWidth: 2,
                                        ),
                                )
                              : Text(
                                  'MARK COMPLETE',
                                  style: TextStyle(
                                    color: const Color(0xFF04CDFE),
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontFamily: isIOS
                                        ? '.SF Pro Text'
                                        : 'Roboto',
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (isCompleted && session != null) ...[
              const SizedBox(height: 12),
              Text(
                'COMPLETED ON ${_formatDate(session.date)}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final d = date.toLocal();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[(d.month - 1).clamp(0, 11)]} ${d.day}';
  }

  void _showMessage(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      // Use CupertinoAlertDialog for iOS
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(isError ? 'Error' : 'Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      // Use SnackBar for Android
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: Duration(seconds: isError ? 3 : 2),
          ),
        );
      }
    }
  }
}

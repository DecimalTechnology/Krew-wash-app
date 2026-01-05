import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../domain/models/booking_model.dart';
import '../providers/cleaner_booking_provider.dart';
import 'staff_session_details_screen.dart';

class StaffServiceDetailsScreen extends StatefulWidget {
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
  State<StaffServiceDetailsScreen> createState() =>
      _StaffServiceDetailsScreenState();
}

class _StaffServiceDetailsScreenState extends State<StaffServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch latest booking details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerBookingProvider>().fetchBookingDetails(
        widget.booking.id,
      );
    });
  }

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
            final currentBooking =
                bookingProvider.selectedBooking ?? widget.booking;

            // Get sessions based on whether it's an addon or package
            final List<PackageSession> currentSessions;
            if (widget.addonId != null) {
              // For addon sessions, get from the addon
              final addon = currentBooking.addons.firstWhere(
                (a) => a.addonId == widget.addonId,
                orElse: () => widget.booking.addons.firstWhere(
                  (a) => a.addonId == widget.addonId,
                ),
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
              currentSessions =
                  currentBooking.package?.sessions ?? widget.sessions;
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
                  SizedBox(height: 24),
                  // Sessions Overview
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _buildSessionsOverview(
                      completedCount,
                      widget.totalSessions,
                      isIOS,
                      isSmallScreen,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Sessions List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<CleanerBookingProvider>()
                            .fetchBookingDetails(currentBooking.id);
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        itemCount: widget.totalSessions,
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
          StandardBackButton(onPressed: () => Navigator.of(context).pop()),
          // Spacer to push heading to center
          const Spacer(),
          // Centered heading
          Column(
            children: [
              SizedBox(height: 4),
              Text(
                widget.serviceName.toUpperCase(),
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
          // Invisible placeholder to balance the back button
          SizedBox(width: 40),
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
          style: AppTheme.bebasNeue(
            color: const Color(0xFF04CDFE),
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          '$completedCount/$totalSessions COMPLETED',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
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
                      serviceName: widget.serviceName,
                      session: session,
                      sessionNumber: sessionNumber,
                      totalSessions: widget.totalSessions,
                      completedCount: currentSessions
                          .where((s) => s.isCompleted)
                          .length,
                      addonId: widget.addonId,
                      sessionType: widget.addonId != null ? 'addon' : 'package',
                    ),
                  )
                : MaterialPageRoute(
                    builder: (_) => StaffSessionDetailsScreen(
                      booking: booking,
                      serviceName: widget.serviceName,
                      session: session,
                      sessionNumber: sessionNumber,
                      totalSessions: widget.totalSessions,
                      completedCount: currentSessions
                          .where((s) => s.isCompleted)
                          .length,
                      addonId: widget.addonId,
                      sessionType: widget.addonId != null ? 'addon' : 'package',
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
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: AppTheme.bebasNeue(
                        color: Colors.green,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
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
                            // Show confirmation dialog before completing
                            final shouldComplete =
                                await _showCompleteConfirmation(context, isIOS);
                            if (!shouldComplete) return;

                            // Check if it's an addon session (true) or package session (false)
                            final isAddon = widget.addonId != null;

                            final result = await bookingProvider.updateSession(
                              bookingId: booking.id,
                              sessionId: session.id,
                              sessionType: isAddon ? 'addon' : 'package',
                              addonId: widget
                                  .addonId, // null for package, addonId for addon
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
                            color: const Color(
                              0xFF04CDFE,
                            ).withValues(alpha: 0.2),
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
                                  style: AppTheme.bebasNeue(
                                    color: const Color(0xFF04CDFE),
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (isCompleted && session != null) ...[
              SizedBox(height: 12),
              Text(
                'COMPLETED ON ${_formatDateWithTime(session.date)}',
                style: AppTheme.bebasNeue(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateWithTime(DateTime? date) {
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
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'pm' : 'am';
    final time = '$hour:$minute $amPm';
    return '${months[(d.month - 1).clamp(0, 11)]} ${d.day}, $time';
  }

  Future<bool> _showCompleteConfirmation(
    BuildContext context,
    bool isIOS,
  ) async {
    if (isIOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: const Text('Complete Session'),
              content: const Text(
                'Are you sure you want to mark this session as completed?',
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Complete'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      return await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: AppTheme.cardColor,
              title: Text(
                'Complete Session',
                style: AppTheme.bebasNeue(color: Colors.white),
              ),
              content: Text(
                'Are you sure you want to mark this session as completed?',
                style: AppTheme.bebasNeue(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTheme.bebasNeue(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    'Complete',
                    style: AppTheme.bebasNeue(color: const Color(0xFF04CDFE)),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
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
              child: Text('OK'),
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

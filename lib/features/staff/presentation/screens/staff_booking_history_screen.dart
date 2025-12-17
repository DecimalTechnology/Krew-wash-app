import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/cleaner_booking_provider.dart';
import '../../domain/models/booking_model.dart';
import 'staff_booking_details_screen.dart';

class StaffBookingHistoryScreen extends StatefulWidget {
  const StaffBookingHistoryScreen({super.key});

  @override
  State<StaffBookingHistoryScreen> createState() =>
      _StaffBookingHistoryScreenState();
}

class _StaffBookingHistoryScreenState extends State<StaffBookingHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerBookingProvider>().fetchCompletedBookings(
        force: true,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Center(
                  child: Text(
                    'BOOKING HISTORY',
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: _buildSearchBar(isIOS, isSmallScreen),
              ),
              SizedBox(height: 12),
              Expanded(
                child: Consumer<CleanerBookingProvider>(
                  builder: (context, bookingProvider, _) {
                    if (bookingProvider.isCompletedLoading &&
                        bookingProvider.completedBookings.isEmpty) {
                      return Center(
                        child: CupertinoActivityIndicator(color: Colors.white),
                      );
                    }

                    if (bookingProvider.completedError != null &&
                        bookingProvider.completedBookings.isEmpty) {
                      return _buildErrorState(
                        message: bookingProvider.completedError!,
                        isIOS: isIOS,
                        onRetry: () =>
                            bookingProvider.fetchCompletedBookings(force: true),
                      );
                    }

                    if (bookingProvider.completedBookings.isEmpty) {
                      return _buildEmptyState(isIOS);
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF04CDFE),
                      onRefresh: () =>
                          bookingProvider.fetchCompletedBookings(force: true),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        itemBuilder: (context, index) {
                          final booking =
                              bookingProvider.completedBookings[index];
                          return _buildBookingCard(
                            booking: booking,
                            title:
                                booking.package?.packageId?.name ??
                                'Completed Package',
                            subtitle: booking.user?.name ?? 'Customer',
                            bookingId: booking.bookingId,
                            status: booking.status,
                            service:
                                booking.package?.packageId?.description ?? '',
                            location:
                                booking.buildingInfo?.name ??
                                booking.user?.apartmentNumber ??
                                'N/A',
                            dateTime:
                                _formatDate(booking.endDate) ??
                                _formatDate(booking.startDate) ??
                                'Completed',
                            isIOS: isIOS,
                            isSmallScreen: isSmallScreen,
                            isTablet: isTablet,
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 16),
                        itemCount: bookingProvider.completedBookings.length,
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
  }

  Widget _buildSearchBar(bool isIOS, bool isSmallScreen) {
    void handleSearch() {
      final query = _searchController.text.trim();
      context.read<CleanerBookingProvider>().fetchCompletedBookings(
        force: true,
        search: query,
      );
    }

    return isIOS
        ? CupertinoTextField(
            controller: _searchController,
            placeholder: 'SEARCH BOOKING ID',
            placeholderStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            style: const TextStyle(color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onSubmitted: (_) => handleSearch(),
            suffix: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minSize: 0,
                onPressed: handleSearch,
                child: const Icon(
                  CupertinoIcons.search,
                  color: Color(0xFF04CDFE),
                  size: 20,
                ),
              ),
            ),
          )
        : TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => handleSearch(),
            decoration: InputDecoration(
              hintText: 'SEARCH BOOKING ID',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: isSmallScreen ? 12 : 14,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF04CDFE)),
                onPressed: handleSearch,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF04CDFE), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          );
  }

  Widget _buildBookingCard({
    required CleanerBooking booking,
    required String title,
    required String subtitle,
    required String bookingId,
    required String status,
    required String service,
    required String location,
    required String dateTime,
    required bool isIOS,
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 24,
        vertical: isSmallScreen ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
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
                      title,
                      style: AppTheme.bebasNeue(
                        color: const Color(0xFF04CDFE),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
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
                            text: bookingId,
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
                  status.toUpperCase(),
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
          _buildDetailRow('SERVICE', service, isIOS, isSmallScreen),
          SizedBox(height: 12),
          _buildDetailRow('LOCATION', location, isIOS, isSmallScreen),
          SizedBox(height: 12),
          _buildDetailRow(
            'DATE & TIME',
            dateTime,
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
              child: isIOS
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF04CDFE),
                      borderRadius: BorderRadius.circular(24),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) =>
                                StaffBookingDetailsScreen(booking: booking),
                          ),
                        );
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StaffBookingDetailsScreen(booking: booking),
                          ),
                        );
                      },
                      child: Text(
                        'VIEW DETAILS',
                        style: AppTheme.bebasNeue(
                          fontSize: isSmallScreen ? 13 : 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
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

  Widget _buildErrorState({
    required String message,
    required bool isIOS,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.bebasNeue(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isIOS) {
    return Center(
      child: Text(
        'No completed bookings yet.',
        style: AppTheme.bebasNeue(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  String? _formatDate(DateTime? dateTime) {
    if (dateTime == null) return null;
    final local = dateTime.toLocal();
    final day =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$day • $time';
  }
}

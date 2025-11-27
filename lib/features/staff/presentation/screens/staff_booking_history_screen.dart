import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cleaner_booking_provider.dart';

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

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Center(
                  child: Text(
                    'BOOKING HISTORY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
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
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<CleanerBookingProvider>(
                  builder: (context, bookingProvider, _) {
                    if (bookingProvider.isCompletedLoading &&
                        bookingProvider.completedBookings.isEmpty) {
                      return const Center(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final booking =
                              bookingProvider.completedBookings[index];
                          return _buildBookingCard(
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
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
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
              color: Colors.white.withOpacity(0.5),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            style: const TextStyle(color: Colors.white),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                CupertinoIcons.search,
                color: Colors.white70,
                size: 20,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onSubmitted: (_) => handleSearch(),
            suffix: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: handleSearch,
              child: const Text('Search'),
            ),
          )
        : TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => handleSearch(),
            decoration: InputDecoration(
              hintText: 'SEARCH BOOKING ID',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 12 : 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white70,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: handleSearch,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
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
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
                      style: TextStyle(
                        color: const Color(0xFF04CDFE),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 12 : 14,
                        fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ID : ',
                            style: TextStyle(
                              color: const Color(0xFF04CDFE),
                              fontSize: isSmallScreen ? 12 : 14,
                              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                            ),
                          ),
                          TextSpan(
                            text: bookingId,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge - Green for completed
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
                  status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Service details
          _buildDetailRow('SERVICE', service, isIOS, isSmallScreen),
          const SizedBox(height: 12),
          _buildDetailRow('LOCATION', location, isIOS, isSmallScreen),
          const SizedBox(height: 12),
          _buildDetailRow(
            'DATE & TIME',
            dateTime,
            isIOS,
            isSmallScreen,
            isHighlighted: true,
          ),
          const SizedBox(height: 20),
          // View Details Button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 44 : 48,
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: const Color(0xFF04CDFE),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      // TODO: Navigate to booking details
                    },
                    child: Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04CDFE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: Navigate to booking details
                    },
                    child: Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF04CDFE) : Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isIOS) {
    return Center(
      child: Text(
        'No completed bookings yet.',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
        ),
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

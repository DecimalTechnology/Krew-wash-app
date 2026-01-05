import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cleaner_booking_provider.dart';
import '../../domain/models/booking_model.dart';
import 'staff_booking_details_screen.dart';

class StaffUpcomingBookingsScreen extends StatefulWidget {
  const StaffUpcomingBookingsScreen({super.key});

  @override
  State<StaffUpcomingBookingsScreen> createState() =>
      _StaffUpcomingBookingsScreenState();
}

class _StaffUpcomingBookingsScreenState
    extends State<StaffUpcomingBookingsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Add listener for search with debouncing
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerBookingProvider>().fetchAssignedBookings(force: true);
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer to debounce search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final query = _searchController.text.trim();
        debugPrint('🔍 [SEARCH] Debounced search query: "$query"');
        // Always use force: true to ensure search executes
        context.read<CleanerBookingProvider>().fetchAssignedBookings(
          force: true,
          search: query.isEmpty ? '' : query,
        );
      }
    });
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

        return Consumer<CleanerBookingProvider>(
          builder: (context, bookingProvider, _) {
            // Debug: Track Consumer rebuilds
            if (kDebugMode) {
              debugPrint(
                '🔍 [UI] Consumer rebuilt - Search: "${bookingProvider.assignedSearch}", Bookings: ${bookingProvider.assignedBookings.length}, Loading: ${bookingProvider.isAssignedLoading}',
              );
            }
            return RefreshIndicator(
              color: const Color(0xFF04CDFE),
              onRefresh: () =>
                  bookingProvider.fetchAssignedBookings(force: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          20,
                        ),
                        child: _buildSearchBar(isIOS, isSmallScreen),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'UPCOMING BOOKINGS',
                          style: AppTheme.bebasNeue(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: _buildBookingsSliver(
                      bookingProvider: bookingProvider,
                      isIOS: isIOS,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(bool isIOS, bool isSmallScreen) {
    void handleSearch() {
      // Cancel any pending debounced search
      _searchDebounceTimer?.cancel();

      final query = _searchController.text.trim();
      debugPrint('🔍 [SEARCH] Manual search query (Enter/Button): "$query"');
      // Pass empty string if query is empty, so it clears the search
      context.read<CleanerBookingProvider>().fetchAssignedBookings(
        force: true,
        search: query.isEmpty ? '' : query,
      );
    }

    return isIOS
        ? CupertinoTextField(
            controller: _searchController,
            placeholder: 'SEARCH BOOKING ID OR VEHICLE',
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
              hintText: 'SEARCH BOOKING ID OR VEHICLE',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: isSmallScreen ? 12 : 14,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF04CDFE),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF04CDFE)),
                onPressed: handleSearch,
              ),
            ),
          );
  }

  SliverList _buildBookingsSliver({
    required CleanerBookingProvider bookingProvider,
    required bool isIOS,
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    // Check if there's an active search
    final hasSearch = bookingProvider.assignedSearch.isNotEmpty;

    // Debug: Track when this method is called
    if (kDebugMode) {
      debugPrint(
        '🔍 [UI] _buildBookingsSliver called - Search: "$hasSearch", Query: "${bookingProvider.assignedSearch}", Loading: ${bookingProvider.isAssignedLoading}, Bookings: ${bookingProvider.assignedBookings.length}',
      );
    }

    // Show shimmer loading (show even when searching with existing bookings)
    if (bookingProvider.isAssignedLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: 20),
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
              child: _buildBookingCardShimmer(isIOS, isSmallScreen),
            );
          }),
        ]),
      );
    }

    // Show error state
    if (bookingProvider.assignedError != null &&
        bookingProvider.assignedBookings.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          _buildErrorState(
            message: bookingProvider.assignedError!,
            isIOS: isIOS,
            onRetry: () => bookingProvider.fetchAssignedBookings(
              force: true,
              search: hasSearch ? bookingProvider.assignedSearch : null,
            ),
          ),
        ]),
      );
    }

    // Filter bookings based on search or status
    final filteredBookings = hasSearch
        ? bookingProvider.assignedBookings.toList()
        : bookingProvider.assignedBookings.where((booking) {
            final status = booking.status.toLowerCase();
            return status == 'assigned' ||
                status == 'pending' ||
                status.contains('progress') ||
                status == 'in progress';
          }).toList();

    // Debug: Print filtering info
    if (kDebugMode) {
      debugPrint(
        '🔍 [UI] Total bookings from provider: ${bookingProvider.assignedBookings.length}',
      );
      debugPrint(
        '🔍 [UI] Has search: $hasSearch, Search query: "${bookingProvider.assignedSearch}"',
      );
      debugPrint('🔍 [UI] Filtered bookings count: ${filteredBookings.length}');
      if (filteredBookings.isNotEmpty) {
        final bookingIds = filteredBookings.map((b) => b.bookingId).join(', ');
        debugPrint('🔍 [UI] All filtered booking IDs: [$bookingIds]');
        debugPrint(
          '🔍 [UI] First filtered booking ID: ${filteredBookings.first.bookingId}',
        );
      }
    }

    // Show empty state if no bookings match
    if (filteredBookings.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔍 [UI] Showing empty state - hasSearch: $hasSearch');
      }
      return SliverList(
        delegate: SliverChildListDelegate([
          _buildEmptyState(
            isIOS,
            message: hasSearch
                ? 'No bookings found matching "${bookingProvider.assignedSearch}"'
                : null,
          ),
        ]),
      );
    }

    // Use key to force rebuild when search changes
    return SliverList(
      key: ValueKey(
        'bookings_${hasSearch ? bookingProvider.assignedSearch : 'all'}',
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final booking = filteredBookings[index];

        // Debug: Print what's being displayed
        if (kDebugMode && index == 0) {
          debugPrint(
            '🔍 [UI] Displaying booking at index $index: ${booking.bookingId}',
          );
          debugPrint(
            '🔍 [UI] Total bookings to display: ${filteredBookings.length}',
          );
        }
        final packageName =
            booking.package?.packageId?.name ?? 'Assigned Package';
        final customer = booking.user?.name ?? 'Customer';
        // Location logic: Match details page - building name OR apartment number
        // Format apartment number consistently
        String location;
        if (booking.buildingInfo?.name != null &&
            booking.buildingInfo!.name.trim().isNotEmpty) {
          location = booking.buildingInfo!.name.trim();
        } else if (booking.user?.apartmentNumber != null &&
            booking.user!.apartmentNumber!.trim().isNotEmpty) {
          location = booking.user!.apartmentNumber!.trim();
        } else {
          location = 'N/A';
        }

        // Debug: Print location info
        if (kDebugMode && index == 0) {
          print('🔵 LOCATION DEBUG for Booking ${booking.bookingId}:');
          print('Building Info: ${booking.buildingInfo?.name}');
          print('Building ID: ${booking.buildingId}');
          print('Vehicle Info: ${booking.vehicleInfo?.vehicleNumber}');
          print('User Apartment: ${booking.user?.apartmentNumber}');
          print('Final Location: $location');
        }
        final schedule = _formatDate(booking.startDate);

        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
          child: _buildBookingCard(
            booking: booking,
            title: packageName,
            subtitle: customer,
            bookingId: booking.bookingId,
            status: booking.status,
            service: booking.package?.packageId?.description ?? 'Not available',
            location: location,
            dateTime: schedule,
            isIOS: isIOS,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
          ),
        );
      }, childCount: filteredBookings.length),
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
          SizedBox(height: 12),
          _buildDetailRow(
            'START DATE',
            _formatDateOnly(booking.startDate),
            isIOS,
            isSmallScreen,
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            'END DATE',
            _formatDateOnly(booking.endDate),
            isIOS,
            isSmallScreen,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load bookings',
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: AppTheme.bebasNeue(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onRetry, child: Text('Retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isIOS, {String? message}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message ?? 'No bookings found',
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message != null
                ? 'Try a different search term or clear the search to see all bookings.'
                : 'Assigned bookings will appear here. Try refreshing to check for new tasks.',
            style: AppTheme.bebasNeue(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Schedule pending';
    final d = date.toLocal();
    final month = _monthShort(d.month);
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute ${amPm.toLowerCase()}';
    return '${month.toUpperCase()} ${d.day}, $time';
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return 'N/A';
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildBookingCardShimmer(bool isIOS, bool isSmallScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.25),
      child: Container(
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
                      Container(
                        height: isSmallScreen ? 14 : 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: isSmallScreen ? 12 : 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: isSmallScreen ? 12 : 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            SizedBox(height: 18),
            // Service details shimmer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 12 : 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 12 : 14,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 12 : 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 12 : 14,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 12 : 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 12 : 14,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 12 : 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 12 : 14,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 12 : 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 12 : 14,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Button shimmer
            Center(
              child: Container(
                width: isSmallScreen ? 200 : 220,
                height: isSmallScreen ? 40 : 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

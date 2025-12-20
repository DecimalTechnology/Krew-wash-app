import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../staff/domain/models/booking_model.dart';
import '../providers/customer_booking_provider.dart';
import 'customer_booking_details_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key, this.onBack});

  /// For tab-based navigation: parent can provide a callback to switch tabs
  /// (e.g., go to Car Listing tab).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerBookingProvider(),
      child: _MyBookingsView(onBack: onBack),
    );
  }
}

class _MyBookingsView extends StatefulWidget {
  const _MyBookingsView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<_MyBookingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBookingProvider>().fetchBookings(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOS() : _buildAndroid();
  }

  Widget _buildIOS() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildContent(isIOS: true),
    );
  }

  Widget _buildAndroid() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(isIOS: false),
    );
  }

  Widget _buildContent({required bool isIOS}) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmall = screenWidth < 400;
        final horizontalPadding = isSmall ? 16.0 : 20.0;

        return Consumer<CustomerBookingProvider>(
          builder: (context, provider, _) {
            final filtered = provider.bookings;

            // Fixed header section
            final headerSection = SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      16,
                    ),
                    child: _buildTopHeader(
                      context,
                      provider: provider,
                      isSmall: isSmall,
                      isIOS: isIOS,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ALL BOOKINGS',
                        style: AppTheme.bebasNeue(
                          color: Colors.white,
                          fontSize: isSmall ? 16 : 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );

            // Scrollable list section
            Widget listContent;
            if (provider.isLoading && provider.bookings.isEmpty) {
              listContent = Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: isIOS
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const CircularProgressIndicator(color: Colors.white),
                ),
              );
            } else if (provider.error != null && provider.bookings.isEmpty) {
              // Error state with pull-to-refresh support
              if (isIOS) {
                listContent = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () => provider.fetchBookings(force: true),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: AppTheme.bebasNeue(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                listContent = RefreshIndicator(
                  color: const Color(0xFF04CDFE),
                  onRefresh: () => provider.fetchBookings(force: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: AppTheme.bebasNeue(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            } else if (filtered.isEmpty) {
              // Empty state with pull-to-refresh support
              if (isIOS) {
                listContent = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () => provider.fetchBookings(force: true),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No bookings found',
                            style: AppTheme.bebasNeue(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                listContent = RefreshIndicator(
                  color: const Color(0xFF04CDFE),
                  onRefresh: () => provider.fetchBookings(force: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No bookings found',
                            style: AppTheme.bebasNeue(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            } else {
              if (isIOS) {
                // iOS: Use CustomScrollView with CupertinoSliverRefreshControl
                listContent = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () => provider.fetchBookings(force: true),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final booking = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _bookingCard(
                              booking,
                              isSmall: isSmall,
                              isIOS: isIOS,
                              onTap: () async {
                                await Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(
                                  CupertinoPageRoute(
                                    builder: (_) =>
                                        CustomerBookingDetailsScreen(
                                          booking: booking,
                                        ),
                                  ),
                                );
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100 + MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                  ],
                );
              } else {
                // Android: Use ListView with RefreshIndicator
                listContent = ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _bookingCard(
                        booking,
                        isSmall: isSmall,
                        isIOS: isIOS,
                        onTap: () async {
                          await Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => CustomerBookingDetailsScreen(
                                booking: booking,
                              ),
                            ),
                          );
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    );
                  },
                );
                listContent = RefreshIndicator(
                  color: const Color(0xFF04CDFE),
                  onRefresh: () => provider.fetchBookings(force: true),
                  child: listContent,
                );
                // Add bottom padding for Android
                listContent = Padding(
                  padding: EdgeInsets.only(
                    bottom: 100 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: listContent,
                );
              }
            }

            return Column(
              children: [
                headerSection,
                Expanded(child: listContent),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopHeader(
    BuildContext context, {
    required CustomerBookingProvider provider,
    required bool isSmall,
    required bool isIOS,
  }) {
    return Row(
      children: [
        StandardBackButton(
          onPressed: () async {
            // Prefer tab switch callback (no blank screen issues).
            if (widget.onBack != null) {
              widget.onBack!();
              return;
            }

            // Fallback: try pop (works if this screen was pushed).
            final navigator = Navigator.of(context);
            final didPop = await navigator.maybePop();
            if (!didPop) {
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              if (rootNavigator != navigator) {
                await rootNavigator.maybePop();
              }
            }
          },
        ),
        Expanded(
          child: Text(
            'MY BOOKINGS',
            textAlign: TextAlign.center,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmall ? 18 : 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Refresh button
        if (isIOS)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: provider.isLoading
                ? null
                : () {
                    provider.fetchBookings(force: true);
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: provider.isLoading
                  ? const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 10,
                    )
                  : const Icon(
                      CupertinoIcons.arrow_clockwise,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          )
        else
          IconButton(
            onPressed: provider.isLoading
                ? null
                : () {
                    provider.fetchBookings(force: true);
                  },
            icon: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF04CDFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _bookingCard(
    CleanerBooking booking, {
    required bool isSmall,
    required bool isIOS,
    required VoidCallback onTap,
  }) {
    final status = booking.status.isNotEmpty
        ? booking.status.toUpperCase()
        : 'N/A';
    final bookingId = booking.bookingId.isNotEmpty
        ? booking.bookingId
        : booking.id;
    final vehicleModel =
        (booking.vehicleInfo?.vehicleModel?.trim().isNotEmpty == true)
        ? booking.vehicleInfo!.vehicleModel!
        : 'VEHICLE';

    // Status color
    final statusColor = status.contains('COMPLET')
        ? const Color(0xFF22C55E)
        : status.contains('PROGRESS')
        ? const Color(0xFFFFA500)
        : status.contains('ASSIGNED')
        ? const Color(0xFF04CDFE)
        : Colors.white70;

    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 18,
        vertical: isSmall ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Model (Title)
                Text(
                  vehicleModel.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isSmall ? 16 : 18,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                // Booking ID (Subtitle)
                Text(
                  bookingId.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bebasNeue(
                    color: const Color(0xFF04CDFE),
                    fontSize: isSmall ? 13 : 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isSmall ? 11 : 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white38,
            size: isSmall ? 14 : 16,
          ),
        ],
      ),
    );

    // InkWell requires a Material ancestor; iOS uses CupertinoPageScaffold.
    if (isIOS) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      ),
    );
  }
}

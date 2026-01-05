import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../staff/domain/models/booking_model.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../providers/customer_booking_provider.dart';

class CustomerBookingDetailsScreen extends StatefulWidget {
  const CustomerBookingDetailsScreen({super.key, required this.booking});

  final CleanerBooking booking;

  @override
  State<CustomerBookingDetailsScreen> createState() =>
      _CustomerBookingDetailsScreenState();
}

class _CustomerBookingDetailsScreenState
    extends State<CustomerBookingDetailsScreen> {
  String? _loadedVehicleId;
  Map<String, dynamic>? _vehicle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBookingProvider>().fetchBookingDetails(
        widget.booking.id,
      );
    });
  }

  @override
  void dispose() {
    context.read<CustomerBookingProvider>().clearSelectedBooking();
    super.dispose();
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
    return Consumer<CustomerBookingProvider>(
      builder: (context, provider, _) {
        final booking = provider.selectedBooking ?? widget.booking;
        final isLoading =
            provider.isDetailsLoading && provider.selectedBooking == null;
        final error = provider.detailsError;

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmall = screenWidth < 400;
        final horizontalPadding = isSmall ? 16.0 : 20.0;

        // Attempt to load vehicle details (if backend provides vehicleId)
        final vehicleId = booking.vehicleId;
        if (vehicleId != null &&
            vehicleId.isNotEmpty &&
            vehicleId != _loadedVehicleId) {
          _loadedVehicleId = vehicleId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vehicleId == 'demo_vehicle') {
              setState(() {
                _vehicle = {
                  '_id': 'demo_vehicle',
                  'vehicleModel': 'CHEVROLET AVEO U-VA',
                  'vehicleNumber': 'JFM 624 J 12',
                  'color': 'BLACK',
                  'parkingNumber': 'A15',
                };
              });
              return;
            }
            _loadVehicle(vehicleId);
          });
        }

        Widget body;
        if (isLoading) {
          body = Center(
            child: isIOS
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const CircularProgressIndicator(color: Colors.white),
          );
        } else if (error != null && provider.selectedBooking == null) {
          body = Center(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error,
                    style: AppTheme.bebasNeue(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        provider.fetchBookingDetails(widget.booking.id),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black],
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (isIOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () =>
                        provider.fetchBookingDetails(widget.booking.id),
                  )
                else
                  const SliverToBoxAdapter(),
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        10,
                      ),
                      child: _buildTopHeader(context, isSmall: isSmall),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionTitle('BOOKING OVERVIEW'),
                      const SizedBox(height: 10),
                      _buildBookingOverviewCard(booking, isSmall: isSmall),
                      const SizedBox(height: 18),
                      _buildSectionTitle('SERVICE BREAKDOWN'),
                      const SizedBox(height: 10),
                      if (booking.package != null)
                        _buildServiceSummaryCard(
                          title:
                              booking.package!.packageId?.name.isNotEmpty ==
                                  true
                              ? booking.package!.packageId!.name
                              : 'MAIN PACKAGE',
                          subtitle: 'MAIN PACKAGE',
                          total: booking.package!.totalSessions,
                          completed: booking.package!.sessions
                              .where((s) => s.isCompleted)
                              .length,
                          isSmall: isSmall,
                          highlight: true,
                        ),
                      if (booking.package != null) const SizedBox(height: 12),
                      ...booking.addons.map(
                        (addon) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildServiceSummaryCard(
                            title: addon.displayName.isNotEmpty
                                ? addon.displayName.toUpperCase()
                                : 'ADD-ON',
                            subtitle: 'ADD-ON',
                            total: addon.totalSessions,
                            completed: addon.sessions
                                .where((s) => s.isCompleted)
                                .length,
                            isSmall: isSmall,
                            highlight: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle('SESSION LISTING'),
                      const SizedBox(height: 10),
                      if (booking.package != null)
                        _sessionsSection(
                          isSmall: isSmall,
                          title: 'PACKAGE SESSIONS',
                          total: booking.package!.totalSessions,
                          sessions: booking.package!.sessions,
                        ),
                      if (booking.package != null && booking.addons.isNotEmpty)
                        const SizedBox(height: 12),
                      if (booking.addons.isNotEmpty)
                        ...booking.addons.map(
                          (addon) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _addonSessionsCard(addon, isSmall: isSmall),
                          ),
                        ),
                      const SizedBox(height: 18),
                      _buildSectionTitle('SERVICE MEDIA'),
                      const SizedBox(height: 6),
                      Text(
                        'Real-time verification photos',
                        style: AppTheme.bebasNeue(
                          color: Colors.white54,
                          fontSize: isSmall ? 11 : 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildServiceMediaGrid(booking, isSmall: isSmall),
                    ]),
                  ),
                ),
              ],
            ),
          );

          if (!isIOS) {
            body = RefreshIndicator(
              color: const Color(0xFF04CDFE),
              onRefresh: () => provider.fetchBookingDetails(widget.booking.id),
              child: body,
            );
          }
        }

        return body;
      },
    );
  }

  Future<void> _loadVehicle(String vehicleId) async {
    try {
      final vehicles = await const VehicleRepository().getVehicles();
      final match = vehicles.firstWhere(
        (v) =>
            v['_id']?.toString() == vehicleId ||
            v['id']?.toString() == vehicleId,
        orElse: () => const <String, dynamic>{},
      );
      if (!mounted) return;
      setState(() {
        _vehicle = match.isEmpty ? null : match;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vehicle = null;
      });
    }
  }

  Widget _buildTopHeader(BuildContext context, {required bool isSmall}) {
    return Row(
      children: [
        StandardBackButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        Expanded(
          child: Text(
            'DETAILS',
            textAlign: TextAlign.center,
            style: AppTheme.bebasNeue(
              color: Colors.white,
              fontSize: isSmall ? 18 : 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTheme.bebasNeue(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 14,
          letterSpacing: 3.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBookingOverviewCard(
    CleanerBooking booking, {
    required bool isSmall,
  }) {
    final model =
        (_vehicle?['vehicleModel']?.toString().trim().isNotEmpty == true)
        ? _vehicle!['vehicleModel'].toString()
        : 'VEHICLE';
    final plate =
        (_vehicle?['vehicleNumber']?.toString().trim().isNotEmpty == true)
        ? _vehicle!['vehicleNumber'].toString()
        : (booking.bookingId.isNotEmpty ? booking.bookingId : booking.id);
    final color = (_vehicle?['color']?.toString().trim().isNotEmpty == true)
        ? _vehicle!['color'].toString().toUpperCase()
        : 'N/A';
    final spot =
        (_vehicle?['parkingNumber']?.toString().trim().isNotEmpty == true)
        ? 'SPOT ${_vehicle!['parkingNumber'].toString().toUpperCase()}'
        : (booking.user?.apartmentNumber?.isNotEmpty == true
              ? 'SPOT ${booking.user!.apartmentNumber!.toUpperCase()}'
              : 'SPOT N/A');
    final buildingName = booking.buildingInfo?.name.trim() ?? '';
    final spotValue = buildingName.isNotEmpty
        ? buildingName.toUpperCase()
        : spot;
    final bookingIdValue =
        (booking.bookingId.isNotEmpty ? booking.bookingId : booking.id)
            .toUpperCase();
    final paymentStatus = (booking.payment?.status.trim().isNotEmpty == true)
        ? booking.payment!.status.trim().toUpperCase()
        : 'N/A';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 18 : 22,
        vertical: isSmall ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  model.toUpperCase(),
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isSmall ? 18 : 22,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'START: ${_formatBookingDate(booking.startDate)}',
                    style: AppTheme.bebasNeue(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: isSmall ? 12 : 13,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'END: ${_formatBookingDate(booking.endDate)}',
                    style: AppTheme.bebasNeue(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: isSmall ? 12 : 13,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Text(
              plate.toUpperCase(),
              style: AppTheme.bebasNeue(
                color: Colors.white70,
                fontSize: isSmall ? 12 : 13,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'BOOKING ID: $bookingIdValue',
            style: AppTheme.bebasNeue(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: isSmall ? 12 : 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'PAYMENT STATUS: $paymentStatus',
            style: AppTheme.bebasNeue(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: isSmall ? 12 : 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _overviewMiniTile(
                  icon: Icons.palette_outlined,
                  label: 'COLOR',
                  value: color,
                  isSmall: isSmall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _overviewMiniTile(
                  icon: Icons.location_on_outlined,
                  label: 'SPOT',
                  value: spotValue,
                  isSmall: isSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewMiniTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmall,
  }) {
    return Row(
      children: [
        Container(
          width: isSmall ? 36 : 40,
          height: isSmall ? 36 : 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, color: Colors.white70, size: isSmall ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bebasNeue(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: isSmall ? 11 : 12,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isSmall ? 14 : 16,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSummaryCard({
    required String title,
    required String subtitle,
    required int total,
    required int completed,
    required bool isSmall,
    required bool highlight,
  }) {
    final progress = total <= 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final borderColor = highlight
        ? const Color(0xFF04CDFE).withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.12);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 16 : 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bebasNeue(
                        color: highlight
                            ? const Color(0xFF04CDFE)
                            : Colors.white,
                        fontSize: isSmall ? 16 : 18,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toUpperCase(),
                      style: AppTheme.bebasNeue(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: isSmall ? 12 : 13,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  '$completed/$total COMPLETED',
                  style: AppTheme.bebasNeue(
                    color: Colors.white70,
                    fontSize: isSmall ? 11 : 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                highlight ? const Color(0xFF04CDFE) : const Color(0xFF04CDFE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMediaGrid(
    CleanerBooking booking, {
    required bool isSmall,
  }) {
    final urls = <String>[
      ...?booking.package?.sessions.expand((s) => s.images),
      ...booking.addons.expand((a) => a.sessions.expand((s) => s.images)),
    ].where((u) => u.trim().isNotEmpty).toList();

    if (urls.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
        child: Text(
          'No media available.',
          style: AppTheme.bebasNeue(
            color: Colors.white54,
            fontSize: isSmall ? 12 : 14,
          ),
        ),
      );
    }

    final shown = urls.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shown.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final url = shown[index];
        final isAsset = url.startsWith('asset:');
        final assetPath = isAsset ? url.replaceFirst('asset:', '') : '';
        // Find the actual index in the full urls list
        final actualIndex = urls.indexOf(url);
        return GestureDetector(
          onTap: () => _showImagePreview(
            context,
            urls,
            actualIndex >= 0 ? actualIndex : index,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: Colors.white.withValues(alpha: 0.06),
              child: isAsset
                  ? Image.asset(assetPath, fit: BoxFit.cover)
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        color: Colors.white.withValues(alpha: 0.06),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white38,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.white.withValues(alpha: 0.06),
                          alignment: Alignment.center,
                          child: isSmall
                              ? const CupertinoActivityIndicator()
                              : const CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _sessionsSection({
    required bool isSmall,
    required String title,
    required int total,
    required List<PackageSession> sessions,
  }) {
    final completed = sessions.where((s) => s.isCompleted).length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isSmall ? 16 : 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$completed/$total',
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: isSmall ? 14 : 16,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sessions.isEmpty)
            Text(
              'No sessions found.',
              style: AppTheme.bebasNeue(
                color: Colors.white54,
                fontSize: isSmall ? 12 : 14,
              ),
            )
          else
            ...List.generate(sessions.length, (idx) {
              final s = sessions[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _sessionRow(
                  label: 'SESSION ${idx + 1}',
                  isCompleted: s.isCompleted,
                  date: s.date,
                  isSmall: isSmall,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _addonSessionsCard(BookingAddon addon, {required bool isSmall}) {
    final completed = addon.sessions.where((s) => s.isCompleted).length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  addon.displayName.isNotEmpty
                      ? addon.displayName.toUpperCase()
                      : 'ADD-ON',
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isSmall ? 16 : 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$completed/${addon.totalSessions}',
                style: AppTheme.bebasNeue(
                  color: const Color(0xFF04CDFE),
                  fontSize: isSmall ? 14 : 16,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (addon.sessions.isEmpty)
            Text(
              'No sessions found.',
              style: AppTheme.bebasNeue(
                color: Colors.white54,
                fontSize: isSmall ? 12 : 14,
              ),
            )
          else
            ...List.generate(addon.sessions.length, (idx) {
              final s = addon.sessions[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _sessionRow(
                  label: 'SESSION ${idx + 1}',
                  isCompleted: s.isCompleted,
                  date: s.date,
                  isSmall: isSmall,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _sessionRow({
    required String label,
    required bool isCompleted,
    required DateTime? date,
    required bool isSmall,
  }) {
    final statusText = isCompleted ? 'COMPLETED' : 'PENDING';
    final dateText = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.bebasNeue(
                color: Colors.white,
                fontSize: isSmall ? 13 : 14,
                letterSpacing: 0.9,
              ),
            ),
          ),
          if (dateText.isNotEmpty) ...[
            Text(
              dateText,
              style: AppTheme.bebasNeue(
                color: Colors.white70,
                fontSize: isSmall ? 12 : 13,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            statusText,
            style: AppTheme.bebasNeue(
              color: isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF04CDFE),
              fontSize: isSmall ? 12 : 13,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBookingDate(DateTime? date) {
    if (date == null) return 'N/A';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  void _showImagePreview(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) =>
              _ImagePreviewScreen(images: urls, initialIndex: initialIndex),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              _ImagePreviewScreen(images: urls, initialIndex: initialIndex),
        ),
      );
    }
  }
}

class _ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagePreviewScreen({required this.images, required this.initialIndex});

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isIOS ? CupertinoIcons.back : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: AppTheme.bebasNeue(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final url = widget.images[index];
          final isAsset = url.startsWith('asset:');
          final assetPath = isAsset ? url.replaceFirst('asset:', '') : '';

          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: isAsset
                  ? Image.asset(assetPath, fit: BoxFit.contain)
                  : Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, __) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white38,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: AppTheme.bebasNeue(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: isIOS
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

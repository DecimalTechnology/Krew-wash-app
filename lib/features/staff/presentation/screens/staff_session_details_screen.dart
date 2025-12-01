import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/models/booking_model.dart';

class StaffSessionDetailsScreen extends StatelessWidget {
  final CleanerBooking booking;
  final String serviceName;
  final PackageSession session;
  final int sessionNumber;
  final int totalSessions;
  final int completedCount;

  const StaffSessionDetailsScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.session,
    required this.sessionNumber,
    required this.totalSessions,
    required this.completedCount,
  });

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

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, isIOS, isSmallScreen),
                const SizedBox(height: 24),
                // Sessions Overview
                _buildSessionsOverview(
                  completedCount,
                  totalSessions,
                  isIOS,
                  isSmallScreen,
                ),
                const SizedBox(height: 24),
                // Session Details Card
                _buildSessionDetailsCard(isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 24),
                // Photos Section
                _buildPhotosSection(isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isIOS, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                'Session Details',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SESSION $sessionNumber DETAILS',
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

  Widget _buildSessionDetailsCard(
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
              if (session.isCompleted)
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
                ),
            ],
          ),
          if (session.isCompleted) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 16),
            _buildDetailRow(
              'COMPLETED ON',
              _formatDateTime(session.date),
              isIOS,
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'COMPLETED BY',
              session.completedBy?.toUpperCase() ?? 'N/A',
              isIOS,
              isSmallScreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 100 : 120,
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

  Widget _buildPhotosSection(bool isIOS, bool isSmallScreen, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PHOTOS',
              style: TextStyle(
                color: const Color(0xFF04CDFE),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
              ),
            ),
            isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Open camera/gallery
                    },
                    child: const Icon(
                      CupertinoIcons.camera,
                      color: Color(0xFF04CDFE),
                      size: 24,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF04CDFE),
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Open camera/gallery
                    },
                  ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPhotoPlaceholder(isIOS, isSmallScreen, isTablet),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(bool isIOS, bool isSmallScreen, bool isTablet) {
    final hasPhotos = session.images.isNotEmpty;

    if (hasPhotos) {
      // Show photo grid if images exist
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: session.images.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                session.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    // Show placeholder if no photos
    return Container(
      height: isTablet ? 300 : 200,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isIOS ? 26 : 22),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isIOS ? CupertinoIcons.camera : Icons.camera_alt,
            color: Colors.grey[600],
            size: isTablet ? 80 : 60,
          ),
          const SizedBox(height: 16),
          Text(
            'NO PHOTOS UPLOADED FOR THIS SESSION',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 12 : 14,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
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
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[(d.month - 1).clamp(0, 11)]} ${d.day}, ${d.year} ${hour}:$minute $amPm';
  }
}

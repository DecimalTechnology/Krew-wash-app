import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StaffBookingHistoryScreen extends StatelessWidget {
  const StaffBookingHistoryScreen({super.key});

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

        return SafeArea(
          child: Column(
            children: [
              // Header Title
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
              const SizedBox(height: 20),
              // Bookings List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    _buildBookingCard(
                      vehicleModel: 'CHEVROLET AVED U-VA',
                      vehicleNumber: 'JFM 624 J12',
                      bookingId: 'BOOKING 01',
                      status: 'COMPLETED',
                      service: 'MONTHLY CAR WASH + INTERIOR CLEANING',
                      location: 'PARKING A 15',
                      dateTime: 'NOV 15, 10:00 AM',
                      isIOS: isIOS,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 16),
                    _buildBookingCard(
                      vehicleModel: 'CHEVROLET OPTRA SRV',
                      vehicleNumber: 'JPM 034 H 32',
                      bookingId: 'BOOKING 02',
                      status: 'COMPLETED',
                      service: 'MONTHLY CAR WASH + INTERIOR CLEANING',
                      location: 'PARKING A 16',
                      dateTime: 'NOV 21, 11:00 AM',
                      isIOS: isIOS,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingCard({
    required String vehicleModel,
    required String vehicleNumber,
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
        color: const Color(0xFF1A1A1A),
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
                      vehicleModel,
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
                      vehicleNumber,
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
                  status,
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
}

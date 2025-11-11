import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/constants/size_constants.dart';

class ActionCardsWidget extends StatelessWidget {
  const ActionCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.getResponsivePadding(screenWidth),
        vertical: SizeConstants.getResponsivePadding(screenWidth) + 3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Column - Full height card
          Expanded(
            child: _buildProTipsCard(
              context,
              title: 'PRO TIPS & TRICKS',
              icon: Icons.lightbulb_outline,
              onTap: () {
                Navigator.pushNamed(context, Routes.customerProTips);
              },
            ),
          ),
          SizedBox(width: SizeConstants.getResponsiveSpacing(screenWidth)),
          // Second Column - 2 cards stacked
          Expanded(
            child: Column(
              children: [
                // Scheduled Card
                _buildCard(
                  context,
                  title: 'SCHEDULED',
                  icon: Icons.schedule,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.customerPackageSelection,
                    );
                  },
                ),
                SizedBox(
                  height: SizeConstants.getResponsiveSpacing(screenWidth),
                ),
                // History Card
                _buildCard(
                  context,
                  title: 'HISTORY',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.customerHistory);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: SizeConstants.getResponsiveButtonHeight(screenWidth) * 4,
        padding: EdgeInsets.all(
          SizeConstants.getResponsivePadding(screenWidth),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF01031C).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen
                          ? 12
                          : isMediumScreen
                          ? 14
                          : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 4 : 8),
                Container(
                  width: isSmallScreen ? 16 : 20,
                  height: isSmallScreen ? 16 : 20,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: isSmallScreen ? 8 : 10,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            // Speedometer gauge
            Center(
              child: SizedBox(
                width: isSmallScreen
                    ? 50
                    : isMediumScreen
                    ? 70
                    : 90,
                height: isSmallScreen
                    ? 30
                    : isMediumScreen
                    ? 40
                    : 50,
                child: CustomPaint(painter: SpeedometerPainter()),
              ),
            ),
            SizedBox(
              height: isSmallScreen
                  ? 8
                  : isMediumScreen
                  ? 12
                  : 16,
            ),
            // Rating text
            Text(
              'PROUDLY RATED',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? 8
                    : isMediumScreen
                    ? 12
                    : 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(
              height: isSmallScreen
                  ? 2
                  : isMediumScreen
                  ? 4
                  : 6,
            ),
            Text(
              '4.8 STARS ON GOOGLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? 10
                    : isMediumScreen
                    ? 12
                    : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;
    final isLargeScreen = screenWidth >= 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmallScreen
            ? 75
            : isMediumScreen
            ? 95
            : 120,
        padding: EdgeInsets.all(
          isSmallScreen
              ? 10
              : isMediumScreen
              ? 12
              : 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF01031C).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isSmallScreen
                      ? 20
                      : isMediumScreen
                      ? 24
                      : 28,
                ),
                Container(
                  width: isSmallScreen
                      ? 20
                      : isMediumScreen
                      ? 24
                      : 28,
                  height: isSmallScreen
                      ? 20
                      : isMediumScreen
                      ? 24
                      : 28,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen
                          ? 10
                          : isMediumScreen
                          ? 12
                          : 14,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: isSmallScreen
                        ? 10
                        : isMediumScreen
                        ? 12
                        : 14,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? 12
                    : isMediumScreen
                    ? 14
                    : 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF04CDFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw semi-circular arc (speedometer background)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14, // Start from left (π radians)
      3.14, // End at right (π radians)
      false,
      paint,
    );

    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final needleLength = radius * 0.7;
    final needleAngle = 0.5; // Pointing towards the right (4.8/5.0 position)

    final needleEndX = center.dx + needleLength * cos(needleAngle);
    final needleEndY = center.dy - needleLength * sin(needleAngle);

    canvas.drawLine(center, Offset(needleEndX, needleEndY), needlePaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, centerDotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

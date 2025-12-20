import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/standard_back_button.dart';

class MyPackageScreen extends StatelessWidget {
  const MyPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return isIOS
        ? _buildIOSScreen(context, screenWidth)
        : _buildAndroidScreen(context, screenWidth);
  }

  Widget _buildIOSScreen(BuildContext context, double screenWidth) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildContent(context, screenWidth, true),
    );
  }

  Widget _buildAndroidScreen(BuildContext context, double screenWidth) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(context, screenWidth, false),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth, bool isIOS) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/CustomerHome/homebg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(context, isIOS, screenWidth),

              // Car Illustration Section
              _buildCarIllustrationSection(context),

              // Progress Card
              _buildProgressCard(context),

              // Next Car Wash Info
              _buildNextCarWashInfo(context),

              // Add On Button
              _buildAddOnButton(context, isIOS),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isIOS, double screenWidth) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;
    final isVeryLargeScreen = screenSize.width > 600;

    return Container(
      padding: EdgeInsets.all(
        isVeryLargeScreen
            ? 28.0
            : isLargeScreen
            ? 24.0
            : 20.0,
      ),
      child: Row(
        children: [
          // Back Button
          StandardBackButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final didPop = await navigator.maybePop();
              if (!didPop) {
                final rootNavigator = Navigator.of(
                  context,
                  rootNavigator: true,
                );
                if (rootNavigator != navigator) {
                  await rootNavigator.maybePop();
                }
              }
            },
          ),
          // Centered Title
          Expanded(
            child: Text(
              'MY PACKAGE',
              textAlign: TextAlign.center,
              style: AppTextStyles.bebasNeue(
                fontSize: isVeryLargeScreen
                    ? 24
                    : isLargeScreen
                    ? 22
                    : 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(width: 40), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildCarIllustrationSection(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isVeryLargeScreen = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isVeryLargeScreen
            ? 32.0
            : isLargeScreen
            ? 24.0
            : 16.0,
        vertical: isVeryLargeScreen
            ? 24.0
            : isLargeScreen
            ? 20.0
            : 12.0,
      ),
      child: Column(
        children: [
          // Car Illustration with Clock
          Stack(
            alignment: Alignment.center,
            children: [
              // Car Image - More responsive sizing
              Container(
                width: isVeryLargeScreen
                    ? 250
                    : isLargeScreen
                    ? 200
                    : screenWidth * 0.4,
                height: isVeryLargeScreen
                    ? 125
                    : isLargeScreen
                    ? 100
                    : screenWidth * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/loginScreen/car.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Clock Icon - More responsive positioning
              Positioned(
                top: isVeryLargeScreen
                    ? 12
                    : isLargeScreen
                    ? 10
                    : 6,
                right: isVeryLargeScreen
                    ? 25
                    : isLargeScreen
                    ? 20
                    : screenWidth * 0.05,
                child: Container(
                  width: isVeryLargeScreen
                      ? 45
                      : isLargeScreen
                      ? 40
                      : 28,
                  height: isVeryLargeScreen
                      ? 45
                      : isLargeScreen
                      ? 40
                      : 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      isVeryLargeScreen
                          ? 22
                          : isLargeScreen
                          ? 20
                          : 14,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.black,
                    size: isVeryLargeScreen
                        ? 22
                        : isLargeScreen
                        ? 20
                        : 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: isVeryLargeScreen
                ? 24
                : isLargeScreen
                ? 20
                : 12,
          ),

          // Package Text - Better spacing
          Text(
            'SCHEDULED PACKAGE',
            style: AppTextStyles.bebasNeue(
              fontSize: isVeryLargeScreen
                  ? 18
                  : isLargeScreen
                  ? 16
                  : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(
            height: isVeryLargeScreen
                ? 12
                : isLargeScreen
                ? 8
                : 6,
          ),

          Text(
            'PREMIUM PACKAGE',
            style: AppTextStyles.bebasNeue(
              fontSize: isVeryLargeScreen
                  ? 32
                  : isLargeScreen
                  ? 28
                  : 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isVeryLargeScreen = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isVeryLargeScreen
            ? 32.0
            : isLargeScreen
            ? 24.0
            : 16.0,
        vertical: isVeryLargeScreen
            ? 24.0
            : isLargeScreen
            ? 20.0
            : 12.0,
      ),
      padding: EdgeInsets.all(
        isVeryLargeScreen
            ? 28.0
            : isLargeScreen
            ? 24.0
            : 18.0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(isVeryLargeScreen ? 20 : 16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.1),
            blurRadius: isVeryLargeScreen ? 15 : 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // CAR WASH text
          Text(
            'CAR WASH',
            style: AppTextStyles.bebasNeue(
              fontSize: isVeryLargeScreen
                  ? 22
                  : isLargeScreen
                  ? 18
                  : 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF04CDFE),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(
            height: isVeryLargeScreen
                ? 16
                : isLargeScreen
                ? 12
                : 8,
          ),

          // Monthly 5 Wash text
          Text(
            '[ MONTHLY 5 WASH ]',
            style: AppTextStyles.bebasNeue(
              fontSize: isVeryLargeScreen
                  ? 20
                  : isLargeScreen
                  ? 18
                  : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(
            height: isVeryLargeScreen
                ? 24
                : isLargeScreen
                ? 20
                : 16,
          ),

          // Semi-circle Progress
          _buildSemiCircleProgress(context),

          SizedBox(
            height: isVeryLargeScreen
                ? 20
                : isLargeScreen
                ? 16
                : 12,
          ),

          // Completed text
          Text(
            'COMPLETED',
            style: AppTextStyles.bebasNeue(
              fontSize: isVeryLargeScreen
                  ? 18
                  : isLargeScreen
                  ? 16
                  : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF04CDFE),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemiCircleProgress(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isVeryLargeScreen = screenWidth > 600;

    final progressWidth = isVeryLargeScreen
        ? 180.0
        : isLargeScreen
        ? 160.0
        : screenWidth * 0.35;
    final progressHeight = isVeryLargeScreen
        ? 90.0
        : isLargeScreen
        ? 80.0
        : screenWidth * 0.175;

    return SizedBox(
      width: progressWidth,
      height: progressHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-circle background
          Image.asset(
            'assets/CustomerHome/semicircle.png',
            width: progressWidth,
            height: progressHeight,
            fit: BoxFit.contain,
          ),
          // Progress text - centered
          Padding(
            padding: EdgeInsets.only(
              top: isVeryLargeScreen
                  ? 20
                  : isLargeScreen
                  ? 18
                  : 16,
            ),
            child: Text(
              '2/5',
              style: AppTextStyles.bebasNeue(
                fontSize: isVeryLargeScreen
                    ? 32
                    : isLargeScreen
                    ? 28
                    : 24,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCarWashInfo(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isVeryLargeScreen = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isVeryLargeScreen
            ? 32.0
            : isLargeScreen
            ? 24.0
            : 16.0,
        vertical: isVeryLargeScreen
            ? 24.0
            : isLargeScreen
            ? 20.0
            : 12.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isVeryLargeScreen
            ? 24.0
            : isLargeScreen
            ? 20.0
            : 16.0,
        vertical: isVeryLargeScreen
            ? 20.0
            : isLargeScreen
            ? 16.0
            : 12.0,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isVeryLargeScreen ? 16 : 12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: const Color(0xFF04CDFE),
            size: isVeryLargeScreen
                ? 20
                : isLargeScreen
                ? 18
                : 16,
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              'NEXT CAR WASH: 11/11/2025',
              style: AppTextStyles.bebasNeue(
                fontSize: isVeryLargeScreen
                    ? 20
                    : isLargeScreen
                    ? 18
                    : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnButton(BuildContext context, bool isIOS) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isVeryLargeScreen = screenWidth > 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isVeryLargeScreen
            ? 32.0
            : isLargeScreen
            ? 24.0
            : 16.0,
        vertical: isVeryLargeScreen
            ? 24.0
            : isLargeScreen
            ? 20.0
            : 12.0,
      ),
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add On feature coming soon!'),
                    backgroundColor: Color(0xFF04CDFE),
                  ),
                );
              },
              child: Container(
                height: isVeryLargeScreen
                    ? 64
                    : isLargeScreen
                    ? 56
                    : 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF04CDFE),
                  borderRadius: BorderRadius.circular(
                    isVeryLargeScreen
                        ? 20
                        : isLargeScreen
                        ? 16
                        : 12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF04CDFE).withValues(alpha: 0.4),
                      blurRadius: isVeryLargeScreen ? 25 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '+ ADD ON',
                    style: AppTextStyles.bebasNeue(
                      fontSize: isVeryLargeScreen
                          ? 20
                          : isLargeScreen
                          ? 18
                          : 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add On feature coming soon!'),
                    backgroundColor: Color(0xFF04CDFE),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04CDFE),
                padding: EdgeInsets.symmetric(
                  vertical: isVeryLargeScreen
                      ? 22
                      : isLargeScreen
                      ? 18
                      : 16,
                  horizontal: isVeryLargeScreen
                      ? 40
                      : isLargeScreen
                      ? 32
                      : 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isVeryLargeScreen
                        ? 20
                        : isLargeScreen
                        ? 16
                        : 12,
                  ),
                ),
                elevation: isVeryLargeScreen ? 12 : 8,
                shadowColor: const Color(0xFF04CDFE).withValues(alpha: 0.4),
              ),
              child: Text(
                '+ ADD ON',
                style: AppTextStyles.bebasNeue(
                  fontSize: isVeryLargeScreen
                      ? 20
                      : isLargeScreen
                      ? 18
                      : 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
    );
  }
}

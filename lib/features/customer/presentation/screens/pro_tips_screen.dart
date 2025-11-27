import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';

class ProTipsScreen extends StatelessWidget {
  const ProTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;
    final isTablet = screenWidth > 600;

    if (Platform.isIOS) {
      return _buildIOSScreen(context, isLargeScreen, isTablet);
    } else {
      return _buildAndroidScreen(context, isLargeScreen, isTablet);
    }
  }

  Widget _buildIOSScreen(
    BuildContext context,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: _buildContent(context, isLargeScreen, isTablet),
    );
  }

  Widget _buildAndroidScreen(
    BuildContext context,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(context, isLargeScreen, isTablet),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/ProTips/protipsbg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isLargeScreen, isTablet),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTitle(isLargeScreen, isTablet),
                    _buildTipsCards(isLargeScreen, isTablet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLargeScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Platform.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),

          // Title
          const Expanded(
            child: Text(
              'PRO TIPS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isLargeScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
      child: Text(
        'PRO TIPS & TRICKS',
        style: TextStyle(
          color: Colors.white,
          fontSize: isLargeScreen ? 32 : (isTablet ? 28 : 24),
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTipsCards(bool isLargeScreen, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
      child: Column(
        children: [
          _buildTipCard(
            'assets/ProTips/tip1.png',
            'Regular Maintenance',
            'Keep your car clean regularly to prevent dirt buildup and maintain its shine.',
            isLargeScreen,
            isTablet,
          ),
          SizedBox(height: isLargeScreen ? 30 : 20),
          _buildTipCard(
            'assets/ProTips/tip2.png',
            'Quality Products',
            'Use high-quality car care products for better results and protection.',
            isLargeScreen,
            isTablet,
          ),
          SizedBox(height: isLargeScreen ? 30 : 20),
          _buildTipCard(
            'assets/ProTips/tip3.png',
            'Professional Service',
            'Get professional car wash services for thorough cleaning and detailing.',
            isLargeScreen,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    String imagePath,
    String title,
    String description,
    bool isLargeScreen,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: isLargeScreen ? 180 : 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 24 : (isTablet ? 20 : 18),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isLargeScreen ? 18 : (isTablet ? 16 : 14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

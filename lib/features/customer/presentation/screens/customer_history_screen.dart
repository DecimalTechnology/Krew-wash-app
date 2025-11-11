import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomerHistoryScreen extends StatelessWidget {
  const CustomerHistoryScreen({super.key});

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
        child: Column(
          children: [
            // Header
            _buildHeader(context, isIOS, screenWidth),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Next Car Wash Banner
                    _buildNextCarWashBanner(screenWidth),

                    // History Section
                    _buildHistorySection(screenWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isIOS, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      child: Row(
        children: [
          // Back Button
          Container(
            width: screenWidth > 400 ? 50 : 40,
            height: screenWidth > 400 ? 50 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(screenWidth > 400 ? 25 : 20),
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: screenWidth > 400 ? 24 : 20,
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        screenWidth > 400 ? 25 : 20,
                      ),
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: screenWidth > 400 ? 24 : 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCarWashBanner(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 24.0 : 20.0,
        vertical: screenWidth > 400 ? 20.0 : 16.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 20.0 : 16.0,
        vertical: screenWidth > 400 ? 16.0 : 12.0,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(screenWidth > 400 ? 12 : 8),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth > 400 ? 8 : 6,
            height: screenWidth > 400 ? 8 : 6,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: screenWidth > 400 ? 12 : 8),
          Text(
            'NEXT CAR WASH: 11/11/2025',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 400 ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(double screenWidth) {
    final historyItems = [
      {'date': '10/10/2025 - 10:25AM', 'service': 'CAR WASH AND POLISHING'},
      {'date': '10/08/2025 - 10:25AM', 'service': 'CAR WASH'},
      {'date': '10/06/2025 - 10:25AM', 'service': 'INTERIOR CLEANING'},
      {
        'date': '10/04/2025 - 10:25AM',
        'service': 'CAR WASH AND POLISHING ARE COMPLETED.',
      },
      {'date': '10/08/2025 - 10:25AM', 'service': 'CAR WASH IS COMPLETED.'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 24.0 : 20.0,
        vertical: screenWidth > 400 ? 20.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // History Title
          Text(
            'HISTORY',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 400 ? 24 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: screenWidth > 400 ? 20 : 16),

          // History Items
          ...historyItems
              .map((item) => _buildHistoryItem(item, screenWidth))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, String> item, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth > 400 ? 16 : 12),
      padding: EdgeInsets.all(screenWidth > 400 ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(screenWidth > 400 ? 12 : 8),
        border: Border.all(color: const Color(0xFF04CDFE), width: 1),
      ),
      child: Row(
        children: [
          // Checkmark Icon
          Container(
            width: screenWidth > 400 ? 40 : 32,
            height: screenWidth > 400 ? 40 : 32,
            decoration: BoxDecoration(
              color: const Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: screenWidth > 400 ? 24 : 20,
            ),
          ),
          SizedBox(width: screenWidth > 400 ? 16 : 12),

          // Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['date']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth > 400 ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenWidth > 400 ? 8 : 6),
                Text(
                  item['service']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth > 400 ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

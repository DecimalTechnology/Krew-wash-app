import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../core/constants/route_constants.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

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
                    // Car Details Card
                    _buildCarDetailsCard(screenWidth),

                    // Add New Car Button
                    _buildAddNewCarButton(context, isIOS),

                    SizedBox(height: screenWidth > 400 ? 40 : 30),

                    // Next Button
                    SizedBox(height: screenWidth > 400 ? 40 : 30),
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

  Widget _buildCarDetailsCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 400 ? 24.0 : 20.0,
        vertical: screenWidth > 400 ? 20.0 : 16.0,
      ),
      padding: EdgeInsets.all(screenWidth > 400 ? 24.0 : 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF01031C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF04CDFE).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04CDFE).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Type
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: Colors.white,
                size: screenWidth > 400 ? 20 : 18,
              ),
              SizedBox(width: screenWidth > 400 ? 8 : 6),
              Text(
                'SEDAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth > 400 ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth > 400 ? 20 : 16),

          // Vehicle Information
          _buildInfoRow('VEHICLE NUMBER', 'JFM 624 J 12', screenWidth),
          SizedBox(height: screenWidth > 400 ? 16 : 12),
          _buildInfoRow('COMPANY', 'BMW', screenWidth),
          SizedBox(height: screenWidth > 400 ? 16 : 12),
          _buildInfoRow('MODEL', 'X7', screenWidth),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: screenWidth > 400 ? 16 : 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth > 400 ? 16 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewCarButton(BuildContext context, bool isIOS) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          // Empty space on the left
          const Expanded(flex: 1, child: SizedBox()),
          // Add New Car Button - Right side
          Expanded(
            flex: 1,
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.customerAddNewCar);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF04CDFE),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF04CDFE,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'ADD NEW CAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.customerAddNewCar);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04CDFE),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF04CDFE,
                      ).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'ADD NEW CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

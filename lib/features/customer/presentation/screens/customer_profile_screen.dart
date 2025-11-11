import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../../core/constants/route_constants.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;

    // Debug print to check screen size detection
    print(
      'Profile Screen - Screen width: $screenWidth, isLargeScreen: $isLargeScreen',
    );

    if (Platform.isIOS) {
      return _buildIOSScreen(context, isLargeScreen);
    } else {
      return _buildAndroidScreen(context, isLargeScreen);
    }
  }

  Widget _buildIOSScreen(BuildContext context, bool isLargeScreen) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Background Images
          _buildBackgroundImages(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildIOSHeader(context, isLargeScreen),

                  // Profile Title
                  _buildProfileTitle(isLargeScreen),

                  // Profile Avatar
                  _buildProfileAvatar(isLargeScreen),

                  // Profile Information Card
                  _buildProfileCard(isLargeScreen),

                  // Edit Profile Button
                  _buildEditProfileButton(context, isLargeScreen),

                  // Logout Button
                  _buildLogoutButton(context, isLargeScreen),

                  SizedBox(height: isLargeScreen ? 60 : 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidScreen(BuildContext context, bool isLargeScreen) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Images
          _buildBackgroundImages(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildAndroidHeader(context, isLargeScreen),

                  // Profile Title
                  _buildProfileTitle(isLargeScreen),

                  // Profile Avatar
                  _buildProfileAvatar(isLargeScreen),

                  // Profile Information Card
                  _buildProfileCard(isLargeScreen),

                  // Edit Profile Button
                  _buildEditProfileButton(context, isLargeScreen),

                  // View Car List Button
                  _buildViewCarListButton(context, isLargeScreen),

                  // View My Package Button
                  _buildViewMyPackageButton(context, isLargeScreen),

                  // Logout Button
                  _buildLogoutButton(context, isLargeScreen),

                  SizedBox(height: isLargeScreen ? 60 : 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: ElevatedButton(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          // Navigate to auth screen and clear history
          // ignore: use_build_context_synchronously
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.auth,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16.0 : 12.0,
            horizontal: isLargeScreen ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          elevation: 6,
          shadowColor: const Color(0xFFE53935).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.white,
              size: isLargeScreen ? 20 : 18,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            const Text(
              'LOG OUT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImages() {
    return Stack(
      children: [
        // Top Background - Car Interior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/CustomerProfile/image1.png'),
                fit: BoxFit.fitHeight,
                opacity: 0.3,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
        // Bottom Background - Car Exterior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/CustomerProfile/image2.png'),
                fit: BoxFit.fitWidth,
                opacity: 0.3,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIOSHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Container(
              width: isLargeScreen ? 40 : 35,
              height: isLargeScreen ? 40 : 35,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 18),
              ),
              child: Icon(
                CupertinoIcons.back,
                color: CupertinoColors.white,
                size: isLargeScreen ? 20 : 18,
              ),
            ),
          ),
          // Profile Icon
          Container(
            width: isLargeScreen ? 50 : 40,
            height: isLargeScreen ? 50 : 40,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.person,
              color: CupertinoColors.white,
              size: isLargeScreen ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: isLargeScreen ? 40 : 35,
              height: isLargeScreen ? 40 : 35,
              decoration: BoxDecoration(
                color: const Color(0xFF04CDFE),
                borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 18),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isLargeScreen ? 20 : 18,
              ),
            ),
          ),
          // Profile Icon
          Container(
            width: isLargeScreen ? 50 : 40,
            height: isLargeScreen ? 50 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isLargeScreen ? 25 : 20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: isLargeScreen ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTitle(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 20.0 : 10.0),
      child: Text(
        'PROFILE',
        style: TextStyle(
          color: Colors.white,
          fontSize: isLargeScreen ? 28 : 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 100 : 80,
      height: isLargeScreen ? 100 : 80,
      margin: EdgeInsets.symmetric(vertical: isLargeScreen ? 20.0 : 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isLargeScreen ? 50 : 40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: isLargeScreen ? 50 : 40,
      ),
    );
  }

  Widget _buildProfileCard(bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 8.0,
      ),
      padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF01031C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF04CDFE).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('NAME', 'ROY ALEX', isLargeScreen),
          SizedBox(height: isLargeScreen ? 12 : 8),
          _buildInfoRow('ID NUMBER', '74551', isLargeScreen),
          SizedBox(height: isLargeScreen ? 12 : 8),
          _buildInfoRow('PHONE', '+721 5889 369', isLargeScreen),
          SizedBox(height: isLargeScreen ? 12 : 8),
          _buildInfoRow('LOCATION', 'AL-JASEERA', isLargeScreen),
          SizedBox(height: isLargeScreen ? 12 : 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLargeScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.customerEditProfile);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D4AA),
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16.0 : 12.0,
            horizontal: isLargeScreen ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00D4AA).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
              size: isLargeScreen ? 20 : 18,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              'EDIT PROFILE',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewCarListButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.customerCarList);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04CDFE),
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16.0 : 12.0,
            horizontal: isLargeScreen ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF04CDFE).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.white,
              size: isLargeScreen ? 20 : 18,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              'VIEW CAR LIST',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMyPackageButton(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.customerMyPackage);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF04CDFE),
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16.0 : 12.0,
            horizontal: isLargeScreen ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF04CDFE).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership,
              color: Colors.white,
              size: isLargeScreen ? 20 : 18,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              'VIEW MY PACKAGE',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

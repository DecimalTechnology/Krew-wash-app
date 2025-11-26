import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Title
                Text(
                  'PROFILE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
                  ),
                ),
                const SizedBox(height: 32),
                // Profile Picture
                _buildProfilePicture(isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 24),
                // User Name and ID
                _buildUserInfo(isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 32),
                // Contact Information
                _buildContactInfo(context, isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 32),
                // Logout Button
                _buildLogoutButton(context, isIOS, isSmallScreen, isTablet),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture(bool isIOS, bool isSmallScreen, bool isTablet) {
    final size = isSmallScreen
        ? 100.0
        : isTablet
        ? 140.0
        : 120.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isIOS, bool isSmallScreen, bool isTablet) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final userName = user?.name?.toUpperCase() ?? 'CLEANER';
        final userId = user?.uid ?? 'KFM-EPM-0003';

        return Column(
          children: [
            Text(
              userName,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? 20
                    : isTablet
                    ? 28
                    : 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userId,
              style: TextStyle(
                color: const Color(0xFF04CDFE),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final phone = user?.phone?.toString() ?? '+721 5888 368';
        final email = user?.email?.toUpperCase() ?? 'ROYALLX@GMAIL.COM';

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              _buildContactRow('PHONE', phone, isIOS, isSmallScreen),
              const SizedBox(height: 16),
              _buildContactRow('EMAIL', email, isIOS, isSmallScreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactRow(
    String label,
    String value,
    bool isIOS,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        SizedBox(
          width: isSmallScreen ? 60 : 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
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

  Widget _buildLogoutButton(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 48 : 52,
      child: isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              color: const Color(0xFF04CDFE),
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                _handleLogout(context, isIOS);
              },
              child: Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
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
                _handleLogout(context, isIOS);
              },
              child: Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
    );
  }

  void _handleLogout(BuildContext context, bool isIOS) {
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: const Text('Logout'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }
}

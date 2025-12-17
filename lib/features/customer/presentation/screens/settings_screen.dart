import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isLargeScreen = screenWidth > 400;

    return isIOS
        ? _buildIOSScreen(context, isLargeScreen)
        : _buildAndroidScreen(context, isLargeScreen);
  }

  Widget _buildIOSScreen(BuildContext context, bool isLargeScreen) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _buildIOSHeader(context, isLargeScreen),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 24.0 : 16.0,
                    vertical: isLargeScreen ? 24.0 : 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('GENERAL', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'NOTIFICATIONS',
                        CupertinoIcons.bell,
                        () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerNotifications);
                        },
                        isLargeScreen,
                        isIOS: true,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'CHANGE PASSWORD',
                        CupertinoIcons.lock,
                        () {
                          // TODO: Navigate to change password screen
                        },
                        isLargeScreen,
                        isIOS: true,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'PRIVACY POLICY',
                        CupertinoIcons.shield,
                        () {
                          // TODO: Navigate to privacy policy screen
                        },
                        isLargeScreen,
                        isIOS: true,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'TERMS OF SERVICE',
                        CupertinoIcons.doc_text,
                        () {
                          // TODO: Navigate to terms of service screen
                        },
                        isLargeScreen,
                        isIOS: true,
                      ),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildSectionTitle('ACCOUNT', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'LOGOUT',
                        CupertinoIcons.arrow_right_square,
                        () async {
                          final rootNav = Navigator.of(
                            context,
                            rootNavigator: true,
                          );
                          await context.read<AuthProvider>().signOut();
                          rootNav.pushNamedAndRemoveUntil(
                            Routes.authWrapper,
                            (route) => false,
                          );
                        },
                        isLargeScreen,
                        isIOS: true,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidScreen(BuildContext context, bool isLargeScreen) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAndroidHeader(context, isLargeScreen),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 24.0 : 16.0,
                    vertical: isLargeScreen ? 24.0 : 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('GENERAL', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'NOTIFICATIONS',
                        Icons.notifications,
                        () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerNotifications);
                        },
                        isLargeScreen,
                        isIOS: false,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'CHANGE PASSWORD',
                        Icons.lock,
                        () {
                          // TODO: Navigate to change password screen
                        },
                        isLargeScreen,
                        isIOS: false,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'PRIVACY POLICY',
                        Icons.shield,
                        () {
                          // TODO: Navigate to privacy policy screen
                        },
                        isLargeScreen,
                        isIOS: false,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'TERMS OF SERVICE',
                        Icons.description,
                        () {
                          // TODO: Navigate to terms of service screen
                        },
                        isLargeScreen,
                        isIOS: false,
                      ),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildSectionTitle('ACCOUNT', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'LOGOUT',
                        Icons.logout,
                        () async {
                          final rootNav = Navigator.of(
                            context,
                            rootNavigator: true,
                          );
                          await context.read<AuthProvider>().signOut();
                          rootNav.pushNamedAndRemoveUntil(
                            Routes.authWrapper,
                            (route) => false,
                          );
                        },
                        isLargeScreen,
                        isIOS: false,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 16.0 : 12.0,
      ),
      child: Row(
        children: [
          const StandardBackButton(),
          SizedBox(width: isLargeScreen ? 16 : 12),
          Text(
            'SETTINGS',
            style: AppTheme.bebasNeue(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 1.5,
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
        children: [
          const StandardBackButton(),
          SizedBox(width: isLargeScreen ? 16 : 12),
          Text(
            'SETTINGS',
            style: AppTheme.bebasNeue(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isLargeScreen) {
    return Text(
      title,
      style: AppTheme.bebasNeue(
        color: Colors.white,
        fontSize: isLargeScreen ? 18 : 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isLargeScreen, {
    bool isIOS = false,
    bool isLogout = false,
  }) {
    final iconColor = isLogout
        ? const Color(0xFFE53935)
        : const Color(0xFF04CDFE);
    final textColor = isLogout ? const Color(0xFFE53935) : Colors.white;

    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isLargeScreen ? 16.0 : 14.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 10),
            border: Border.all(color: const Color(0xFF04CDFE), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: isLargeScreen ? 24 : 20),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                title,
                style: AppTheme.bebasNeue(
                  color: textColor,
                  fontSize: isLargeScreen ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isLargeScreen ? 16.0 : 14.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 10),
            border: Border.all(color: const Color(0xFF04CDFE), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: isLargeScreen ? 24 : 20),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                title,
                style: AppTheme.bebasNeue(
                  color: textColor,
                  fontSize: isLargeScreen ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

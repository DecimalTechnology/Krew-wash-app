import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';

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
                        'PRIVACY POLICY',
                        CupertinoIcons.shield,
                        () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerPrivacyPolicy);
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
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerTermsOfService);
                        },
                        isLargeScreen,
                        isIOS: true,
                      ),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildSectionTitle('ACCOUNT', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'DELETE ACCOUNT',
                        CupertinoIcons.trash,
                        () async {
                          await _confirmAndDeleteAccount(context);
                        },
                        isLargeScreen,
                        isIOS: true,
                        isLogout: true,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'LOGOUT',
                        CupertinoIcons.arrow_right_square,
                        () => _showLogoutDialog(context, true),
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
                        'PRIVACY POLICY',
                        Icons.shield,
                        () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerPrivacyPolicy);
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
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.customerTermsOfService);
                        },
                        isLargeScreen,
                        isIOS: false,
                      ),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildSectionTitle('ACCOUNT', isLargeScreen),
                      SizedBox(height: isLargeScreen ? 16 : 12),
                      _buildSettingsItem(
                        context,
                        'DELETE ACCOUNT',
                        Icons.delete_forever,
                        () async {
                          await _confirmAndDeleteAccount(context);
                        },
                        isLargeScreen,
                        isIOS: false,
                        isLogout: true,
                      ),
                      SizedBox(height: isLargeScreen ? 12 : 8),
                      _buildSettingsItem(
                        context,
                        'LOGOUT',
                        Icons.logout,
                        () => _showLogoutDialog(context, false),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: StandardBackButton(),
          ),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: StandardBackButton(),
          ),
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

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    Future<void> runDelete() async {
      // show blocking loader
      if (isIOS) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const CupertinoAlertDialog(
            title: Text('Deleting...'),
            content: Padding(
              padding: EdgeInsets.only(top: 12),
              child: CupertinoActivityIndicator(),
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            title: Text('Deleting...'),
            content: SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }

      final repo = const ProfileRepository();
      final res = await repo.deleteAccount();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close loader
      }

      final ok = res['success'] == true;
      if (!context.mounted) return;

      if (ok) {
        await context.read<AuthProvider>().signOut();
        if (context.mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(Routes.authWrapper, (route) => false);
        }
      } else {
        final msg = res['message']?.toString() ?? 'Failed to delete account';
        if (isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Delete Failed'),
              content: Text(msg),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Delete Account?'),
          content: const Text(
            'This will permanently delete your account. This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await runDelete();
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'Delete Account?',
            style: AppTheme.bebasNeue(color: Colors.white),
          ),
          content: Text(
            'This will permanently delete your account. This action cannot be undone.',
            style: AppTheme.bebasNeue(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bebasNeue(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await runDelete();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                'Delete',
                style: AppTheme.bebasNeue(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, bool isIOS) {
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                final rootNav = Navigator.of(context, rootNavigator: true);
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  rootNav.pushNamedAndRemoveUntil(
                    Routes.authWrapper,
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text('Logout', style: AppTheme.bebasNeue(color: Colors.white)),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.bebasNeue(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: Text(
                'Cancel',
                style: AppTheme.bebasNeue(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                final rootNav = Navigator.of(context, rootNavigator: true);
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  rootNav.pushNamedAndRemoveUntil(
                    Routes.authWrapper,
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                'Logout',
                style: AppTheme.bebasNeue(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }
  }
}

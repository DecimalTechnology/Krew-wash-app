import 'package:flutter/material.dart';
import '../../../../../core/constants/route_constants.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class TopSectionWidget extends StatelessWidget {
  const TopSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth > 400 ? 16.0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo - Teal K/X style
          Container(
            width: screenWidth > 400 ? 50 : 50,
            height: screenWidth > 400 ? 50 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth > 400 ? 16 : 12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    71,
                    214,
                    250,
                  ).withValues(alpha: 0.3),
                  blurRadius: screenWidth > 400 ? 15 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/Logo.png',
              width: screenWidth > 400 ? 28 : 28,
              height: screenWidth > 400 ? 28 : 28,
              fit: BoxFit.contain,
            ),
          ),
          // Profile Icon
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.customerProfile);
            },
            child: Container(
              width: screenWidth > 400 ? 50 : 50,
              height: screenWidth > 400 ? 50 : 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  screenWidth > 400 ? 35 : 25,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: screenWidth > 400 ? 24 : 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

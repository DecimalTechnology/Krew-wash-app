import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOS(context) : _buildAndroid(context);
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: _buildBody(context, isIOS: true),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(context, isIOS: false)),
    );
  }

  Widget _buildBody(BuildContext context, {required bool isIOS}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 400;
    final horizontalPadding = isLargeScreen ? 24.0 : 16.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
          child: Row(
            children: [
              const StandardBackButton(),
              const SizedBox(width: 12),
              Text(
                'PRIVACY POLICY',
                style: AppTheme.bebasNeue(
                  fontSize: isLargeScreen ? 26 : 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoCard(
                  title: 'LAST UPDATED',
                  body: '2025-12-18',
                ),
                const SizedBox(height: 12),
                _section(
                  'INTRODUCTION',
                  'This Privacy Policy explains how Krew Car Wash ("we", "our", "us") collects, uses, and shares information when you use our mobile application.',
                ),
                _section(
                  'INFORMATION WE COLLECT',
                  'We may collect information you provide (such as name, phone number, email, building/location details, vehicle details) and information generated through your use of the app (such as bookings, package selections, payment status, and support chats).',
                ),
                _section(
                  'HOW WE USE INFORMATION',
                  'We use information to provide and improve services, process bookings, support customer and staff workflows, prevent fraud, and communicate important updates.',
                ),
                _section(
                  'SHARING',
                  'We may share information with service providers (e.g., payment and infrastructure providers) only as needed to operate the app. We do not sell your personal information.',
                ),
                _section(
                  'SECURITY',
                  'We use reasonable measures to protect your information. No method of transmission or storage is 100% secure.',
                ),
                _section(
                  'RETENTION',
                  'We retain information as long as needed for business purposes, legal requirements, and to provide the service.',
                ),
                _section(
                  'YOUR CHOICES',
                  'You may update your profile information in the app. For privacy requests (access, deletion, or correction), contact support.',
                ),
                _section(
                  'CONTACT',
                  'If you have questions about this policy, please contact support through the app or your organization’s administrator.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bebasNeue(
              fontSize: 14,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.bebasNeue(
                fontSize: 16,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



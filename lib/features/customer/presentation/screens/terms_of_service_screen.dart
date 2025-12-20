import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOS(context) : _buildAndroid(context);
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 400;
    final horizontalPadding = isLargeScreen ? 24.0 : 16.0;

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
          child: Row(
            children: [
              const StandardBackButton(),
              const SizedBox(width: 12),
              Text(
                'TERMS OF SERVICE',
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
                _infoCard(title: 'LAST UPDATED', body: '2025-12-18'),
                const SizedBox(height: 12),
                _section(
                  'ACCEPTANCE',
                  'By using this app, you agree to these Terms of Service.',
                ),
                _section(
                  'SERVICES',
                  'The app allows users to browse packages, book services, manage vehicles, and communicate with support/staff as needed.',
                ),
                _section(
                  'PAYMENTS',
                  'Payments may be processed by third-party payment providers. Payment status is subject to verification.',
                ),
                _section(
                  'USER RESPONSIBILITIES',
                  'You are responsible for providing accurate information (vehicle details, location/parking info) and for complying with building/site rules.',
                ),
                _section(
                  'LIMITATION OF LIABILITY',
                  'To the maximum extent permitted by law, we are not liable for indirect or consequential damages.',
                ),
                _section(
                  'CHANGES',
                  'We may update these terms from time to time. Continued use means you accept the updated terms.',
                ),
                _section(
                  'CONTACT',
                  'For questions, please contact support through the app or your organization’s administrator.',
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



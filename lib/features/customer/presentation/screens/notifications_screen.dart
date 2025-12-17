import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/standard_back_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
            Expanded(child: _buildNotificationsList(isLargeScreen)),
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
            Expanded(child: _buildNotificationsList(isLargeScreen)),
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
          Expanded(
            child: Center(
              child: Text(
                'NOTIFICATIONS',
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 28 : 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 40 : 35),
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
          Expanded(
            child: Center(
              child: Text(
                'NOTIFICATIONS',
                style: AppTheme.bebasNeue(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 28 : 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 40 : 35),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isLargeScreen) {
    // Sample notification data - replace with actual data from API
    final notifications = [
      {
        'name': 'ALEX JOE',
        'message': 'CAR WASH COMPLETE',
        'avatar': null, // You can add avatar URL here
      },
      {'name': 'ALEX JOE', 'message': 'CAR WASH COMPLETE', 'avatar': null},
      {'name': 'ALEX JOE', 'message': 'CAR WASH COMPLETE', 'avatar': null},
      {'name': 'ALEX JOE', 'message': 'CAR WASH COMPLETE', 'avatar': null},
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : 16.0,
        vertical: isLargeScreen ? 20.0 : 16.0,
      ),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(
          notification['name']!,
          notification['message']!,
          notification['avatar'],
          isLargeScreen,
        );
      },
    );
  }

  Widget _buildNotificationItem(
    String name,
    String message,
    String? avatarUrl,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16.0 : 12.0),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: isLargeScreen ? 50 : 45,
            height: isLargeScreen ? 50 : 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: isLargeScreen ? 50 : 45,
                      height: isLargeScreen ? 50 : 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isLargeScreen ? 30 : 25,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: isLargeScreen ? 30 : 25,
                  ),
          ),
          SizedBox(width: isLargeScreen ? 16 : 12),
          // Name and Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 4 : 2),
                Text(
                  message,
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
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

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/customer/presentation/providers/location_provider.dart';
import 'features/customer/presentation/providers/package_provider.dart';
import 'features/staff/presentation/providers/staff_provider.dart';
import 'features/staff/presentation/providers/cleaner_booking_provider.dart';
import 'features/shared/presentation/screens/splash_screen.dart';
import 'features/customer/presentation/screens/main_navigation_screen.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/staff/presentation/screens/staff_main_navigation_screen.dart';
import 'core/constants/route_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => CleanerBookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
      ],
      child: CupertinoTheme(
        data: AppTheme.cupertinoTheme,
        child: MaterialApp(
          title: 'Krew Car Wash',
          theme: AppTheme.materialTheme,
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
          // Fix yellow underlines on iOS by setting default text decoration
          builder: (context, child) {
            return DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, StaffProvider>(
      builder: (context, authProvider, staffProvider, child) {
        // Show loading screen while checking authentication
        if (authProvider.isInitializing || staffProvider.isInitializing) {
          return const SplashScreen();
        }

        // Check if staff is logged in first
        if (staffProvider.isAuthenticated) {
          return const StaffMainNavigationScreen();
        }

        // Then check if customer is logged in
        if (authProvider.isAuthenticated) {
          // Show appropriate portal based on user role
          final role = authProvider.user?.role;
          if (role == 'user') {
            return const MainNavigationScreen();
          } else if (role == 'staff') {
            return const StaffMainNavigationScreen();
          } else {
            return const RoleSelectionScreen();
          }
        }

        // Show authentication screen if not logged in
        return const AuthScreen();
      },
    );
  }
}

// Placeholder screens - will be implemented later

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Role Selection Screen - To be implemented')),
    );
  }
}

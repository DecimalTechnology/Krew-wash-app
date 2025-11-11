import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/customer/presentation/providers/location_provider.dart';
import 'features/customer/presentation/providers/package_provider.dart';
import 'features/shared/presentation/screens/splash_screen.dart';
import 'features/customer/presentation/screens/main_navigation_screen.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'core/constants/route_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
      ],
      child: MaterialApp(
        title: 'Krew Car Wash',
        theme: AppTheme.materialTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking authentication
        if (authProvider.isInitializing) {
          return const SplashScreen();
        }

        // This will determine which portal to show based on user role
        if (authProvider.isAuthenticated) {
          // Show appropriate portal based on user role
          final role = authProvider.user?.role;
          if (role == 'user') {
            return const MainNavigationScreen();
          } else if (role == 'staff') {
            return const StaffHomeScreen();
          } else {
            return const RoleSelectionScreen();
          }
        } else {
          // Show authentication screen
          return const AuthScreen();
        }
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

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Staff Portal - To be implemented')),
    );
  }
}

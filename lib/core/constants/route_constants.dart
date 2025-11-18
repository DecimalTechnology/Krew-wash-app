import 'package:carwash_app/features/customer/presentation/screens/main_navigation_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/customer_profile_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/edit_profile_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/profile_details_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/customer_history_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/full_screen_map_page.dart';
import 'package:carwash_app/features/customer/presentation/screens/package_selection_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/pro_tips_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/choose_slot_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/car_list_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/add_new_car_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/my_package_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/package_details_screen.dart';
import 'package:carwash_app/features/customer/presentation/screens/booking_summary_screen.dart';
import 'package:carwash_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:carwash_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:carwash_app/app.dart';

class Routes {
  // App routes
  static const String splash = '/';
  static const String authWrapper = '/auth-wrapper';

  // Auth routes
  static const String login = '/login';
  static const String auth = '/auth';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';

  // Customer routes
  static const String customerHome = '/customer/home';
  static const String customerMapFullScreen = '/customer/map-fullscreen';
  static const String customerBooking = '/customer/booking';
  static const String customerServiceSelection = '/customer/service-selection';
  static const String customerPackageSelection = '/customer/package-selection';
  static const String customerProTips = '/customer/pro-tips';
  static const String customerChooseSlot = '/customer/choose-slot';
  static const String customerPayment = '/customer/payment';
  static const String customerHistory = '/customer/history';
  static const String customerProfile = '/customer/profile';
  static const String customerEditProfile = '/customer/edit-profile';
  static const String customerProfileDetails = '/customer/profile-details';
  static const String customerCarList = '/customer/car-list';
  static const String customerAddNewCar = '/customer/add-new-car';
  static const String customerMyPackage = '/customer/my-package';
  static const String customerPackageDetails = '/customer/package-details';
  static const String customerBookingSummary = '/customer/booking-summary';

  // Staff routes
  static const String staffHome = '/staff/home';
  static const String staffJobDetails = '/staff/job-details';
  static const String staffJobCompletion = '/staff/job-completion';
  static const String staffPerformance = '/staff/performance';

  // Shared routes
  static const String locationSelection = '/location-selection';
  static const String buildingSelection = '/building-selection';
}

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    Routes.authWrapper: (context) => const AuthWrapper(),
    Routes.auth: (context) => const AuthScreen(),
    Routes.otpVerification: (context) => const OtpVerificationScreen(
      email: "example@example.com",
      phoneNumber: '+1 262 585 5556',
      otpMethod: 'phone',
    ),
    Routes.customerHome: (context) => const MainNavigationScreen(),
    Routes.customerMapFullScreen: (context) => const FullScreenMapPage(),
    Routes.customerBooking: (context) => const CustomerBookingScreen(),
    Routes.customerPackageSelection: (context) =>
        const PackageSelectionScreen(),
    Routes.customerProTips: (context) => const ProTipsScreen(),
    Routes.customerChooseSlot: (context) => const ChooseSlotScreen(),
    Routes.customerHistory: (context) => const CustomerHistoryScreen(),
    Routes.customerProfile: (context) => const CustomerProfileScreen(),
    Routes.customerEditProfile: (context) => const EditProfileScreen(),
    Routes.customerProfileDetails: (context) => const ProfileDetailsScreen(),
    Routes.customerCarList: (context) => const CarListScreen(),
    Routes.customerAddNewCar: (context) => const AddNewCarScreen(),
    Routes.customerMyPackage: (context) => const MyPackageScreen(),
    Routes.customerPackageDetails: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments
              as PackageDetailsArguments?;
      return PackageDetailsScreen(arguments: args);
    },
    Routes.customerBookingSummary: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments
              as BookingSummaryArguments?;
      return BookingSummaryScreen(arguments: args);
    },
    // Other routes will be added when screens are implemented
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Dynamic routes will be handled here when screens are implemented
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Page Not Found')));
  }
}

// Placeholder screens for customer routes
class CustomerBookingScreen extends StatelessWidget {
  const CustomerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Customer Booking Screen - To be implemented')),
    );
  }
}

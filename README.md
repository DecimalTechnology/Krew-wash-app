# Krew Car Wash App

A Flutter-based car wash application with Firebase authentication, featuring a luxury UI design and platform-aware components for both iOS and Android.

## 🚀 Features

### Authentication System
- **Google Sign-In** - Firebase Google Authentication
- **Phone Authentication** - SMS OTP verification via Firebase
- **Email/Phone Sign-Up** - User registration with validation
- **Email/Phone Sign-In** - User login with OTP verification
- **Platform-Aware UI** - Native iOS (Cupertino) and Android (Material) components

### User Interface
- **Luxury Design** - Premium car-themed UI with teal accents
- **Responsive Layout** - Adaptive design for different screen sizes
- **Dark Theme** - Black background with car imagery overlay
- **Smooth Animations** - Platform-specific transitions and effects

### Core Functionality
- **User Management** - Registration, authentication, and profile management
- **Firestore Integration** - User data persistence
- **State Management** - Provider pattern for app state
- **Navigation** - Role-based routing (Customer/Staff)

## 📱 Screenshots

### Authentication Screens
- **Splash Screen** - App loading with car background
- **Auth Screen** - Sign-in/Sign-up with luxury design
- **OTP Verification** - 6-digit code input with platform-specific styling

### Home Screens
- **Customer Home** - Main dashboard for customers
- **Staff Home** - Staff portal (placeholder)
- **Role Selection** - User role selection screen

## 🛠 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Cupertino** - iOS-specific widgets
- **Material Design** - Android-specific widgets

### Backend Services
- **Firebase Auth** - Authentication service
- **Firebase Firestore** - NoSQL database
- **Google Sign-In** - Social authentication
- **Firebase Phone Auth** - SMS verification

### Development Tools
- **Flutter SDK** - Mobile development framework
- **Android Studio** - IDE for Android development
- **Xcode** - IDE for iOS development
- **Firebase Console** - Backend service management

## 📋 Prerequisites

Before running the application, ensure you have:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (2.17.0 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** with authentication enabled
- **Google Services** configuration files
- **iOS Development** setup (for iOS builds)

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd carwash_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Android Configuration
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Enable Phone Authentication in Firebase Console
4. Add SHA-1 fingerprint for Android

#### iOS Configuration
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` directory
3. Enable Phone Authentication in Firebase Console

### 4. Configure Firebase
1. Enable Authentication methods:
   - Google Sign-In
   - Phone Authentication
2. Set up Firestore database
3. Configure security rules

### 5. Run the Application
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter run -d <device-id>
```

## 📁 Project Structure

```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # App entry point
├── core/
│   ├── config/
│   │   └── firebase_config.dart
│   ├── constants/
│   │   └── route_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_result.dart
│   │   │   └── services/
│   │   │       └── auth_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── auth_screen.dart
│   │       │   └── otp_verification_screen.dart
│   │       └── widgets/
│   │           └── platform_auth_widget.dart
│   ├── customer/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   └── shared/
│       └── presentation/
│           └── screens/
│               └── splash_screen.dart
└── assets/
    ├── loginScreen/
    │   └── car.png
    └── Logo.png
```

## 🔐 Authentication Flow

### Sign Up Process
1. **Field Validation** - Check required fields (name, email, phone)
2. **Format Validation** - Validate email and phone number formats
3. **Existence Check** - Verify email/phone don't already exist
4. **OTP Method Selection** - Choose phone or email verification
5. **OTP Sending** - Send verification code via Firebase/API
6. **OTP Verification** - Verify 6-digit code
7. **User Registration** - Create user account in Firestore
8. **Navigation** - Redirect to appropriate home screen

### Sign In Process
1. **Field Validation** - Check required fields (email, phone)
2. **User Existence** - Verify user exists in system
3. **OTP Sending** - Send verification code via Firebase
4. **OTP Verification** - Verify 6-digit code
5. **Authentication** - Sign in user
6. **Navigation** - Redirect to home screen

## 🎨 UI Components

### Platform-Aware Widgets
- **PlatformAuthWidget** - Main authentication form
- **OtpVerificationScreen** - OTP input screen
- **AuthScreen** - Authentication container

### Design Elements
- **Color Scheme** - Black background with teal (#00D4AA) accents
- **Typography** - Platform-specific fonts (SF Pro for iOS)
- **Icons** - Platform-appropriate icons
- **Animations** - Smooth transitions and loading states

## 🔧 Configuration

### Environment Setup
1. **Firebase Project** - Create project in Firebase Console
2. **Authentication** - Enable Google and Phone auth
3. **Firestore** - Set up database with security rules
4. **APIs** - Configure required APIs

### Build Configuration
- **Android** - `minSdkVersion: 23` (required for Firebase Auth)
- **iOS** - iOS 11.0+ deployment target
- **Permissions** - Phone and location permissions

## 🚀 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

## 🐛 Troubleshooting

### Common Issues

#### Firebase Authentication
- **API Key Error** - Ensure Firebase project is properly configured
- **Phone Auth Error** - Check SHA-1 fingerprint and billing setup
- **Google Sign-In Error** - Verify OAuth client configuration

#### Build Issues
- **Gradle Errors** - Clean and rebuild project
- **iOS Build Errors** - Check Xcode configuration and certificates
- **Dependency Conflicts** - Run `flutter pub deps` to check conflicts

#### Runtime Issues
- **OTP Not Received** - Check phone number format and Firebase billing
- **Navigation Errors** - Verify route constants and navigation setup
- **State Management** - Check Provider setup and state updates

## 📚 API Documentation

### AuthRepository Methods
- `registerUser()` - Register new user in Firestore
- `updateUser()` - Update existing user data
- `getUser()` - Retrieve user by UID
- `userExists()` - Check if user exists

### AuthService Methods
- `signInWithGoogle()` - Google authentication
- `sendPhoneVerificationCode()` - Send SMS OTP
- `verifyPhoneNumber()` - Verify phone OTP
- `signOut()` - Sign out user

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development Team** - Flutter development and UI/UX design
- **Backend Team** - Firebase configuration and API development
- **Design Team** - UI/UX design and branding

## 📞 Support

For support and questions:
- **Email** - support@krewcarwash.com
- **Documentation** - [Project Wiki](wiki-url)
- **Issues** - [GitHub Issues](issues-url)

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Firebase authentication
- Platform-aware UI
- Basic user management
- OTP verification system

### Planned Features
- **Payment Integration** - Stripe/PayPal integration
- **Booking System** - Car wash appointment booking
- **Location Services** - GPS-based service location
- **Push Notifications** - Real-time updates
- **Admin Panel** - Staff management interface
- **Analytics** - User behavior tracking
- **Multi-language** - Internationalization support

---

**Built with ❤️ using Flutter and Firebase**
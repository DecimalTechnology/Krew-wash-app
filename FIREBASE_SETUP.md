# Firebase Setup Instructions

## ✅ Android Configuration (Already Done)

The Android configuration has been updated to support Firebase:
- **Minimum SDK Version**: Updated to 23 (required for Firebase Auth)
- **Google Services Plugin**: Added to build configuration
- **Build Scripts**: Configured for Firebase integration

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "Krew Car Wash")
4. Enable Google Analytics (optional)
5. Create the project

## 2. Add Android App to Firebase

1. In your Firebase project, click "Add app" and select Android
2. Enter your package name: `com.example.carwash_app`
3. Enter app nickname: "Krew Car Wash Android"
4. Download the `google-services.json` file
5. Place the `google-services.json` file in `android/app/` directory

## 3. Enable Google Services Plugin

After placing the `google-services.json` file, uncomment the Google Services plugin in `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Uncomment this line
}
```

## 4. Enable Authentication

1. In your Firebase project, go to **Authentication** > **Sign-in method**
2. Enable the following sign-in providers:
   - **Email/Password**: Enable this provider
   - **Google**: Enable this provider and configure OAuth consent screen
   - **Phone**: Enable this provider

### For Google Sign-In:
1. In the Google provider settings, add your app's SHA-1 fingerprint
2. Get your SHA-1 fingerprint by running:
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Copy the SHA-1 fingerprint and add it to Firebase

## 5. Configure iOS (Optional)

1. In Firebase Console, add an iOS app
2. Enter your bundle ID: `com.example.carwashApp`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/` directory
5. Add it to your Xcode project

## 6. Update Firebase Configuration

Update the Firebase configuration in `lib/core/config/firebase_config.dart` with your actual Firebase project settings:

```dart
static FirebaseOptions _getFirebaseOptions() {
  return const FirebaseOptions(
    apiKey: "your-actual-api-key",
    appId: "your-actual-app-id",
    messagingSenderId: "your-actual-sender-id",
    projectId: "your-actual-project-id",
    // Add other required options for your platforms
  );
}
```

## 7. Install Dependencies

Run the following command to install the Firebase dependencies:

```bash
flutter pub get
```

## 8. Test Authentication

1. Run your app: `flutter run`
2. Test each authentication method:
   - Email/Password sign up and sign in
   - Google sign in
   - Phone number authentication

## 9. Security Rules (Optional)

For production, consider setting up Firestore security rules if you plan to use Firestore for user data storage.

## Troubleshooting

### Build Issues
- Make sure `google-services.json` is in `android/app/` directory
- Verify the Google Services plugin is uncommented in `android/app/build.gradle.kts`
- Clean and rebuild: `flutter clean && flutter pub get`

### Google Sign-In Issues
- Make sure SHA-1 fingerprint is added to Firebase project
- Verify `google-services.json` is in the correct location
- Check that Google Services plugin is properly configured

### Phone Authentication Issues
- Ensure phone authentication is enabled in Firebase Console
- Test with a real phone number (SMS codes are required)
- Check that your app is properly configured for phone authentication

### General Issues
- Make sure Firebase project is properly initialized
- Verify all dependencies are installed
- Check that Firebase configuration is correct

## Current Status

✅ **Android Configuration**: Complete
✅ **Firebase Dependencies**: Installed
✅ **Authentication UI**: Implemented
⏳ **Firebase Project**: Needs to be created
⏳ **google-services.json**: Needs to be added
⏳ **Firebase Configuration**: Needs actual project values

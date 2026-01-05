# Play Store Release Setup Guide

This guide will help you prepare your KREW CAR WASH app for release on the Google Play Store.

## Prerequisites

- Java JDK installed (for keytool command)
- Flutter SDK installed
- Google Play Console account

## Step 1: Generate Signing Keystore

### Option A: Using the Automated Script (Recommended)

1. Navigate to the android directory:
   ```bash
   cd android
   ```

2. Run the keystore generation script:
   ```bash
   ./generate_keystore.sh
   ```

3. Follow the prompts:
   - Enter a keystore file name (default: `upload-keystore.jks`)
   - Enter a key alias (default: `upload`)
   - Enter a keystore password (minimum 6 characters)
   - Enter a key password (minimum 6 characters)
   - Answer the certificate questions

The script will automatically:
- Generate the keystore file
- Update the `key.properties` file with your credentials

### Option B: Manual Generation

If you prefer to generate the keystore manually:

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Then manually update `android/key.properties` with:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

## Step 2: Verify Configuration

The `build.gradle.kts` file has been configured to:
- Automatically load signing configuration from `key.properties`
- Use the release signing config for release builds
- Fall back to debug signing if keystore is not found (for development)

## Step 3: Build Release Bundle (AAB)

For Play Store, you need to build an Android App Bundle (AAB):

```bash
flutter build appbundle --release
```

The AAB file will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Step 4: Build Release APK (Optional)

If you need an APK file instead:

```bash
flutter build apk --release
```

The APK file will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Step 5: Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app or select your existing app
3. Go to **Release** → **Production** (or **Testing**)
4. Click **Create new release**
5. Upload the AAB file from Step 3
6. Fill in the release notes
7. Review and roll out

## Important Security Notes

⚠️ **CRITICAL**: Keep your keystore file safe!

- **Never commit** the keystore file (`.jks` or `.keystore`) to version control
- **Never commit** the `key.properties` file to version control
- **Back up** your keystore file in a secure location
- **Store passwords** in a secure password manager
- **You'll need this keystore** for all future app updates on Play Store

If you lose your keystore:
- You **cannot** update your existing app on Play Store
- You'll need to create a new app listing with a new package name

## Troubleshooting

### Error: "key.properties not found"
- Make sure you've generated the keystore and updated `key.properties`
- Verify the file exists at `android/key.properties`

### Error: "Keystore was tampered with, or password was incorrect"
- Double-check your passwords in `key.properties`
- Ensure there are no extra spaces or special characters

### Error: "storeFile path not found"
- Verify the `storeFile` path in `key.properties` is correct
- The path should be relative to the `android/app` directory
- Example: If keystore is at `android/app/upload-keystore.jks`, use `upload-keystore.jks`

## Additional Configuration

### Update Application ID

Before releasing, consider updating the application ID in `android/app/build.gradle.kts`:

```kotlin
applicationId = "com.yourcompany.krewcarwash"
```

### Update Version

Update the version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Format: `versionName+versionCode`
- `versionName`: User-facing version (e.g., 1.0.0)
- `versionCode`: Internal version number (e.g., 1)

## Next Steps

1. ✅ Generate keystore (Step 1)
2. ✅ Build release bundle (Step 3)
3. ✅ Test the release build on a device
4. ✅ Upload to Play Store (Step 5)
5. ✅ Complete Play Store listing (screenshots, description, etc.)

Good luck with your Play Store release! 🚀




# Firebase SHA Fingerprint Setup for Release Builds

## Problem
After building a release APK, you're experiencing reCAPTCHA issues. This is because Firebase requires SHA-1 and SHA-256 fingerprints from your **release keystore** to be registered in Firebase Console.

## Your Release Keystore Fingerprints

**SHA-1:**
```
60:14:85:10:A3:3F:EC:C3:DA:CA:66:0D:B8:55:69:7B:B2:C0:54:43
```

**SHA-256:**
```
ff:f5:2d:0d:7e:b4:bc:c3:f7:d6:79:b5:6a:f2:34:85:f4:3b:72:66:b9:31:8f:db:93:2e:97:e4:9f:07:93:ff
```

## Steps to Fix reCAPTCHA Issue

### 1. Go to Firebase Console
- Open [Firebase Console](https://console.firebase.google.com/)
- Select your project: **krew-wash-faa79**

### 2. Navigate to Project Settings
- Click the **gear icon** (⚙️) next to "Project Overview"
- Select **Project settings**

### 3. Add SHA Fingerprints
- Scroll down to the **"Your apps"** section
- Find your Android app (package: `com.example.carwash_app`)
- Click on the app to expand it
- In the **"SHA certificate fingerprints"** section, click **"Add fingerprint"**

### 4. Add Both Fingerprints
Add both fingerprints one by one:

**First, add SHA-1:**
```
60:14:85:10:A3:3F:EC:C3:DA:CA:66:0D:B8:55:69:7B:B2:C0:54:43
```

**Then, add SHA-256:**
```
ff:f5:2d:0d:7e:b4:bc:c3:f7:d6:79:b5:6a:f2:34:85:f4:3b:72:66:b9:31:8f:db:93:2e:97:e4:9f:07:93:ff
```

### 5. Download Updated google-services.json
- After adding the fingerprints, Firebase will automatically update the configuration
- Click **"Download google-services.json"** button
- Replace the existing file at: `android/app/google-services.json`

### 6. Rebuild Your App
After updating the `google-services.json` file:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Why This Fixes reCAPTCHA

- **Debug builds** use a debug keystore (automatically registered by Firebase)
- **Release builds** use your custom release keystore (needs manual registration)
- Firebase uses SHA fingerprints to verify app authenticity for:
  - reCAPTCHA verification
  - Google Sign-In
  - Phone Authentication
  - Other Google services

## Verify It's Working

After adding the fingerprints and rebuilding:
1. Install the release APK on a device
2. Test reCAPTCHA functionality
3. Test Google Sign-In (if applicable)
4. Test Phone Authentication (if applicable)

## Troubleshooting

### Still Getting reCAPTCHA Errors?
1. **Wait a few minutes** - Firebase may take 5-10 minutes to propagate changes
2. **Verify fingerprints** - Double-check you copied them correctly (no extra spaces)
3. **Check google-services.json** - Ensure you downloaded the updated file
4. **Clean rebuild** - Run `flutter clean` before rebuilding

### Need to Get Fingerprints Again?
Run the script:
```bash
cd android
./get_sha_fingerprints.sh
```

## Additional Notes

- **Keep your keystore safe** - You'll need the same keystore for all future app updates
- **Don't lose the keystore** - If you lose it, you won't be able to update your app on Play Store
- **Backup your keystore** - Store it in a secure location

## Quick Reference

**Your Keystore Details:**
- File: `android/app/krew-car-wash-keystore.jks`
- Alias: `04602234576`
- Package: `com.example.carwash_app`

**Firebase Project:**
- Project ID: `krew-wash-faa79`
- Project Number: `532581665819`


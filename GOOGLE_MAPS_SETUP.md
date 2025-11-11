# Google Maps API Setup Guide

## 📍 Where to Add Your Google Maps API Key

### 1. **Android Configuration** ✅ (Already configured)
File: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

### 2. **iOS Configuration** (Manual step required)
File: `ios/Runner/AppDelegate.swift`
Add this code inside the `application` function:
```swift
import GoogleMaps

// Add this line inside application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

### 3. **Get Your Google Maps API Key**

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Create a new project** or select existing one
3. **Enable APIs**:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (optional)
4. **Go to Credentials** → **Create Credentials** → **API Key**
5. **Restrict your API key** (recommended for security):
   - For Android: Restrict by package name `com.example.carwash_app`
   - For iOS: Restrict by bundle ID `com.example.carwashApp`

### 4. **Replace Placeholder Keys**

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in:
- ✅ `android/app/src/main/AndroidManifest.xml`
- ⚠️ `ios/Runner/AppDelegate.swift` (you need to add this manually)

### 5. **Test Your Setup**

Run the app and check if the map loads properly. If you see a blank map or error, verify:
- API key is correct
- Required APIs are enabled
- Package name/Bundle ID restrictions match your app

## 🔒 Security Note
Never commit your real API key to version control. Use environment variables or secure configuration files for production apps.

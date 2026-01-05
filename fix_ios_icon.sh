#!/bin/bash

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "🧹 Cleaning Xcode Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "📦 Getting dependencies..."
flutter pub get

echo "🎨 Regenerating icons..."
flutter pub run flutter_launcher_icons

echo "📱 Uninstalling app from booted simulator (if any)..."
xcrun simctl uninstall booted com.decimaltechnology.krewwash 2>/dev/null || echo "   (No simulator running or app not installed)"

echo ""
echo "✅ Done! Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Product → Clean Build Folder (Shift+Cmd+K)"
echo "3. If using simulator, restart it: Device → Restart"
echo "4. If using physical device, uninstall the app completely"
echo "5. Rebuild: flutter build ios"
echo "6. Run: flutter run"

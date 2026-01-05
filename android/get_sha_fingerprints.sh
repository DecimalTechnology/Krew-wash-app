#!/bin/bash

# Script to get SHA-1 and SHA-256 fingerprints from release keystore
# This is required for Firebase reCAPTCHA and Google Sign-In in release builds

KEYSTORE_PATH="app/krew-car-wash-keystore.jks"
KEY_ALIAS="04602234576"
STORE_PASSWORD="04602234576"

# Find Java/Keytool
JAVA_BIN=""
if [ -f "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]; then
    JAVA_BIN="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin"
elif [ -f "$HOME/Library/Android/sdk/jbr/bin/java" ]; then
    JAVA_BIN="$HOME/Library/Android/sdk/jbr/bin"
elif command -v java &> /dev/null; then
    JAVA_BIN=$(dirname $(which java))
else
    echo "Error: Java not found. Please install Java JDK."
    exit 1
fi

KEYTOOL="$JAVA_BIN/keytool"
if [ ! -f "$KEYTOOL" ]; then
    echo "Error: keytool not found at $KEYTOOL"
    exit 1
fi

echo "=========================================="
echo "Getting SHA Fingerprints from Release Keystore"
echo "=========================================="
echo ""

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "Error: Keystore file not found at $KEYSTORE_PATH"
    exit 1
fi

echo "Keystore: $KEYSTORE_PATH"
echo "Alias: $KEY_ALIAS"
echo ""

# Get SHA-1 fingerprint
echo "SHA-1 Fingerprint:"
echo "-------------------"
"$KEYTOOL" -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" | grep -A 1 "SHA1:" | head -2
echo ""

# Get SHA-256 fingerprint
echo "SHA-256 Fingerprint:"
echo "---------------------"
"$KEYTOOL" -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" | grep -A 1 "SHA256:" | head -2
echo ""

# Extract just the fingerprint values (clean format)
echo "=========================================="
echo "Clean Fingerprint Values (copy these):"
echo "=========================================="
echo ""

SHA1=$( "$KEYTOOL" -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" 2>/dev/null | grep "SHA1:" | sed 's/.*SHA1: //' | tr -d ' ' | tr '[:lower:]' '[:upper:]' )
SHA256=$( "$KEYTOOL" -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" 2>/dev/null | grep "SHA256:" | sed 's/.*SHA256: //' | tr -d ' ' | tr '[:upper:]' '[:lower:]' )

if [ -n "$SHA1" ]; then
    echo "SHA-1:   $SHA1"
else
    echo "Warning: Could not extract SHA-1"
fi

if [ -n "$SHA256" ]; then
    echo "SHA-256: $SHA256"
else
    echo "Warning: Could not extract SHA-256"
fi

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Go to Firebase Console: https://console.firebase.google.com/"
echo "2. Select your project: krew-wash-faa79"
echo "3. Go to Project Settings (gear icon)"
echo "4. Scroll down to 'Your apps' section"
echo "5. Click on your Android app"
echo "6. Click 'Add fingerprint' button"
echo "7. Add both SHA-1 and SHA-256 fingerprints"
echo "8. Download the updated google-services.json"
echo "9. Replace android/app/google-services.json with the new file"
echo ""
echo "This will fix reCAPTCHA issues in release builds!"


#!/bin/bash

# Script to generate a keystore for Android app signing
# This keystore will be used to sign your app for Play Store release

echo "=========================================="
echo "Android Keystore Generation Script"
echo "=========================================="
echo ""
echo "This script will help you generate a keystore file for signing your Android app."
echo "IMPORTANT: Keep this keystore file and passwords safe! You'll need them for all future app updates."
echo ""

# Set default values
KEYSTORE_NAME="upload-keystore.jks"
KEYSTORE_PATH="app/$KEYSTORE_NAME"
KEY_ALIAS="upload"

# Prompt for keystore details
read -p "Enter keystore file name (default: $KEYSTORE_NAME): " input_keystore
KEYSTORE_NAME=${input_keystore:-$KEYSTORE_NAME}
KEYSTORE_PATH="app/$KEYSTORE_NAME"

read -p "Enter key alias (default: $KEY_ALIAS): " input_alias
KEY_ALIAS=${input_alias:-$KEY_ALIAS}

read -sp "Enter keystore password (min 6 characters): " STORE_PASSWORD
echo ""
read -sp "Enter key password (min 6 characters): " KEY_PASSWORD
echo ""

# Validate passwords
if [ ${#STORE_PASSWORD} -lt 6 ]; then
    echo "Error: Keystore password must be at least 6 characters"
    exit 1
fi

if [ ${#KEY_PASSWORD} -lt 6 ]; then
    echo "Error: Key password must be at least 6 characters"
    exit 1
fi

# Find Java/Keytool
# Try to use Flutter's detected Java first, then Android Studio's Java, then system Java
JAVA_BIN=""
if [ -f "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]; then
    JAVA_BIN="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin"
elif [ -f "$HOME/Library/Android/sdk/jbr/bin/java" ]; then
    JAVA_BIN="$HOME/Library/Android/sdk/jbr/bin"
elif command -v java &> /dev/null; then
    JAVA_BIN=$(dirname $(which java))
else
    echo "Error: Java not found. Please install Java JDK."
    echo "You can install it using: brew install openjdk"
    exit 1
fi

KEYTOOL="$JAVA_BIN/keytool"
if [ ! -f "$KEYTOOL" ]; then
    echo "Error: keytool not found at $KEYTOOL"
    exit 1
fi

# Generate keystore
echo ""
echo "Generating keystore using Java at: $JAVA_BIN..."
"$KEYTOOL" -genkey -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD" <<EOF
KREW CAR WASH
Development Team
Krew Car Wash
City
State
US
yes
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Keystore generated successfully!"
    echo ""
    echo "Keystore location: android/$KEYSTORE_PATH"
    echo ""
    echo "Now updating key.properties file..."
    
    # Update key.properties file (storeFile path is relative to android/app directory)
    cat > key.properties <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_NAME
EOF
    
    echo "✓ key.properties file updated!"
    echo ""
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "IMPORTANT SECURITY NOTES:"
    echo "1. Keep your keystore file ($KEYSTORE_PATH) safe and backed up"
    echo "2. Never commit the keystore or key.properties to version control"
    echo "3. Store your passwords in a secure password manager"
    echo "4. You'll need this keystore for all future app updates on Play Store"
    echo ""
    echo "You can now build a release APK/AAB with:"
    echo "  flutter build appbundle  (for Play Store)"
    echo "  flutter build apk --release  (for APK)"
    echo ""
else
    echo ""
    echo "Error: Failed to generate keystore"
    exit 1
fi


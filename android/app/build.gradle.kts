plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase Google Services plugin
}

android {
    namespace = "com.example.carwash_app"
    // Updated to SDK 36 to support latest plugin dependencies
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.carwash_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Telr Payment SDK requires minSdkVersion 21, targetSdkVersion 34
        minSdk = flutter.minSdkVersion  // Updated to 23 to support Firebase Auth 23.2.1 (meets Telr requirement of >= 21)
        targetSdk = 34  // Telr Payment SDK requires targetSdkVersion 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Load keystore properties from key.properties file
    val keystorePropertiesFile = rootProject.file("key.properties")
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val lines = keystorePropertiesFile.readLines()
                val props = lines.associate { line ->
                    val parts = line.split("=", limit = 2)
                    if (parts.size == 2) parts[0].trim() to parts[1].trim()
                    else "" to ""
                }.filterKeys { it.isNotEmpty() }
                
                keyAlias = props["keyAlias"] ?: ""
                keyPassword = props["keyPassword"] ?: ""
                storeFile = file(props["storeFile"] ?: "")
                storePassword = props["storePassword"] ?: ""
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config if keystore properties exist, otherwise fall back to debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Color constants
  static const Color primaryColor = Color(0xFF04CDFE);
  static const Color backgroundColor = Color(0xFF01031C);
  static const Color cardColor = Color(
    0xFF0A0D2C,
  ); // Slightly lighter for cards
  static const Color cardColorWithOpacity = Color(0xE60A0D2C); // 90% opacity
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Colors.white70;

  // Card decoration helper
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
  );

  // Card decoration with primary border
  static BoxDecoration get cardDecorationPrimary => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primaryColor, width: 1),
  );

  // Font family - using system default until BebasNeue fonts are added
  static const String fontFamily = 'Roboto';

  // Material Theme
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: cardColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: textSecondaryColor,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Cupertino Theme
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: textColor,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          decoration: TextDecoration.none,
        ),
        actionTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: primaryColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          decoration: TextDecoration.none,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          decoration: TextDecoration.none,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: primaryColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          decoration: TextDecoration.none,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  // Helper method to get text style with Bebas Neue font
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textColor,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined text styles for common use cases
  static TextStyle get titleStyle => getTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static TextStyle get subtitleStyle => getTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static TextStyle get bodyStyle =>
      getTextStyle(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get captionStyle => getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );

  static TextStyle get buttonStyle => getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );
}

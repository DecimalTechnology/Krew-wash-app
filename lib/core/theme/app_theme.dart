import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color primaryColor = Color(0xFF04CDFE);
  static const Color backgroundColor = Color(0xFF01031C);
  static const Color cardColor = Colors.black;
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

  // Font family - Bebas Neue
  static const String fontFamily = 'BebasNeue';

  // Base font size multiplier
  static const double baseFontSizeMultiplier = 1.3;

  // Get responsive font size multiplier based on screen width
  // Reduces font size on large screens
  static double getFontSizeMultiplier(BuildContext? context) {
    if (context == null) return baseFontSizeMultiplier;

    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for screen sizes
    const double smallScreenBreakpoint = 350;
    const double mediumScreenBreakpoint = 400;
    const double largeScreenBreakpoint = 600;
    const double extraLargeScreenBreakpoint = 800;

    // Reduce multiplier on larger screens
    if (screenWidth >= extraLargeScreenBreakpoint) {
      return baseFontSizeMultiplier *
          0.75; // 25% reduction on extra large screens
    } else if (screenWidth >= largeScreenBreakpoint) {
      return baseFontSizeMultiplier * 0.85; // 15% reduction on large screens
    } else if (screenWidth >= mediumScreenBreakpoint) {
      return baseFontSizeMultiplier * 0.95; // 5% reduction on medium screens
    } else if (screenWidth >= smallScreenBreakpoint) {
      return baseFontSizeMultiplier; // Normal size on small-medium screens
    } else {
      return baseFontSizeMultiplier *
          0.9; // Slightly smaller on very small screens
    }
  }

  // Get Bebas Neue text style
  static TextStyle bebasNeue({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
    BuildContext? context, // Optional context for responsive sizing
  }) {
    final multiplier = context != null
        ? getFontSizeMultiplier(context)
        : baseFontSizeMultiplier;

    return GoogleFonts.bebasNeue(
      fontSize: fontSize != null ? fontSize * multiplier : null,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? textColor,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );
  }

  // Material Theme
  static ThemeData get materialTheme {
    // Use BebasNeue for ALL text (including body text)
    final baseTextTheme = GoogleFonts.bebasNeueTextTheme();

    return ThemeData(
      useMaterial3: true,
      // Override bodyLarge to Inter so TextFields automatically use Inter
      // Note: This also affects regular body Text widgets. Use AppTheme.bebasNeue()
      // for body text that should use BebasNeue font.
      textTheme: baseTextTheme
          .copyWith(
            bodyLarge: GoogleFonts.inter(color: textColor, fontSize: 16),
          )
          .apply(bodyColor: textColor, displayColor: textColor),
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
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: true,
        titleTextStyle: bebasNeue(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
      // Text fields use Inter font (not BebasNeue) for better readability
      // Hint and label styles use Inter
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(color: textSecondaryColor),
        labelStyle: GoogleFonts.inter(color: textSecondaryColor),
      ),
      // Set default text style for TextField to use Inter
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: bebasNeue(fontWeight: FontWeight.w400),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: bebasNeue(fontWeight: FontWeight.w400),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: bebasNeue(fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  // Cupertino Theme
  static CupertinoThemeData get cupertinoTheme {
    return CupertinoThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: textColor,
        // Use BebasNeue for all iOS text except CupertinoTextField
        textStyle: bebasNeue(color: textColor),
        actionTextStyle: bebasNeue(
          color: primaryColor,
          fontWeight: FontWeight.w400,
        ),
        tabLabelTextStyle: bebasNeue(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
        navTitleTextStyle: bebasNeue(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        navLargeTitleTextStyle: bebasNeue(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: 28,
        ),
        navActionTextStyle: bebasNeue(
          color: primaryColor,
          fontWeight: FontWeight.w400,
        ),
        pickerTextStyle: bebasNeue(color: textColor),
        dateTimePickerTextStyle: bebasNeue(color: textColor),
      ),
    );
  }

  // Helper method to get Inter font style for text fields
  // Use this for TextField and CupertinoTextField widgets
  static TextStyle textFieldStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? textColor,
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
    return bebasNeue(
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

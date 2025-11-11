import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Helper method to get Bebas Neue text style
  static TextStyle bebasNeue({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTheme.textColor,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined styles for common use cases
  static TextStyle get largeTitle =>
      bebasNeue(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0);

  static TextStyle get title =>
      bebasNeue(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5);

  static TextStyle get subtitle =>
      bebasNeue(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.0);

  static TextStyle get body =>
      bebasNeue(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get bodySmall =>
      bebasNeue(fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle get caption => bebasNeue(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondaryColor,
  );

  static TextStyle get button =>
      bebasNeue(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0);

  static TextStyle get buttonSmall =>
      bebasNeue(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0);

  // Responsive text styles
  static TextStyle responsiveTitle(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;

    return bebasNeue(
      fontSize: isLargeScreen ? 28 : 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );
  }

  static TextStyle responsiveSubtitle(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;

    return bebasNeue(
      fontSize: isLargeScreen ? 20 : 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    );
  }

  static TextStyle responsiveBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;

    return bebasNeue(
      fontSize: isLargeScreen ? 18 : 16,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle responsiveCaption(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;

    return bebasNeue(
      fontSize: isLargeScreen ? 16 : 14,
      fontWeight: FontWeight.w500,
      color: AppTheme.textSecondaryColor,
    );
  }

  static TextStyle responsiveButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 400;

    return bebasNeue(
      fontSize: isLargeScreen ? 18 : 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );
  }
}

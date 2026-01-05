import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
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
    BuildContext? context, // Optional context for responsive sizing
  }) {
    return AppTheme.bebasNeue(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      context: context,
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

  // Responsive text styles - reduces font size on large screens
  static TextStyle responsiveTitle(BuildContext context) {
    return bebasNeue(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      context: context, // Pass context for responsive sizing
    );
  }

  static TextStyle responsiveSubtitle(BuildContext context) {
    return bebasNeue(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      context: context, // Pass context for responsive sizing
    );
  }

  static TextStyle responsiveBody(BuildContext context) {
    return bebasNeue(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      context: context, // Pass context for responsive sizing
    );
  }

  static TextStyle responsiveCaption(BuildContext context) {
    return bebasNeue(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppTheme.textSecondaryColor,
      context: context, // Pass context for responsive sizing
    );
  }

  static TextStyle responsiveButton(BuildContext context) {
    return bebasNeue(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      context: context, // Pass context for responsive sizing
    );
  }

  // ============================================
  // CUPERTINO TEXT STYLES
  // ============================================

  /// Get Cupertino text theme from context
  static CupertinoTextThemeData cupertinoTextTheme(BuildContext context) {
    return CupertinoTheme.of(context).textTheme;
  }

  /// Cupertino large title style (iOS navigation large title)
  static TextStyle cupertinoLargeTitle(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle;
  }

  /// Cupertino navigation title style
  static TextStyle cupertinoNavTitle(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.navTitleTextStyle;
  }

  /// Cupertino action text style (for buttons/links)
  static TextStyle cupertinoAction(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.actionTextStyle;
  }

  /// Cupertino tab label style
  static TextStyle cupertinoTabLabel(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.tabLabelTextStyle;
  }

  /// Cupertino picker text style
  static TextStyle cupertinoPicker(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.pickerTextStyle;
  }

  /// Cupertino date time picker text style
  static TextStyle cupertinoDateTimePicker(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.dateTimePickerTextStyle;
  }

  /// Cupertino default text style
  static TextStyle cupertinoText(BuildContext context) {
    return CupertinoTheme.of(context).textTheme.textStyle;
  }

  /// Custom Cupertino-style text with Bebas Neue font
  static TextStyle cupertino({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.bebasNeue(
      fontSize: fontSize ?? 17,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppTheme.textColor,
      letterSpacing: letterSpacing ?? 0.5,
      height: height,
    );
  }

  /// Cupertino headline style
  static TextStyle get cupertinoHeadline =>
      cupertino(fontSize: 17, fontWeight: FontWeight.w600);

  /// Cupertino subheadline style
  static TextStyle get cupertinoSubheadline =>
      cupertino(fontSize: 15, fontWeight: FontWeight.normal);

  /// Cupertino body style
  static TextStyle get cupertinoBody =>
      cupertino(fontSize: 17, fontWeight: FontWeight.normal);

  /// Cupertino callout style
  static TextStyle get cupertinoCallout =>
      cupertino(fontSize: 16, fontWeight: FontWeight.normal);

  /// Cupertino footnote style
  static TextStyle get cupertinoFootnote => cupertino(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryColor,
  );

  /// Cupertino caption 1 style
  static TextStyle get cupertinoCaption1 => cupertino(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryColor,
  );

  /// Cupertino caption 2 style
  static TextStyle get cupertinoCaption2 => cupertino(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryColor,
  );

  /// Cupertino title 1 style
  static TextStyle get cupertinoTitle1 => cupertino(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.36,
  );

  /// Cupertino title 2 style
  static TextStyle get cupertinoTitle2 => cupertino(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.35,
  );

  /// Cupertino title 3 style
  static TextStyle get cupertinoTitle3 => cupertino(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.38,
  );
}

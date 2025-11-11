class SizeConstants {
  // Private constructor to prevent instantiation
  SizeConstants._();

  // Screen size breakpoints
  static const double smallScreenBreakpoint = 350;
  static const double mediumScreenBreakpoint = 400;
  static const double largeScreenBreakpoint = 600;

  // Padding and margins
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 16.0;
  static const double extraLargePadding = 20.0;
  static const double hugePadding = 24.0;
  static const double massivePadding = 28.0;

  // Font sizes
  static const double smallFontSize = 10.0;
  static const double mediumFontSize = 12.0;
  static const double largeFontSize = 14.0;
  static const double extraLargeFontSize = 16.0;
  static const double hugeFontSize = 18.0;
  static const double massiveFontSize = 20.0;
  static const double giantFontSize = 24.0;
  static const double enormousFontSize = 28.0;
  static const double colossalFontSize = 32.0;

  // Icon sizes
  static const double smallIconSize = 12.0;
  static const double mediumIconSize = 16.0;
  static const double largeIconSize = 20.0;
  static const double extraLargeIconSize = 24.0;
  static const double hugeIconSize = 28.0;
  static const double massiveIconSize = 32.0;

  // Button sizes
  static const double smallButtonHeight = 40.0;
  static const double mediumButtonHeight = 48.0;
  static const double largeButtonHeight = 56.0;
  static const double extraLargeButtonHeight = 64.0;

  // Container sizes
  static const double smallContainerSize = 20.0;
  static const double mediumContainerSize = 40.0;
  static const double largeContainerSize = 50.0;
  static const double extraLargeContainerSize = 60.0;

  // Border radius
  static const double smallBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 20.0;
  static const double hugeBorderRadius = 24.0;
  static const double massiveBorderRadius = 28.0;

  // Spacing
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 8.0;
  static const double largeSpacing = 12.0;
  static const double extraLargeSpacing = 16.0;
  static const double hugeSpacing = 20.0;
  static const double massiveSpacing = 24.0;
  static const double giantSpacing = 32.0;

  // Elevation
  static const double smallElevation = 4.0;
  static const double mediumElevation = 8.0;
  static const double largeElevation = 12.0;
  static const double extraLargeElevation = 16.0;

  // Helper methods for responsive sizing
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallPadding;
    if (screenWidth < mediumScreenBreakpoint) return mediumPadding;
    if (screenWidth < largeScreenBreakpoint) return largePadding;
    return extraLargePadding;
  }

  static double getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < smallScreenBreakpoint) return baseSize * 0.8;
    if (screenWidth < mediumScreenBreakpoint) return baseSize * 0.9;
    if (screenWidth < largeScreenBreakpoint) return baseSize;
    return baseSize * 1.1;
  }

  static double getResponsiveIconSize(double screenWidth, double baseSize) {
    if (screenWidth < smallScreenBreakpoint) return baseSize * 0.8;
    if (screenWidth < mediumScreenBreakpoint) return baseSize * 0.9;
    if (screenWidth < largeScreenBreakpoint) return baseSize;
    return baseSize * 1.1;
  }

  static double getResponsiveButtonHeight(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallButtonHeight;
    if (screenWidth < mediumScreenBreakpoint) return mediumButtonHeight;
    if (screenWidth < largeScreenBreakpoint) return largeButtonHeight;
    return extraLargeButtonHeight;
  }

  static double getResponsiveBorderRadius(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallBorderRadius;
    if (screenWidth < mediumScreenBreakpoint) return mediumBorderRadius;
    if (screenWidth < largeScreenBreakpoint) return largeBorderRadius;
    return extraLargeBorderRadius;
  }

  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallSpacing;
    if (screenWidth < mediumScreenBreakpoint) return mediumSpacing;
    if (screenWidth < largeScreenBreakpoint) return largeSpacing;
    return extraLargeSpacing;
  }

  static double getResponsiveElevation(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallElevation;
    if (screenWidth < mediumScreenBreakpoint) return mediumElevation;
    if (screenWidth < largeScreenBreakpoint) return largeElevation;
    return extraLargeElevation;
  }
}

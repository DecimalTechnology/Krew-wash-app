class SizeConstants {
  // Private constructor to prevent instantiation
  SizeConstants._();

  // Screen size breakpoints
  static const double smallScreenBreakpoint = 350;
  static const double mediumScreenBreakpoint = 400;
  static const double largeScreenBreakpoint = 600;
  /// iPad 13" (iPad Pro 12.9") portrait width in logical pixels (~1024).
  /// Use for appropriate layout and max content width on large tablets.
  static const double ipad13Breakpoint = 1024;
  /// Max width for main content when on iPad 13" or larger (keeps layout readable).
  static const double maxContentWidthForLargeScreen = 800;
  /// Scale factor for widgets (fonts, icons, padding, etc.) on iPad 13" and larger.
  /// Use to increase widget sizes for better touch targets and readability.
  static const double ipadContentScaleFactor = 1.2;

  /// Returns a size scaled for iPad 13" when applicable (e.g. baseSize * 1.2 on iPad).
  /// Use for any dimension you want larger on iPad: fonts, icons, padding, heights.
  static double getIpadAwareSize(double screenWidth, double baseSize) {
    if (screenWidth >= ipad13Breakpoint) {
      return baseSize * ipadContentScaleFactor;
    }
    return baseSize;
  }

  /// Returns true when screen width is iPad 13" or larger (e.g. iPad Pro 12.9").
  static bool isIpad13OrLarger(double screenWidth) =>
      screenWidth >= ipad13Breakpoint;

  /// Returns max content width to use for the current screen (for centered, readable layout on iPad).
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth >= ipad13Breakpoint) return maxContentWidthForLargeScreen;
    return double.infinity;
  }

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
    if (screenWidth >= ipad13Breakpoint) {
      return hugePadding * ipadContentScaleFactor;
    }
    return extraLargePadding;
  }

  static double getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < smallScreenBreakpoint) return baseSize * 0.8;
    if (screenWidth < mediumScreenBreakpoint) return baseSize * 0.9;
    if (screenWidth < largeScreenBreakpoint) return baseSize;
    // iPad 13": scale up for readability and prominence
    if (screenWidth >= ipad13Breakpoint) {
      return baseSize * ipadContentScaleFactor;
    }
    if (screenWidth >= 800) {
      return baseSize * 0.75; // 25% reduction on extra large (non‑iPad) screens
    }
    return baseSize * 0.85; // 15% reduction on large screens
  }

  static double getResponsiveIconSize(double screenWidth, double baseSize) {
    if (screenWidth < smallScreenBreakpoint) return baseSize * 0.8;
    if (screenWidth < mediumScreenBreakpoint) return baseSize * 0.9;
    if (screenWidth < largeScreenBreakpoint) return baseSize;
    // iPad 13": scale up for touch targets and clarity
    if (screenWidth >= ipad13Breakpoint) {
      return baseSize * ipadContentScaleFactor;
    }
    if (screenWidth >= 800) {
      return baseSize * 0.75; // 25% reduction on extra large (non‑iPad) screens
    }
    return baseSize * 0.85; // 15% reduction on large screens
  }

  static double getResponsiveButtonHeight(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallButtonHeight;
    if (screenWidth < mediumScreenBreakpoint) return mediumButtonHeight;
    if (screenWidth < largeScreenBreakpoint) return largeButtonHeight;
    // iPad 13": larger tap targets
    if (screenWidth >= ipad13Breakpoint) {
      return extraLargeButtonHeight * ipadContentScaleFactor;
    }
    return extraLargeButtonHeight;
  }

  static double getResponsiveBorderRadius(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallBorderRadius;
    if (screenWidth < mediumScreenBreakpoint) return mediumBorderRadius;
    if (screenWidth < largeScreenBreakpoint) return largeBorderRadius;
    if (screenWidth >= ipad13Breakpoint) {
      return hugeBorderRadius * (ipadContentScaleFactor * 0.9); // Slightly scaled
    }
    return extraLargeBorderRadius;
  }

  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallSpacing;
    if (screenWidth < mediumScreenBreakpoint) return mediumSpacing;
    if (screenWidth < largeScreenBreakpoint) return largeSpacing;
    if (screenWidth >= ipad13Breakpoint) {
      return hugeSpacing * (ipadContentScaleFactor * 0.85);
    }
    return extraLargeSpacing;
  }

  static double getResponsiveElevation(double screenWidth) {
    if (screenWidth < smallScreenBreakpoint) return smallElevation;
    if (screenWidth < mediumScreenBreakpoint) return mediumElevation;
    if (screenWidth < largeScreenBreakpoint) return largeElevation;
    if (screenWidth >= ipad13Breakpoint) return largeElevation;
    return extraLargeElevation;
  }
}

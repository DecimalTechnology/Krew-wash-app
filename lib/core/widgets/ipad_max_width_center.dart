import 'package:flutter/material.dart';
import '../constants/size_constants.dart';

/// Wraps [child] for iPad 13" and larger screens (width >= 1024).
/// When [useFullScreenOnIpad] is true (default), the child uses the full screen on iPad.
/// Set [useFullScreenOnIpad] to false to constrain to [maxWidth] and center instead.
/// Widget sizes still scale up on iPad via [SizeConstants.ipadContentScaleFactor].
class IpadMaxWidthCenter extends StatelessWidget {
  const IpadMaxWidthCenter({
    super.key,
    required this.child,
    this.maxWidth,
    /// When true, the child is given the full available height (e.g. for full-screen tab content).
    /// Defaults to false (child's intrinsic height).
    this.fillHeight = false,
    /// How to align the content when [useFullScreenOnIpad] is false.
    this.alignment = Alignment.topCenter,
    /// When true (default), on iPad 13" the child uses the full screen (no max-width).
    /// Set to false to keep centered max-width layout on iPad.
    this.useFullScreenOnIpad = true,
  });

  final Widget child;
  /// Override max content width when [useFullScreenOnIpad] is false.
  final double? maxWidth;
  final bool fillHeight;
  final AlignmentGeometry alignment;
  final bool useFullScreenOnIpad;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (!SizeConstants.isIpad13OrLarger(screenWidth)) {
      return child;
    }
    // Full screen on iPad: no constraint, child uses entire width and height
    if (useFullScreenOnIpad) {
      return child;
    }
    final effectiveMaxWidth =
        maxWidth ?? SizeConstants.maxContentWidthForLargeScreen;
    if (fillHeight) {
      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: effectiveMaxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: SizedBox(
                width: effectiveMaxWidth,
                height: constraints.maxHeight,
                child: Align(
                  alignment: alignment,
                  child: child,
                ),
              ),
            );
          },
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Align(
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}

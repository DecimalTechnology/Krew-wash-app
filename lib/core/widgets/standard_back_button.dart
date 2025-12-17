import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Standardized back button widget used across all screens
class StandardBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;

  const StandardBackButton({
    super.key,
    this.onPressed,
    this.size,
    this.backgroundColor,
    this.iconColor,
  });

  // Standard size: 40x40
  static const double standardSize = 40.0;
  static const Color standardBackgroundColor = Color(0xFF04CDFE);
  static const Color standardIconColor = Colors.white;
  static const double standardIconSize = 20.0;
  static const double standardBorderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final buttonSize = size ?? standardSize;
    final bgColor = backgroundColor ?? standardBackgroundColor;
    final icColor = iconColor ?? standardIconColor;
    final borderRadius = buttonSize / 2; // Circular

    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            CupertinoIcons.back,
            color: icColor,
            size: standardIconSize,
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Icon(
              Icons.arrow_back,
              color: icColor,
              size: standardIconSize,
            ),
          ),
        ),
      );
    }
  }
}

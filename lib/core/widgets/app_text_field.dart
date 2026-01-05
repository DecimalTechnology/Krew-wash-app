import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// A custom TextField widget that automatically uses Inter font
/// instead of the default BebasNeue font from the theme.
/// 
/// Use this widget instead of the standard TextField to ensure
/// text fields use Inter font for better readability.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final String? Function(String?)? validator;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? cursorColor;
  final bool? showCursor;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.decoration,
    this.style,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.validator,
    this.contentPadding,
    this.suffixIcon,
    this.prefixIcon,
    this.cursorColor,
    this.showCursor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      showCursor: showCursor,
      style: style ?? AppTheme.textFieldStyle(),
      cursorColor: cursorColor ?? AppTheme.primaryColor,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
            contentPadding: contentPadding,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
    );
  }
}

/// A custom CupertinoTextField widget that automatically uses Inter font
/// instead of the default BebasNeue font from the theme.
/// 
/// Use this widget instead of the standard CupertinoTextField to ensure
/// text fields use Inter font for better readability.
class AppCupertinoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final BoxDecoration? decoration;
  final TextStyle? style;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final EdgeInsets? padding;
  final Widget? suffix;
  final Widget? prefix;
  final Color? cursorColor;
  final OverlayVisibilityMode clearButtonMode;
  final bool showCursor;

  const AppCupertinoTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.decoration,
    this.style,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.padding,
    this.suffix,
    this.prefix,
    this.cursorColor,
    this.clearButtonMode = OverlayVisibilityMode.never,
    this.showCursor = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      showCursor: showCursor,
      style: style ?? AppTheme.textFieldStyle(),
      cursorColor: cursorColor ?? AppTheme.primaryColor,
      decoration: decoration,
      padding: padding ?? EdgeInsets.zero,
      suffix: suffix,
      prefix: prefix,
      clearButtonMode: clearButtonMode,
    );
  }
}


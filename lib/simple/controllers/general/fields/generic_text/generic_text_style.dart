import 'package:flutter/material.dart';

class GenericTextStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final Widget? clearIcon;

  const GenericTextStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.clearIcon,
  });

  GenericTextStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericTextStyle(
      textStyle: textStyle ?? theme.textTheme.bodyLarge,
      hintStyle:
          hintStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      clearIcon:
          clearIcon ??
          Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
      decoration:
          decoration ??
          const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
    );
  }
}

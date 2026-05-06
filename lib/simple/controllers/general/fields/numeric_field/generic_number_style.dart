import 'package:flutter/material.dart';

class GenericNumberStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final Widget? clearIcon;
  final Widget? prefixIcon; // ممتاز لرموز العملات ($)
  final Widget? suffixText; // ممتاز للوحدات (KG, CM)

  const GenericNumberStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.clearIcon,
    this.prefixIcon,
    this.suffixText,
  });

  GenericNumberStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericNumberStyle(
      textStyle: textStyle ?? theme.textTheme.bodyLarge,
      hintStyle:
          hintStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      clearIcon:
          clearIcon ??
          Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      decoration:
          decoration ??
          const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
    );
  }
}

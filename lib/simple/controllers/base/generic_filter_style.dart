import 'package:flutter/material.dart';

class GenericFilterStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? searchBarHeight;
  final Widget? customTrailingIcon;

  const GenericFilterStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.searchBarHeight,
    this.customTrailingIcon,
  });

  // دالة ذكية تدمج التنسيق الممرر مع التنسيق الافتراضي للتطبيق
  GenericFilterStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericFilterStyle(
      backgroundColor: backgroundColor ?? theme.cardColor,
      borderColor: borderColor ?? theme.dividerColor,
      borderRadius: borderRadius ?? 8.0, // 8.0 كقيمة افتراضية آمنة
      textStyle: textStyle ?? theme.textTheme.bodyMedium,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      searchBarHeight: searchBarHeight ?? 45.0,
      customTrailingIcon: customTrailingIcon ?? const Icon(Icons.keyboard_arrow_down),
    );
  }
}
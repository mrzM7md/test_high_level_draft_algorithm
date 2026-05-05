import 'package:flutter/material.dart';

class GenericCheckboxStyle {
  final Color? activeColor;
  final Color? checkColor;
  final TextStyle? defaultTextStyle;
  final TextStyle? activeTextStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  const GenericCheckboxStyle({
    this.activeColor,
    this.checkColor,
    this.defaultTextStyle,
    this.activeTextStyle,
    this.decoration,
    this.padding,
  });


  GenericCheckboxStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericCheckboxStyle(
      activeColor: activeColor ?? theme.colorScheme.primary,
      checkColor: checkColor ?? theme.colorScheme.onPrimary,
      defaultTextStyle: defaultTextStyle ?? theme.textTheme.bodyMedium,
      activeTextStyle: activeTextStyle ?? theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      // إذا لم يمرر المبرمج ديكور، نستخدم ديكور شفاف لتجنب المربعات القبيحة الافتراضية
      decoration: decoration ?? const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GenericDropdownRangeStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final double? menuMaxHeight;
  final Widget? dropdownIcon;

  const GenericDropdownRangeStyle({
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.decoration,
    this.padding,
    this.menuMaxHeight,
    this.dropdownIcon,
  });

  GenericDropdownRangeStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericDropdownRangeStyle(
      textStyle: textStyle ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      hintStyle: hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      labelStyle: labelStyle ?? theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      menuMaxHeight: menuMaxHeight ?? 300.0,
      dropdownIcon: dropdownIcon ?? Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary, size: 20),
      decoration: decoration ?? const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
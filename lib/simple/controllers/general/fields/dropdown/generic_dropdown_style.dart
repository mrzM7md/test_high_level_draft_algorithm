import 'package:flutter/material.dart';

class GenericDropdownStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final double? menuMaxHeight;
  final Widget? defaultDropdownIcon;

  const GenericDropdownStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.menuMaxHeight,
    this.defaultDropdownIcon,
  });

  GenericDropdownStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericDropdownStyle(
      textStyle: textStyle ?? theme.textTheme.bodyMedium,
      hintStyle: hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      menuMaxHeight: menuMaxHeight ?? 300.0, // حماية من القوائم الطويلة جداً
      defaultDropdownIcon: defaultDropdownIcon ?? Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
      decoration: decoration ?? const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
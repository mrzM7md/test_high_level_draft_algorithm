import 'package:flutter/material.dart';

class FilterGroupStyle {
  final TextStyle? titleTextStyle;
  final Color? headerColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? childrenPadding;
  final ShapeBorder? shape;
  final Widget? expansionIcon;

  const FilterGroupStyle({
    this.titleTextStyle,
    this.headerColor,
    this.backgroundColor,
    this.borderColor,
    this.margin,
    this.childrenPadding,
    this.shape,
    this.expansionIcon,
  });

  FilterGroupStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return FilterGroupStyle(
      titleTextStyle:
          titleTextStyle ??
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: headerColor ?? theme.colorScheme.primary,
          ),
      headerColor: headerColor ?? theme.colorScheme.primary,
      backgroundColor: backgroundColor ?? theme.cardColor,
      borderColor: borderColor ?? theme.dividerColor,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      childrenPadding:
          childrenPadding ??
          const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor ?? theme.dividerColor.withOpacity(0.5),
            ),
          ),
      expansionIcon: expansionIcon,
    );
  }
}

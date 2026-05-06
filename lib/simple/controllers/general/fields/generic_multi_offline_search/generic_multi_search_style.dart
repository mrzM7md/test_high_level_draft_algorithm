import 'package:flutter/material.dart';

class GenericMultiSearchStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  final double? bottomSheetHeightRatio;
  final ShapeBorder? bottomSheetShape;
  final InputDecoration? searchFieldDecoration;

  final Color? chipBackgroundColor;
  final Color? chipDeleteIconColor;
  final TextStyle? chipTextStyle;
  final OutlinedBorder? chipShape;

  const GenericMultiSearchStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.bottomSheetHeightRatio,
    this.bottomSheetShape,
    this.searchFieldDecoration,
    this.chipBackgroundColor,
    this.chipDeleteIconColor,
    this.chipTextStyle,
    this.chipShape,
  });

  GenericMultiSearchStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericMultiSearchStyle(
      textStyle: textStyle ?? theme.textTheme.bodyMedium,
      hintStyle:
          hintStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      bottomSheetHeightRatio: bottomSheetHeightRatio ?? 0.75,
      bottomSheetShape:
          bottomSheetShape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      searchFieldDecoration:
          searchFieldDecoration ??
          InputDecoration(
            labelText: "بحث...",
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
      chipBackgroundColor:
          chipBackgroundColor ??
          theme.colorScheme.primaryContainer.withOpacity(0.5),
      chipDeleteIconColor:
          chipDeleteIconColor ?? theme.colorScheme.onPrimaryContainer,
      chipTextStyle:
          chipTextStyle ??
          TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
      chipShape:
          chipShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
      decoration:
          decoration ??
          const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
    );
  }
}

import 'package:flutter/material.dart';

class GenericSearchRangeStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  final double? bottomSheetHeightRatio;
  final ShapeBorder? bottomSheetShape;
  final InputDecoration? searchFieldDecoration;
  final Widget? trailingIcon;

  const GenericSearchRangeStyle({
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.decoration,
    this.padding,
    this.bottomSheetHeightRatio,
    this.bottomSheetShape,
    this.searchFieldDecoration,
    this.trailingIcon,
  });

  GenericSearchRangeStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericSearchRangeStyle(
      textStyle:
          textStyle ??
          theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      hintStyle:
          hintStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      labelStyle:
          labelStyle ??
          theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
      trailingIcon:
          trailingIcon ??
          Icon(
            Icons.search_rounded,
            size: 18,
            color: theme.colorScheme.primary,
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

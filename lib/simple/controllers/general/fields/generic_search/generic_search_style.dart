import 'package:flutter/material.dart';

class GenericSearchStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  final double? bottomSheetHeightRatio;
  final ShapeBorder? bottomSheetShape;
  final InputDecoration? searchFieldDecoration;
  final Widget? trailingIcon;

  const GenericSearchStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.bottomSheetHeightRatio,
    this.bottomSheetShape,
    this.searchFieldDecoration,
    this.trailingIcon,
  });

  GenericSearchStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericSearchStyle(
      textStyle:
          textStyle ??
          theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
      trailingIcon:
          trailingIcon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
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

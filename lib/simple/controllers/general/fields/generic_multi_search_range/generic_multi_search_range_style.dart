import 'package:flutter/material.dart';

class GenericMultiSearchRangeStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  final double? bottomSheetHeightRatio;
  final ShapeBorder? bottomSheetShape;
  final InputDecoration? searchFieldDecoration;

  // 🚀 تفريق الألوان ديناميكياً بين (من) و (إلى) لدعم الوضع الليلي
  final Color? fromChipBackgroundColor;
  final Color? toChipBackgroundColor;
  final Color? chipDeleteIconColor;
  final TextStyle? fromChipTextStyle;
  final TextStyle? toChipTextStyle;
  final OutlinedBorder? chipShape;

  const GenericMultiSearchRangeStyle({
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.padding,
    this.bottomSheetHeightRatio,
    this.bottomSheetShape,
    this.searchFieldDecoration,
    this.fromChipBackgroundColor,
    this.toChipBackgroundColor,
    this.chipDeleteIconColor,
    this.fromChipTextStyle,
    this.toChipTextStyle,
    this.chipShape,
  });

  GenericMultiSearchRangeStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericMultiSearchRangeStyle(
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
            labelText: "search...",
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
      // 🚀 استخدام primaryContainer لـ "من"، و tertiaryContainer لـ "إلى"
      fromChipBackgroundColor:
          fromChipBackgroundColor ??
          theme.colorScheme.primaryContainer.withOpacity(0.5),
      toChipBackgroundColor:
          toChipBackgroundColor ??
          theme.colorScheme.tertiaryContainer.withOpacity(0.5),
      chipDeleteIconColor: chipDeleteIconColor ?? theme.colorScheme.onSurface,
      fromChipTextStyle:
          fromChipTextStyle ??
          TextStyle(fontSize: 12, color: theme.colorScheme.primary),
      toChipTextStyle:
          toChipTextStyle ??
          TextStyle(fontSize: 12, color: theme.colorScheme.tertiary),
      chipShape:
          chipShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.dividerColor),
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

import 'package:flutter/material.dart';

class GenericDateStyle {
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final Widget? calendarIcon;
  // 🚀 دالة لتنسيق التاريخ ديناميكياً بدلاً من split العشوائي
  final String Function(DateTime)? dateFormatter;

  const GenericDateStyle({
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.decoration,
    this.padding,
    this.calendarIcon,
    this.dateFormatter,
  });

  GenericDateStyle mergeWithDefault(BuildContext context) {
    final theme = Theme.of(context);
    return GenericDateStyle(
      textStyle: textStyle ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      hintStyle: hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      labelStyle: labelStyle ?? theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      calendarIcon: calendarIcon ?? Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 22),
      // التنسيق الافتراضي الآمن
      dateFormatter: dateFormatter ?? (date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      decoration: decoration ?? const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
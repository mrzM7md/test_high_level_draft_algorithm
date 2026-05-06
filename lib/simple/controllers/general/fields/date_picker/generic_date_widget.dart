import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker/generic_date_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker/generic_date_style.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker_range/generic_date_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';
// لا تنسَ استيراد ملف GenericDateStyle

// ==========================================
// 1. Widget التاريخ الفردي
// ==========================================
class GenericDateWidget extends StatelessWidget {
  final GenericDateController controller;
  final String labelText;
  final String hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final GenericDateStyle? style;

  // 🚀 البنّاء المخصص للقوة المطلقة
  final Widget Function(BuildContext context, DateTime? selectedDate, GenericDateController controller)? customBuilder;

  const GenericDateWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = "Select Date",
    this.firstDate,
    this.lastDate,
    this.style,
    this.customBuilder,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.tempValue ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) controller.updateTemp(picked);
  }

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (style ?? const GenericDateStyle()).mergeWithDefault(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();
        final temp = controller.tempValue;

        if (customBuilder != null) return customBuilder!(context, temp, controller);

        Widget? suffixActions;
        if (temp != null) {
          suffixActions = IconButton(
            icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.error, size: 20),
            onPressed: () => controller.clear(),
            splashRadius: 20,
          );
        }

        return Padding(
          padding: appliedStyle.padding!,
          child: InputDecorator(
            decoration: appliedStyle.decoration!.copyWith(
              labelText: labelText,
              errorText: controller.validationError,
              suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (suffixActions != null) suffixActions,
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: appliedStyle.calendarIcon!),
                  ]
              ),
            ),
            child: InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(4),
              child: Text(
                temp != null ? appliedStyle.dateFormatter!(temp) : hintText,
                style: temp != null ? appliedStyle.textStyle : appliedStyle.hintStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 2. Widget نطاق التاريخ (مُحسّن UXياً)
// ==========================================
class GenericDateRangeWidget extends StatelessWidget {
  final GenericDateRangeController controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final GenericDateStyle? style;

  final Widget Function(BuildContext context, DateRange? selectedRange, GenericDateRangeController controller)? customBuilder;

  const GenericDateRangeWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.fromLabelText = "From",
    this.toLabelText = "To",
    this.firstDate,
    this.lastDate,
    this.style,
    this.customBuilder,
  });

  // 🚀 إصلاح الـ UX: استخدام DateRangePicker الحقيقي بدلاً من تقويمين!
  Future<void> _pickDateRange(BuildContext context) async {
    final temp = controller.tempValue;
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: temp != null ? DateTimeRange(start: temp.fromDate, end: temp.toDate) : null,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        // دعم اللغة العربية والاتجاهات
        return Directionality(textDirection: Directionality.of(context), child: child!);
      },
    );

    if (pickedRange != null) {
      // 🚀 أمان منطقي: التطبيق يضمن أن fromDate دائمًا قبل toDate
      controller.updateTemp(DateRange(fromDate: pickedRange.start, toDate: pickedRange.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (style ?? const GenericDateStyle()).mergeWithDefault(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();

        final temp = controller.tempValue;
        if (customBuilder != null) return customBuilder!(context, temp, controller);

        return Padding(
          padding: appliedStyle.padding!,
          child: InputDecorator(
            decoration: appliedStyle.decoration!.copyWith(
              labelText: labelText,
              errorText: controller.validationError,
              suffixIcon: temp != null
                  ? IconButton(icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.error, size: 20), onPressed: () => controller.clear())
                  : null,
            ),
            child: InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(fromLabelText, style: appliedStyle.labelStyle),
                            Text(temp != null ? appliedStyle.dateFormatter!(temp.fromDate) : "---", style: appliedStyle.textStyle)
                          ]
                      )
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(toLabelText, style: appliedStyle.labelStyle),
                            Text(temp != null ? appliedStyle.dateFormatter!(temp.toDate) : "---", style: appliedStyle.textStyle)
                          ]
                      )
                  ),
                  appliedStyle.calendarIcon!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
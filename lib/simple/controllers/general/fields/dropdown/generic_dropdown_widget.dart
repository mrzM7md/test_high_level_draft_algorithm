import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_style.dart';

class GenericDropdownWidget<T> extends StatefulWidget {
  final GenericDropdownController<T> controller;
  final String labelText;
  final String hintText;
  final GenericDropdownStyle? style;

  // 🚀 ترقية: السماح ببناء واجهة مخصصة لكل عنصر (صورة، نصين، الخ)
  final Widget Function(BuildContext context, T item)? itemBuilder;
  // مسار بديل وسريع لمن لا يريد بناء واجهة معقدة
  final String Function(T item)? itemLabelBuilder;

  // 🚀 البنّاء الخارق (Ultimate Builder) للتحكم الكامل
  final Widget Function(BuildContext context, T? selectedItem, GenericDropdownController<T> controller)? customBuilder;

  const GenericDropdownWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = "اختر من القائمة...",
    this.itemBuilder,
    this.itemLabelBuilder,
    this.style,
    this.customBuilder,
  }) : assert(itemBuilder != null || itemLabelBuilder != null || customBuilder != null,
  'يجب تمرير itemBuilder أو itemLabelBuilder على الأقل لمعرفة كيف سيتم رسم العناصر');

  @override
  State<GenericDropdownWidget<T>> createState() => _GenericDropdownWidgetState<T>();
}

class _GenericDropdownWidgetState<T> extends State<GenericDropdownWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🚀 السحر المعماري 1: نقل التحميل إلى التهيئة لإنقاذ الـ Event Loop!
    widget.controller.ensureDataLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (widget.style ?? const GenericDropdownStyle()).mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null && !widget.controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final temp = widget.controller.tempValue;

        // 🚀 السحر 2: هل استخدم المبرمج البنّاء الخارق؟
        if (widget.customBuilder != null) {
          return widget.customBuilder!(context, temp, widget.controller);
        }

        // بناء الأيقونات الذكية في الطرف
        Widget? smartSuffixIcon;
        if (widget.controller.isLoading) {
          smartSuffixIcon = const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (widget.controller.errorMessage != null && widget.controller.showReloadButton) {
          smartSuffixIcon = IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.error),
            onPressed: () => widget.controller.refreshData(forceReload: true),
            splashRadius: 20,
          );
        } else if (temp != null) {
          smartSuffixIcon = IconButton(
            icon: Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
            onPressed: () => widget.controller.clear(),
            splashRadius: 20,
          );
        }

        // أمان للـ Dropdown: إذا كانت القيمة غير موجودة باللستة، نمرر null لمنع الانهيار
        final safeValue = widget.controller.items.contains(temp) ? temp : null;

        return Padding(
          padding: appliedStyle.padding!,
          child: DropdownButtonFormField<T>(
            decoration: appliedStyle.decoration!.copyWith(
              labelText: widget.labelText,
              errorText: widget.controller.errorMessage ?? widget.controller.validationError,
              suffixIcon: smartSuffixIcon,
            ),
            icon: smartSuffixIcon != null ? const SizedBox.shrink() : appliedStyle.defaultDropdownIcon,
            menuMaxHeight: appliedStyle.menuMaxHeight,
            hint: Text(widget.hintText, style: appliedStyle.hintStyle),
            isExpanded: true,
            value: safeValue,
            items: widget.controller.items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: widget.itemBuilder != null
                    ? widget.itemBuilder!(context, item)
                    : Text(widget.itemLabelBuilder!(item), style: appliedStyle.textStyle),
              );
            }).toList(),
            onChanged: (val) => widget.controller.updateTemp(val),
          ),
        );
      },
    );
  }
}
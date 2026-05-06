import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_style.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';

class GenericDropdownRangeWidget<T> extends StatefulWidget {
  final GenericDropdownRangeController<T> controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final GenericDropdownRangeStyle? style;
  final bool showReloadButton;

  // 🚀 البنّاء المرن
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final String Function(T item)? itemLabelBuilder;

  // 🚀 البنّاء المطلق للتحكم الكامل
  final Widget Function(BuildContext context, DropdownRange<T>? selectedRange, GenericDropdownRangeController<T> controller)? customBuilder;

  const GenericDropdownRangeWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.itemBuilder,
    this.itemLabelBuilder,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.showReloadButton = true,
    this.style,
    this.customBuilder,
  }) : assert(itemBuilder != null || itemLabelBuilder != null || customBuilder != null,
  'يجب توفير طريقة لرسم العناصر (itemBuilder أو itemLabelBuilder)');

  @override
  State<GenericDropdownRangeWidget<T>> createState() => _GenericDropdownRangeWidgetState<T>();
}

class _GenericDropdownRangeWidgetState<T> extends State<GenericDropdownRangeWidget<T>> {

  @override
  void initState() {
    super.initState();
    // 🚀 السحر المعماري: الجلب يتم مرة واحدة فقط عند البناء!
    widget.controller.ensureDataLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (widget.style ?? const GenericDropdownRangeStyle()).mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null && !widget.controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final temp = widget.controller.tempValue;

        if (widget.customBuilder != null) {
          return widget.customBuilder!(context, temp, widget.controller);
        }

        // الأيقونات الذكية
        Widget? smartSuffixIcon;
        if (widget.controller.isLoading) {
          smartSuffixIcon = const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
        } else if (widget.controller.errorMessage != null && widget.showReloadButton) {
          smartSuffixIcon = IconButton(icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.error), onPressed: () => widget.controller.refreshData(forceReload: true), splashRadius: 20);
        } else if (temp?.fromValue != null || temp?.toValue != null) {
          smartSuffixIcon = IconButton(icon: Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20), onPressed: () => widget.controller.clear(), splashRadius: 20);
        }

        return Padding(
          padding: appliedStyle.padding!,
          child: InputDecorator(
            decoration: appliedStyle.decoration!.copyWith(
              labelText: widget.labelText,
              errorText: widget.controller.errorMessage ?? widget.controller.validationError,
              suffixIcon: smartSuffixIcon,
            ),
            child: Row(
              children: [
                Expanded(child: _buildDropdown(label: widget.fromLabelText, value: temp?.fromValue, isFrom: true, style: appliedStyle)),
                Container(width: 1, height: 30, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(child: _buildDropdown(label: widget.toLabelText, value: temp?.toValue, isFrom: false, style: appliedStyle)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({required String label, required T? value, required bool isFrom, required GenericDropdownRangeStyle style}) {
    // حماية التطابق: نمرر null إذا كانت القيمة غير موجودة في اللستة حالياً
    final safeValue = widget.controller.items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style.labelStyle),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            isDense: true,
            icon: style.dropdownIcon,
            menuMaxHeight: style.menuMaxHeight,
            value: safeValue,
            hint: Text("اختر...", style: style.hintStyle),
            items: widget.controller.items.map((item) => DropdownMenuItem(
              value: item,
              child: widget.itemBuilder != null
                  ? widget.itemBuilder!(context, item)
                  : Text(widget.itemLabelBuilder!(item), style: style.textStyle, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) {
              final current = widget.controller.tempValue ?? DropdownRange<T>();
              widget.controller.updateTemp(DropdownRange<T>(
                  fromValue: isFrom ? val : current.fromValue,
                  toValue: !isFrom ? val : current.toValue
              ));
            },
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_style.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
// لا تنس استيراد GenericSearchRangeStyle

class GenericSearchRangeWidget<T> extends StatefulWidget {
  final GenericSearchRangeController<T> controller;
  final String labelText;
  final GenericSearchRangeStyle? style;
  final bool showReloadButton;

  // 🌍 نصوص الترجمة
  final String fromLabelText;
  final String toLabelText;
  final String hintText;
  final String searchHintText;
  final String noResultsText;

  // 🚀 البنائين للتحكم المطلق
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item)? selectedItemLabel;

  // مسار التحرر من النص: مررنا isFrom لتتمكن من رسم شكلين مختلفين!
  final Widget Function(BuildContext context, T selectedItem, bool isFrom)?
  customSelectedBuilder;
  final WidgetBuilder? emptyStateBuilder;
  final WidgetBuilder? loadingStateBuilder;

  const GenericSearchRangeWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.itemBuilder,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "بحث...",
    this.searchHintText = "بحث",
    this.noResultsText = "لا توجد نتائج.",
    this.showReloadButton = true,
    this.selectedItemLabel,
    this.customSelectedBuilder,
    this.emptyStateBuilder,
    this.loadingStateBuilder,
    this.style,
  }) : assert(
         selectedItemLabel != null || customSelectedBuilder != null,
         'يجب توفير selectedItemLabel أو customSelectedBuilder لعرض العنصر المختار!',
       );

  @override
  State<GenericSearchRangeWidget<T>> createState() =>
      _GenericSearchRangeWidgetState<T>();
}

class _GenericSearchRangeWidgetState<T>
    extends State<GenericSearchRangeWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🛡️ درع السيرفر: يتم جلب البيانات مرة واحدة فقط لحماية الـ API من الـ DDoS المزدوج!
    widget.controller.ensureDataLoaded();
  }

  void _openSearchSheet(
    BuildContext context, {
    required bool isFrom,
    required GenericSearchRangeStyle appliedStyle,
  }) {
    widget.controller.resetSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: appliedStyle.bottomSheetShape,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height:
              MediaQuery.of(sheetContext).size.height *
              appliedStyle.bottomSheetHeightRatio!,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsetsGeometry.only(bottom: 16),
              ),
              TextField(
                decoration: appliedStyle.searchFieldDecoration!.copyWith(
                  labelText:
                      "${widget.searchHintText} (${isFrom ? widget.fromLabelText : widget.toLabelText})...",
                ),
                onChanged: widget.controller.onSearchQueryChanged,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    if (widget.controller.isSearching) {
                      return widget.loadingStateBuilder != null
                          ? widget.loadingStateBuilder!(context)
                          : const Center(child: CircularProgressIndicator());
                    }
                    if (widget.controller.searchResults.isEmpty) {
                      return widget.emptyStateBuilder != null
                          ? widget.emptyStateBuilder!(context)
                          : Center(
                              child: Text(
                                widget.noResultsText,
                                style: appliedStyle.hintStyle,
                              ),
                            );
                    }
                    return ListView.builder(
                      itemCount: widget.controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = widget.controller.searchResults[index];
                        final isSelected = isFrom
                            ? item == widget.controller.tempValue?.fromValue
                            : item == widget.controller.tempValue?.toValue;
                        return InkWell(
                          onTap: () {
                            final current =
                                widget.controller.tempValue ??
                                DropdownRange<T>();
                            widget.controller.updateTemp(
                              DropdownRange<T>(
                                fromValue: isFrom ? item : current.fromValue,
                                toValue: !isFrom ? item : current.toValue,
                              ),
                            );
                            Navigator.pop(sheetContext);
                          },
                          child: widget.itemBuilder(item, isSelected),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (widget.style ?? const GenericSearchRangeStyle())
        .mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!())
          return const SizedBox.shrink();

        final temp = widget.controller.tempValue;

        Widget? smartSuffixIcon;
        if (widget.controller.isLoading) {
          smartSuffixIcon = const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (widget.controller.errorMessage != null &&
            widget.showReloadButton) {
          smartSuffixIcon = IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.error),
            onPressed: () => widget.controller.refreshData(forceReload: true),
            splashRadius: 20,
          );
        } else if (temp?.fromValue != null || temp?.toValue != null) {
          smartSuffixIcon = IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: () => widget.controller.clear(),
            splashRadius: 20,
          );
        }

        return Padding(
          padding: appliedStyle.padding!,
          child: InputDecorator(
            decoration: appliedStyle.decoration!.copyWith(
              labelText: widget.labelText,
              errorText:
                  widget.controller.errorMessage ??
                  widget.controller.validationError,
              suffixIcon: smartSuffixIcon,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchButton(
                    context,
                    label: widget.fromLabelText,
                    value: temp?.fromValue,
                    isFrom: true,
                    style: appliedStyle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildSearchButton(
                    context,
                    label: widget.toLabelText,
                    value: temp?.toValue,
                    isFrom: false,
                    style: appliedStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(
    BuildContext context, {
    required String label,
    required T? value,
    required bool isFrom,
    required GenericSearchRangeStyle style,
  }) {
    return InkWell(
      onTap: () =>
          _openSearchSheet(context, isFrom: isFrom, appliedStyle: style),
      borderRadius: BorderRadius.circular(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style.labelStyle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: value != null
                    ? (widget.customSelectedBuilder != null
                          ? widget.customSelectedBuilder!(
                              context,
                              value,
                              isFrom,
                            )
                          : Text(
                              widget.selectedItemLabel!(value),
                              style: style.textStyle,
                              overflow: TextOverflow.ellipsis,
                            ))
                    : Text(
                        widget.hintText,
                        style: style.hintStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              style.trailingIcon ?? const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

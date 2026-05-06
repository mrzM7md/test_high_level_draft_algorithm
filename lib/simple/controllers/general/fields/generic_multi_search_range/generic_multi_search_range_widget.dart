import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range/generic_multi_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range/generic_multi_search_range_style.dart';
// لا تنس استيراد GenericMultiSearchRangeStyle

class GenericMultiSearchRangeWidget<T> extends StatefulWidget {
  final GenericMultiSearchRangeController<T> controller;
  final String labelText;
  final GenericMultiSearchRangeStyle? style;
  final bool showReloadButton;

  // 🌍 نصوص الترجمة والديناميكية
  final String fromLabelText;
  final String toLabelText;
  final String hintText;
  final String searchHintText;
  final String noResultsText;
  final String closeText;
  final String confirmText;
  final String selectedText;

  // 🚀 البنائين للتحكم المطلق في التصميم
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item)? selectedItemLabel;

  // 🚀 تمرير `isFrom` للبنّاء ليتمكن المبرمج من تصميم شكل مختلف لـ "من" و "إلى" إذا أراد
  final Widget Function(
    BuildContext context,
    T item,
    bool isFrom,
    VoidCallback onDeleted,
  )?
  customChipBuilder;
  final WidgetBuilder? emptyStateBuilder;
  final WidgetBuilder? loadingStateBuilder;

  const GenericMultiSearchRangeWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.itemBuilder,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "اختر...",
    this.searchHintText = "بحث",
    this.noResultsText = "لا توجد نتائج.",
    this.closeText = "إغلاق",
    this.confirmText = "موافق",
    this.selectedText = "مختار",
    this.showReloadButton = true,
    this.selectedItemLabel,
    this.customChipBuilder,
    this.emptyStateBuilder,
    this.loadingStateBuilder,
    this.style,
  }) : assert(
         selectedItemLabel != null || customChipBuilder != null,
         'يجب توفير selectedItemLabel أو customChipBuilder لرسم الـ Chips!',
       );

  @override
  State<GenericMultiSearchRangeWidget<T>> createState() =>
      _GenericMultiSearchRangeWidgetState<T>();
}

class _GenericMultiSearchRangeWidgetState<T>
    extends State<GenericMultiSearchRangeWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🛡️ نقلنا التحميل لهنا لإنقاذ السيرفرات من الـ DDoS!
    widget.controller.ensureDataLoaded();
  }

  void _openSearchSheet(
    BuildContext context, {
    required bool isFrom,
    required GenericMultiSearchRangeStyle appliedStyle,
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
                    final currentList = isFrom
                        ? (widget.controller.tempValue?.fromValue ?? [])
                        : (widget.controller.tempValue?.toValue ?? []);
                    return ListView.builder(
                      itemCount: widget.controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = widget.controller.searchResults[index];
                        final isSelected = currentList.contains(item);
                        return InkWell(
                          onTap: () => widget.controller.toggleItem(
                            item,
                            isFrom: isFrom,
                          ),
                          child: widget.itemBuilder(item, isSelected),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      final count = isFrom
                          ? (widget.controller.tempValue?.fromValue?.length ??
                                0)
                          : (widget.controller.tempValue?.toValue?.length ?? 0);
                      return Text(
                        count > 0
                            ? "${widget.confirmText} ($count)"
                            : widget.closeText,
                      );
                    },
                  ),
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
    final appliedStyle = (widget.style ?? const GenericMultiSearchRangeStyle())
        .mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!())
          return const SizedBox.shrink();

        final fromList = widget.controller.tempValue?.fromValue ?? [];
        final toList = widget.controller.tempValue?.toValue ?? [];
        final hasAnyItems = fromList.isNotEmpty || toList.isNotEmpty;

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
        } else if (hasAnyItems) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
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
                        count: fromList.length,
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
                        count: toList.length,
                        isFrom: false,
                        style: appliedStyle,
                      ),
                    ),
                  ],
                ),
              ),
              if (fromList.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  "${widget.selectedText} (${widget.fromLabelText}):",
                  style: appliedStyle.fromChipTextStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: fromList
                      .map(
                        (item) =>
                            _buildChip(item, isFrom: true, style: appliedStyle),
                      )
                      .toList(),
                ),
              ],
              if (toList.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  "${widget.selectedText} (${widget.toLabelText}):",
                  style: appliedStyle.toChipTextStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: toList
                      .map(
                        (item) => _buildChip(
                          item,
                          isFrom: false,
                          style: appliedStyle,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(
    BuildContext context, {
    required String label,
    required int count,
    required bool isFrom,
    required GenericMultiSearchRangeStyle style,
  }) {
    return InkWell(
      onTap: () =>
          _openSearchSheet(context, isFrom: isFrom, appliedStyle: style),
      borderRadius: BorderRadius.circular(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style.hintStyle?.copyWith(fontSize: 11)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  count > 0
                      ? "${widget.selectedText} ($count)"
                      : widget.hintText,
                  style: count > 0
                      ? style.textStyle?.copyWith(fontWeight: FontWeight.bold)
                      : style.hintStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.search_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    T item, {
    required bool isFrom,
    required GenericMultiSearchRangeStyle style,
  }) {
    if (widget.customChipBuilder != null) {
      return widget.customChipBuilder!(
        context,
        item,
        isFrom,
        () => widget.controller.removeItem(item, isFrom: isFrom),
      );
    }
    return Chip(
      label: Text(
        widget.selectedItemLabel!(item),
        style: isFrom ? style.fromChipTextStyle : style.toChipTextStyle,
      ),
      deleteIcon: Icon(
        Icons.cancel_rounded,
        size: 18,
        color: style.chipDeleteIconColor,
      ),
      onDeleted: () => widget.controller.removeItem(item, isFrom: isFrom),
      backgroundColor: isFrom
          ? style.fromChipBackgroundColor
          : style.toChipBackgroundColor,
      shape: style.chipShape,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

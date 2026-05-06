import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_style.dart';
// لا تنس استيراد GenericSearchStyle

class GenericSearchWidget<T> extends StatefulWidget {
  final GenericSearchController<T> controller;
  final String labelText;
  final String hintText;
  final GenericSearchStyle? style;
  final bool showReloadButton;

  // 🌍 نصوص الترجمة والديناميكية
  final String searchHintText;
  final String noResultsText;

  // 🚀 البنائين الديناميكية
  final Widget Function(T item, bool isSelected) itemBuilder; // لصفحة البحث
  final String Function(T item)? selectedItemLabel; // النص العادي المختار

  // 🚀 التحرر المطلق: ارسم ما تشاء للعنصر المختار (صورة، بطاقة، إلخ)
  final Widget Function(BuildContext context, T selectedItem)?
  customSelectedBuilder;
  final WidgetBuilder? emptyStateBuilder;
  final WidgetBuilder? loadingStateBuilder;

  const GenericSearchWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.itemBuilder,
    this.hintText = "اختر...",
    this.searchHintText = "بحث...",
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
  State<GenericSearchWidget<T>> createState() => _GenericSearchWidgetState<T>();
}

class _GenericSearchWidgetState<T> extends State<GenericSearchWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🛡️ درع السيرفر: يتم طلب البيانات الأولية مرة واحدة فقط عند التهيئة!
    widget.controller.ensureDataLoaded();
  }

  void _openSearchSheet(BuildContext context, GenericSearchStyle appliedStyle) {
    widget.controller.resetSearchState();
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
                  labelText: widget.searchHintText,
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
                        final isSelected = item == widget.controller.tempValue;
                        return InkWell(
                          onTap: () {
                            widget.controller.updateTemp(item);
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
    final appliedStyle = (widget.style ?? const GenericSearchStyle())
        .mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!())
          return const SizedBox.shrink();

        final temp = widget.controller.tempValue;

        // ذكاء الأيقونات
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
        } else if (temp != null) {
          smartSuffixIcon = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed: () => widget.controller.clear(),
                splashRadius: 20,
              ),
            ],
          );
        } else {
          smartSuffixIcon = appliedStyle.trailingIcon;
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
            child: InkWell(
              onTap: () => _openSearchSheet(context, appliedStyle),
              borderRadius: BorderRadius.circular(4),
              child: temp != null
                  // 🚀 الهروب من سجن النصوص!
                  ? (widget.customSelectedBuilder != null
                        ? widget.customSelectedBuilder!(context, temp)
                        : Text(
                            widget.selectedItemLabel!(temp),
                            style: appliedStyle.textStyle,
                          ))
                  : Text(widget.hintText, style: appliedStyle.hintStyle),
            ),
          ),
        );
      },
    );
  }
}

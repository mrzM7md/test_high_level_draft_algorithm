import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_offline_search/generic_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_offline_search/generic_offline_search_style.dart';

class GenericOfflineSearchWidget<T> extends StatefulWidget {
  final GenericOfflineSearchController<T> controller;
  final String labelText;
  final String hintText;
  final GenericOfflineSearchStyle? style;
  final bool showReloadButton;

  // 🌍 نصوص الترجمة
  final String searchHintText;
  final String noResultsText;

  // 🚀 البنائين الديناميكية
  final Widget Function(T item, bool isSelected) itemBuilder; // عناصر القائمة
  final String Function(T item)? selectedItemLabel; // النص الافتراضي للمختار

  // 🚀 التحرر المطلق: ارسم ما تشاء عندما يتم اختيار العنصر (صورة، بطاقة، إلخ)
  final Widget Function(BuildContext context, T selectedItem)?
  customSelectedBuilder;
  final WidgetBuilder? emptyStateBuilder;

  const GenericOfflineSearchWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.itemBuilder,
    this.hintText = "اختر...",
    this.searchHintText = "بحث سريع...",
    this.noResultsText = "لا توجد نتائج.",
    this.showReloadButton = true,
    this.selectedItemLabel,
    this.customSelectedBuilder,
    this.emptyStateBuilder,
    this.style,
  }) : assert(
         selectedItemLabel != null || customSelectedBuilder != null,
         'يجب توفير selectedItemLabel أو customSelectedBuilder لعرض العنصر المختار!',
       );

  @override
  State<GenericOfflineSearchWidget<T>> createState() =>
      _GenericOfflineSearchWidgetState<T>();
}

class _GenericOfflineSearchWidgetState<T>
    extends State<GenericOfflineSearchWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🛡️ حماية الـ Event Loop: جلب لمرة واحدة
    widget.controller.ensureDataLoaded();
  }

  void _openSearchSheet(
    BuildContext context,
    GenericOfflineSearchStyle appliedStyle,
  ) {
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
    final appliedStyle = (widget.style ?? const GenericOfflineSearchStyle())
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
                  // 🚀 التحرر من سجن النص: استخدام البنّاء إذا وُجد
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

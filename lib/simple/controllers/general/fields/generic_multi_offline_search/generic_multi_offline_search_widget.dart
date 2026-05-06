import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_offline_search/generic_multi_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_offline_search/generic_multi_search_style.dart';

// ==========================================
// 2. الواجهة الخارقة (The Empowered Widget)
// ==========================================
class GenericMultiOfflineSearchWidget<T> extends StatefulWidget {
  final GenericMultiOfflineSearchController<T> controller;
  final String labelText;
  final String hintText;
  final GenericMultiSearchStyle? style;
  final bool showReloadButton;

  // 🌍 نصوص الترجمة (لمنع Hardcoded Strings)
  final String searchHintText;
  final String noResultsText;
  final String closeText;
  final String confirmText;
  final String itemsSelectedText;

  // 🚀 البنّاء الخارق للعناصر في الـ BottomSheet
  final Widget Function(T item, bool isSelected) itemBuilder;

  // 🚀 مسار النص العادي للـ Chip
  final String Function(T item)? selectedItemLabel;

  // 🚀 مسار البنّاء الخارق للـ Chip (يسمح برسم صور وبطاقات!)
  final Widget Function(BuildContext context, T item, VoidCallback onDeleted)?
  customChipBuilder;

  // 🚀 واجهات مخصصة للتحكم المطلق في الحالات الفارغة والتحميل
  final WidgetBuilder? emptyStateBuilder;
  final WidgetBuilder? loadingStateBuilder;

  const GenericMultiOfflineSearchWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.itemBuilder,
    this.hintText = "ابحث واختر...",
    this.searchHintText = "بحث سريع...",
    this.noResultsText = "لا توجد نتائج.",
    this.closeText = "إغلاق",
    this.confirmText = "موافق",
    this.itemsSelectedText = "عناصر مختارة",
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
  State<GenericMultiOfflineSearchWidget<T>> createState() =>
      _GenericMultiOfflineSearchWidgetState<T>();
}

class _GenericMultiOfflineSearchWidgetState<T>
    extends State<GenericMultiOfflineSearchWidget<T>> {
  @override
  void initState() {
    super.initState();
    // 🛡️ حماية الـ Event Loop: جلب البيانات يتم مرة واحدة فقط!
    widget.controller.ensureDataLoaded();
  }

  void _openSearchSheet(
    BuildContext context,
    GenericMultiSearchStyle appliedStyle,
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
          // دعم تلقائي لارتفاع الكيبورد لمنع تغطية المحتوى
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height:
              MediaQuery.of(sheetContext).size.height *
              appliedStyle.bottomSheetHeightRatio!,
          child: Column(
            children: [
              // 🚀 شريط السحب العلوي (Drag Indicator)
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
                    // 1. حالة التحميل الديناميكية
                    if (widget.controller.isSearching) {
                      return widget.loadingStateBuilder != null
                          ? widget.loadingStateBuilder!(context)
                          : const Center(child: CircularProgressIndicator());
                    }

                    // 2. حالة عدم وجود نتائج (ديناميكية)
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

                    // 3. حالة عرض البيانات (بناء مطلق)
                    return ListView.builder(
                      itemCount: widget.controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = widget.controller.searchResults[index];
                        final isSelected =
                            widget.controller.tempValue?.contains(item) ??
                            false;
                        return InkWell(
                          onTap: () => widget.controller.toggleItem(item),
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
                      final count = widget.controller.tempValue?.length ?? 0;
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
    final appliedStyle = (widget.style ?? const GenericMultiSearchStyle())
        .mergeWithDefault(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!()) {
          return const SizedBox.shrink();
        }
        final selectedItems = widget.controller.tempValue ?? [];
        final hasItems = selectedItems.isNotEmpty;

        // 🧠 ذكاء الأيقونات التلقائي
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
        } else if (hasItems) {
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
                child: InkWell(
                  onTap: () => _openSearchSheet(context, appliedStyle),
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    hasItems
                        ? "(${selectedItems.length}) ${widget.itemsSelectedText}"
                        : widget.hintText,
                    style: hasItems
                        ? appliedStyle.textStyle?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : appliedStyle.hintStyle,
                  ),
                ),
              ),
              if (hasItems)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: selectedItems.map((item) {
                      // 🚀 هل نستخدم البنّاء الخارق للـ Chips أم الافتراضي؟
                      if (widget.customChipBuilder != null) {
                        return widget.customChipBuilder!(
                          context,
                          item,
                          () => widget.controller.removeItem(item),
                        );
                      }
                      return Chip(
                        label: Text(
                          widget.selectedItemLabel!(item),
                          style: appliedStyle.chipTextStyle,
                        ),
                        deleteIcon: Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: appliedStyle.chipDeleteIconColor,
                        ),
                        onDeleted: () => widget.controller.removeItem(item),
                        backgroundColor: appliedStyle.chipBackgroundColor,
                        shape: appliedStyle.chipShape,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

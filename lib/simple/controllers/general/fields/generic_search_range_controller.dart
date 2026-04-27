import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';
import '../../base/base_filter_controller.dart';
import '../models/dropdown_range.dart';

class GenericSearchRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String hintText;

  final Future<List<T>> Function() initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;
  final String Function(T item) selectedItemLabel;
  final Widget Function(T item, bool isSelected) itemBuilder;

  List<T> _items = [];
  List<T> searchResults = [];
  bool _isLoading = false;
  bool isSearching = false;
  String? errorMessage; // 🔥 متغير الخطأ
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericSearchRangeController({
    required this.labelText,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "بحث...",
    required this.initialFetchFunction,
    required this.searchFunction,
    required this.selectedItemLabel,
    required this.itemBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) {
      searchResults = List.from(_items);
      isSearching = false;
      notifyListeners();
      return;
    }

    _debouncer.run(() async {
      isSearching = true;
      notifyListeners();
      try {
        searchResults = await searchFunction(query);
      } catch (e) {
        searchResults = [];
      } finally {
        isSearching = false;
        notifyListeners();
      }
    });
  }

  @override
  void onParentValueChanged() {
    _items = [];
    searchResults = [];
    tempValue = null;
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    errorMessage = null; // 🔥 تصفير الخطأ عند المحاولة مرة أخرى
    notifyListeners();

    try {
      final newData = await initialFetchFunction();

      DropdownRange<T>? syncRange(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue;
        T? t = currentRange.toValue;

        if (f != null) {
          if (!newData.contains(f)) {
            newData.insert(0, f);
          } else {
            f = newData.firstWhere((e) => e == f);
          }
        }
        if (t != null) {
          if (!newData.contains(t)) {
            newData.insert(0, t);
          } else {
            t = newData.firstWhere((e) => e == t);
          }
        }
        return DropdownRange<T>(fromValue: f, toValue: t);
      }

      if (tempValue != null) tempValue = syncRange(tempValue);
      if (appliedValue != null) appliedValue = syncRange(appliedValue);

      _items = newData;
      searchResults = List.from(_items);

    } on FilterFetchException catch (e) {
      errorMessage = e.message; // 🔥 التقاط خطأ السيرفر
    } catch (e) {
      errorMessage = "فشل تحميل البيانات، تأكد من الاتصال.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureDataLoaded() async {
    // 🔥 إيقاف الحلقة اللانهائية إذا فشل الجلب
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData();
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: errorMessage ?? validationError, // 🔥 دمج الأخطاء
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData()),
                  if (tempValue?.fromValue != null || tempValue?.toValue != null)
                    IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildSearchButton(context, label: fromLabelText, value: tempValue?.fromValue, isFrom: true)),
                const SizedBox(width: 8),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Expanded(child: _buildSearchButton(context, label: toLabelText, value: tempValue?.toValue, isFrom: false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, {required String label, required T? value, required bool isFrom}) {
    return InkWell(
      onTap: () {
        ensureDataLoaded();
        _openSearchSheet(context, isFrom: isFrom);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null ? selectedItemLabel(value) : hintText,
                    style: TextStyle(fontWeight: value != null ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: value != null ? Colors.black : Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, size: 16, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSearchSheet(BuildContext context, {required bool isFrom}) {
    searchResults = List.from(_items);
    isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: "بحث (${isFrom ? fromLabelText : toLabelText})...", prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()),
                onChanged: onSearchQueryChanged,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: this,
                  builder: (context, _) {
                    if (isSearching) return const Center(child: CircularProgressIndicator());
                    if (searchResults.isEmpty) return const Center(child: Text("لا توجد نتائج."));

                    return ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        final isSelected = isFrom ? item == tempValue?.fromValue : item == tempValue?.toValue;

                        return InkWell(
                          onTap: () {
                            final current = tempValue ?? DropdownRange<T>();
                            updateTemp(DropdownRange<T>(
                              fromValue: isFrom ? item : current.fromValue,
                              toValue: !isFrom ? item : current.toValue,
                            ));
                            Navigator.pop(sheetContext);
                          },
                          child: itemBuilder(item, isSelected),
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
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
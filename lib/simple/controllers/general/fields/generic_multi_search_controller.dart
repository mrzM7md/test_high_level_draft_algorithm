// --- generic_multi_search_controller.dart ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericMultiSearchController<T> extends BaseFilterController<List<T>> {
  final String labelText;
  final String hintText;
  final Future<List<T>> Function() initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item) selectedItemLabel;

  List<T> _items = [];
  List<T> searchResults = [];
  bool _isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericMultiSearchController({
    required this.labelText,
    this.hintText = "ابحث واختر...",
    required this.initialFetchFunction,
    required this.searchFunction,
    required this.itemBuilder,
    required this.selectedItemLabel,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton, // 🔥 تمرير الخاصية
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) {
      validationError = null;
      return true;
    }
    if (isRequired && (tempValue == null || tempValue!.isEmpty)) {
      validationError = "هذا الحقل مطلوب ولا يمكن تركه فارغاً";
      notifyListeners();
      return false;
    }
    validationError = null;
    notifyListeners();
    return true;
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData();
  }

  @override
  void onParentValueChanged() {
    _items = [];
    searchResults = [];
    tempValue = [];
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newData = await initialFetchFunction();

      List<T>? syncList(List<T>? currentList) {
        if (currentList == null || currentList.isEmpty) return [];
        List<T> synced = [];
        for (var item in currentList) {
          if (newData.contains(item)) {
            synced.add(newData.firstWhere((e) => e == item));
          } else {
            synced.add(item);
            if (!_items.contains(item)) newData.insert(0, item);
          }
        }
        return synced;
      }

      tempValue = syncList(tempValue);
      appliedValue = syncList(appliedValue);

      _items = newData;
      searchResults = List.from(_items);
    } on FilterFetchException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "فشل تحميل البيانات، تأكد من الاتصال.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void toggleItem(T item) {
    final currentList = List<T>.from(tempValue ?? []);
    if (currentList.contains(item)) {
      currentList.remove(item);
    } else {
      currentList.add(item);
    }
    updateTemp(currentList.isEmpty ? null : currentList);
  }

  void removeItem(T item) {
    final currentList = List<T>.from(tempValue ?? []);
    currentList.remove(item);
    updateTemp(currentList.isEmpty ? null : currentList);
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        final hasItems = tempValue != null && tempValue!.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  border: const OutlineInputBorder(),
                  errorText: errorMessage ?? validationError,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),

                      if (showReloadButton) // 🔥 شرط ظهور الزر
                        IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData()),

                      if (hasItems)
                        IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                    ],
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    ensureDataLoaded();
                    _openSearchSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      hasItems ? "تم اختيار (${tempValue!.length}) عناصر" : hintText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: hasItems ? FontWeight.bold : FontWeight.normal,
                        color: hasItems ? Colors.blue.shade700 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),

              if (hasItems)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: tempValue!.map((item) => Chip(
                      label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.cancel, size: 16),
                      onDeleted: () => removeItem(item),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide(color: Colors.blue.shade200),
                    )).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    searchResults = List.from(_items);
    isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "بحث...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                        final isSelected = tempValue?.contains(item) ?? false;

                        return InkWell(
                          onTap: () => toggleItem(item),
                          child: itemBuilder(item, isSelected),
                        );
                      },
                    );
                  },
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: ListenableBuilder(
                      listenable: this,
                      builder: (context, _) {
                        final count = tempValue?.length ?? 0;
                        return Text(count > 0 ? "موافق ($count)" : "إغلاق");
                      }
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
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
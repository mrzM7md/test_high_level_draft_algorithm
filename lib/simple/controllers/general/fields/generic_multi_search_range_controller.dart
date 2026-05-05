import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';
import '../../base/base_filter_controller.dart';
import '../models/dropdown_range.dart';

class GenericMultiSearchRangeController<T> extends BaseFilterController<DropdownRange<List<T>>> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String hintText;

  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;
  final String Function(T item) selectedItemLabel;
  final Widget Function(T item, bool isSelected) itemBuilder;

  List<T> _items = [];
  List<T> searchResults = [];
  bool _isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericMultiSearchRangeController({
    required this.labelText,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "اختر...",
    required this.initialFetchFunction,
    required this.searchFunction,
    required this.selectedItemLabel,
    required this.itemBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) {
      validationError = null;
      return true;
    }
    final fromList = tempValue?.fromValue ?? [];
    final toList = tempValue?.toValue ?? [];

    if (isRequired && fromList.isEmpty && toList.isEmpty) {
      validationError = "يجب اختيار عنصر واحد على الأقل";
      notifyListeners();
      return false;
    }
    validationError = null;
    notifyListeners();
    return true;
  }

  @override
  void onParentValueChanged() {
    _items = [];
    searchResults = [];
    tempValue = DropdownRange<List<T>>(fromValue: [], toValue: []);
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData(forceReload: false); // 2. 🔥 التحديث التلقائي يستفيد من الكاش
    }
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newData = await initialFetchFunction(forceReload: forceReload);

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

      if (tempValue != null) {
        tempValue = DropdownRange<List<T>>(
          fromValue: syncList(tempValue!.fromValue),
          toValue: syncList(tempValue!.toValue),
        );
      }
      if (appliedValue != null) {
        appliedValue = DropdownRange<List<T>>(
          fromValue: syncList(appliedValue!.fromValue),
          toValue: syncList(appliedValue!.toValue),
        );
      }

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

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData(forceReload: false);
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

  void toggleItem(T item, {required bool isFrom}) {
    final currentRange = tempValue ?? DropdownRange<List<T>>(fromValue: [], toValue: []);
    List<T> list = List.from(isFrom ? (currentRange.fromValue ?? []) : (currentRange.toValue ?? []));

    if (list.contains(item)) list.remove(item);
    else list.add(item);

    updateTemp(DropdownRange<List<T>>(
      fromValue: isFrom ? list : currentRange.fromValue,
      toValue: !isFrom ? list : currentRange.toValue,
    ));
  }

  void removeItem(T item, {required bool isFrom}) {
    final currentRange = tempValue ?? DropdownRange<List<T>>(fromValue: [], toValue: []);
    List<T> list = List.from(isFrom ? (currentRange.fromValue ?? []) : (currentRange.toValue ?? []));
    list.remove(item);

    updateTemp(DropdownRange<List<T>>(
      fromValue: isFrom ? list : currentRange.fromValue,
      toValue: !isFrom ? list : currentRange.toValue,
    ));
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        final fromList = tempValue?.fromValue ?? [];
        final toList = tempValue?.toValue ?? [];
        final hasAnyItems = fromList.isNotEmpty || toList.isNotEmpty;

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

                      if (showReloadButton)
                      // 5. 🔥 تفعيل الإجبار عند التحديث اليدوي
                        IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData(forceReload: true)),

                      if (hasAnyItems)
                        IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchButton(context, label: fromLabelText, count: fromList.length, isFrom: true)),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSearchButton(context, label: toLabelText, count: toList.length, isFrom: false)),
                  ],
                ),
              ),

              if (fromList.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("المختارة في ($fromLabelText):", style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6.0, runSpacing: 4.0,
                  children: fromList.map((item) => Chip(
                    label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.cancel, size: 16),
                    onDeleted: () => removeItem(item, isFrom: true),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                  )).toList(),
                ),
              ],

              if (toList.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("المختارة في ($toLabelText):", style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6.0, runSpacing: 4.0,
                  children: toList.map((item) => Chip(
                    label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.cancel, size: 16),
                    onDeleted: () => removeItem(item, isFrom: false),
                    backgroundColor: Colors.green.shade50,
                    side: BorderSide(color: Colors.green.shade200),
                  )).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, {required String label, required int count, required bool isFrom}) {
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
                    count > 0 ? "مختار ($count)" : hintText,
                    style: TextStyle(fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: count > 0 ? Colors.black : Colors.grey.shade600),
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
          height: MediaQuery.of(sheetContext).size.height * 0.75,
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

                    final currentList = isFrom ? (tempValue?.fromValue ?? []) : (tempValue?.toValue ?? []);

                    return ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        final isSelected = currentList.contains(item);

                        return InkWell(
                          onTap: () => toggleItem(item, isFrom: isFrom),
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
                        final count = isFrom ? (tempValue?.fromValue?.length ?? 0) : (tempValue?.toValue?.length ?? 0);
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
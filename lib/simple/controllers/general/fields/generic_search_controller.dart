import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart'; // تأكد من المسار
import '../../base/base_data_filter_controller.dart';

class GenericSearchController<T> extends BaseDataFilterController<T> {
  final String labelText;
  final String hintText;
  // 1. 🔥 تعديل الجلب المبدئي فقط
  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item) selectedItemLabel;

  List<T> searchResults = [];
  bool isSearching = false;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericSearchController({
    required this.labelText,
    required this.hintText,
    required this.initialFetchFunction,
    required this.searchFunction,
    required this.itemBuilder,
    required this.selectedItemLabel,
    super.defaultSelectionBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton,
  });

  // 2. 🔥 التمرير
  @override
  Future<List<T>> fetchDataFromServer({bool forceReload = false}) => initialFetchFunction(forceReload: forceReload);

  @override
  void onParentValueChanged() {
    searchResults = [];
    super.onParentValueChanged();
  }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) {
      searchResults = List.from(items);
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
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded().then((_) {
      if (searchResults.isEmpty && items.isNotEmpty) {
        searchResults = List.from(items);
        notifyListeners();
      }
    });

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: errorMessage ?? validationError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (showReloadButton)
                  // 3. 🔥 الإجبار
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData(forceReload: true)),
                  if (tempValue != null) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
            child: InkWell(
              onTap: () {
                ensureDataLoaded();
                _openSearchSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  tempValue != null ? selectedItemLabel(tempValue as T) : hintText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: tempValue != null ? FontWeight.bold : FontWeight.normal,
                    color: tempValue != null ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    if (searchResults.isEmpty && items.isNotEmpty) searchResults = List.from(items);

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
                        final isSelected = item == tempValue;
                        return InkWell(
                          onTap: () {
                            updateTemp(item);
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
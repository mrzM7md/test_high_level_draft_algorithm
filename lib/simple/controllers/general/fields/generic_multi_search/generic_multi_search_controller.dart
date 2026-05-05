import 'package:flutter/cupertino.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericMultiSearchController<T> extends BaseFilterController<List<T>> {
  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;

  List<T> _items = [];
  List<T> get items => _items;
  List<T> searchResults = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool isSearching = false;
  String? errorMessage;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericMultiSearchController({
    required this.initialFetchFunction, required this.searchFunction,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }
    if (isRequired && (tempValue == null || tempValue!.isEmpty)) { validationError = "هذا الحقل مطلوب"; notifyListeners(); return false; }
    validationError = null; notifyListeners(); return true;
  }

  Future<void> ensureDataLoaded() async { if (_items.isNotEmpty || _isLoading || errorMessage != null) return; await refreshData(); }

  @override
  void onParentValueChanged() {
    _items = []; searchResults = []; tempValue = []; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final newData = await initialFetchFunction(forceReload: forceReload);
      List<T>? syncList(List<T>? currentList) {
        if (currentList == null || currentList.isEmpty) return [];
        List<T> synced = [];
        for (var item in currentList) { if (newData.contains(item)) synced.add(newData.firstWhere((e) => e == item)); else { synced.add(item); if (!_items.contains(item)) newData.insert(0, item); } }
        return synced;
      }
      tempValue = syncList(tempValue); appliedValue = syncList(appliedValue);
      _items = newData; searchResults = List.from(_items);
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل التحميل."; } finally { _isLoading = false; notifyListeners(); }
  }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) { searchResults = List.from(_items); isSearching = false; notifyListeners(); return; }
    _debouncer.run(() async {
      isSearching = true; notifyListeners();
      try { searchResults = await searchFunction(query); } catch (e) { searchResults = []; } finally { isSearching = false; notifyListeners(); }
    });
  }

  void resetSearch() { searchResults = List.from(_items); isSearching = false; notifyListeners(); }
  void toggleItem(T item) { final currentList = List<T>.from(tempValue ?? []); if (currentList.contains(item)) currentList.remove(item); else currentList.add(item); updateTemp(currentList.isEmpty ? null : currentList); }
  void removeItem(T item) { final currentList = List<T>.from(tempValue ?? []); currentList.remove(item); updateTemp(currentList.isEmpty ? null : currentList); }
  @override void dispose() { _debouncer.cancel(); super.dispose(); }
}

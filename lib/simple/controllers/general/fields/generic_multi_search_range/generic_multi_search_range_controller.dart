import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericMultiSearchRangeController<T> extends BaseFilterController<DropdownRange<List<T>>> {

  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;

  List<T> _items = [];
  List<T> get items => _items;

  List<T> searchResults = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading; // 👈 🔥 حل المشكلة

  bool isSearching = false;
  String? errorMessage;

  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericMultiSearchRangeController({
    required this.initialFetchFunction,
    required this.searchFunction,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }
    final fromList = tempValue?.fromValue ?? []; final toList = tempValue?.toValue ?? [];
    if (isRequired && fromList.isEmpty && toList.isEmpty) { validationError = "يجب اختيار عنصر واحد على الأقل"; notifyListeners(); return false; }
    validationError = null; notifyListeners(); return true;
  }

  @override
  void onParentValueChanged() {
    _items = []; searchResults = []; tempValue = DropdownRange<List<T>>(fromValue: [], toValue: []); super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final newData = await initialFetchFunction(forceReload: forceReload);
      List<T>? syncList(List<T>? currentList) {
        if (currentList == null || currentList.isEmpty) return [];
        List<T> synced = [];
        for (var item in currentList) {
          if (newData.contains(item)) synced.add(newData.firstWhere((e) => e == item));
          else { synced.add(item); if (!_items.contains(item)) newData.insert(0, item); }
        }
        return synced;
      }
      if (tempValue != null) tempValue = DropdownRange<List<T>>(fromValue: syncList(tempValue!.fromValue), toValue: syncList(tempValue!.toValue));
      if (appliedValue != null) appliedValue = DropdownRange<List<T>>(fromValue: syncList(appliedValue!.fromValue), toValue: syncList(appliedValue!.toValue));
      _items = newData; searchResults = List.from(_items);
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل التحميل."; } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> ensureDataLoaded() async { if (_items.isNotEmpty || _isLoading || errorMessage != null) return; await refreshData(forceReload: false); }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) { searchResults = List.from(_items); isSearching = false; notifyListeners(); return; }
    _debouncer.run(() async {
      isSearching = true; notifyListeners();
      try { searchResults = await searchFunction(query); } catch (e) { searchResults = []; } finally { isSearching = false; notifyListeners(); }
    });
  }

  void resetSearch() { searchResults = List.from(_items); isSearching = false; notifyListeners(); }

  void toggleItem(T item, {required bool isFrom}) {
    final currentRange = tempValue ?? DropdownRange<List<T>>(fromValue: [], toValue: []);
    List<T> list = List.from(isFrom ? (currentRange.fromValue ?? []) : (currentRange.toValue ?? []));
    if (list.contains(item)) list.remove(item); else list.add(item);
    updateTemp(DropdownRange<List<T>>(fromValue: isFrom ? list : currentRange.fromValue, toValue: !isFrom ? list : currentRange.toValue));
  }

  void removeItem(T item, {required bool isFrom}) {
    final currentRange = tempValue ?? DropdownRange<List<T>>(fromValue: [], toValue: []);
    List<T> list = List.from(isFrom ? (currentRange.fromValue ?? []) : (currentRange.toValue ?? []));
    list.remove(item);
    updateTemp(DropdownRange<List<T>>(fromValue: isFrom ? list : currentRange.fromValue, toValue: !isFrom ? list : currentRange.toValue));
  }

  @override void dispose() { _debouncer.cancel(); super.dispose(); }
}
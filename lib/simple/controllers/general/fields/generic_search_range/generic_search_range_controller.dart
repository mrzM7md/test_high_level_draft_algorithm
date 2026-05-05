// --- 1. THE CONTROLLER (Search Range Example) ---
import 'package:flutter/cupertino.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericSearchRangeController<T> extends BaseFilterController<DropdownRange<T>> {
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

  GenericSearchRangeController({
    required this.initialFetchFunction, required this.searchFunction,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) { searchResults = List.from(_items); isSearching = false; notifyListeners(); return; }
    _debouncer.run(() async {
      isSearching = true; notifyListeners();
      try { searchResults = await searchFunction(query); } catch (e) { searchResults = []; } finally { isSearching = false; notifyListeners(); }
    });
  }
  
  void resetSearch() { searchResults = List.from(_items); isSearching = false; notifyListeners(); }

  @override
  void onParentValueChanged() {
    _items = []; searchResults = []; tempValue = null; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final newData = await initialFetchFunction(forceReload: forceReload);
      DropdownRange<T>? syncRange(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue; T? t = currentRange.toValue;
        if (f != null) { if (!newData.contains(f)) newData.insert(0, f); else f = newData.firstWhere((e) => e == f); }
        if (t != null) { if (!newData.contains(t)) newData.insert(0, t); else t = newData.firstWhere((e) => e == t); }
        return DropdownRange<T>(fromValue: f, toValue: t);
      }
      if (tempValue != null) tempValue = syncRange(tempValue);
      if (appliedValue != null) appliedValue = syncRange(appliedValue);
      _items = newData; searchResults = List.from(_items);
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل التحميل."; } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> ensureDataLoaded() async { if (_items.isNotEmpty || _isLoading || errorMessage != null) return; await refreshData(forceReload: false); }
  @override void dispose() { _debouncer.cancel(); super.dispose(); }
}

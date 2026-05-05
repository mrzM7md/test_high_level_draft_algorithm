import 'package:flutter/cupertino.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';


class GenericDropdownRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final Future<List<T>> Function({bool forceReload}) fetchFunction;
  
  List<T> _items = [];
  List<T> get items => _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? errorMessage;

  GenericDropdownRangeController({
    required this.fetchFunction,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override
  void onParentValueChanged() {
    _items = []; tempValue = null; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final newData = await fetchFunction(forceReload: forceReload);
      DropdownRange<T>? syncWithNewList(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue; T? t = currentRange.toValue;
        if (f != null) { if (!newData.contains(f)) newData.insert(0, f); else f = newData.firstWhere((e) => e == f); }
        if (t != null) { if (!newData.contains(t)) newData.insert(0, t); else t = newData.firstWhere((e) => e == t); }
        return DropdownRange<T>(fromValue: f, toValue: t);
      }
      if (tempValue != null) tempValue = syncWithNewList(tempValue);
      if (appliedValue != null) appliedValue = syncWithNewList(appliedValue);
      _items = newData;
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل تحميل البيانات."; } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData(forceReload: false);
  }
}

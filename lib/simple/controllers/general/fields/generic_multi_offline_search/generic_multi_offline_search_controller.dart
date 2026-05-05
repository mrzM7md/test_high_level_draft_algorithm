import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericMultiOfflineSearchController<T> extends BaseFilterController<List<T>> {
  final Future<List<T>> Function({bool forceReload}) fetchAllFunction;
  final bool Function(T item, String query) localFilterFunction;

  List<T> _items = [];
  List<T> get items => _items; // 👈 إضافة Getter للبيانات

  List<T> searchResults = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading; // 👈 🔥 حل المشكلة هنا

  String? errorMessage;

  GenericMultiOfflineSearchController({
    required this.fetchAllFunction,
    required this.localFilterFunction,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }
    if (isRequired && (tempValue == null || tempValue!.isEmpty)) { validationError = "هذا الحقل مطلوب ولا يمكن تركه فارغاً"; notifyListeners(); return false; }
    validationError = null; notifyListeners(); return true;
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData();
  }

  @override
  void onParentValueChanged() {
    _items = []; searchResults = []; tempValue = []; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final newData = await fetchAllFunction(forceReload: forceReload);
      List<T>? syncList(List<T>? currentList) {
        if (currentList == null || currentList.isEmpty) return [];
        List<T> synced = [];
        for (var item in currentList) {
          if (newData.contains(item)) { synced.add(newData.firstWhere((e) => e == item)); }
          else { synced.add(item); newData.insert(0, item); }
        }
        return synced;
      }
      tempValue = syncList(tempValue); appliedValue = syncList(appliedValue);
      _items = newData; searchResults = List.from(_items);
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل تحميل البيانات."; } finally { _isLoading = false; notifyListeners(); }
  }

  void onSearchQueryChanged(String query) {
    if (query.trim().isEmpty) { searchResults = List.from(_items); }
    else { final lowerQuery = query.toLowerCase().trim(); searchResults = _items.where((item) => localFilterFunction(item, lowerQuery)).toList(); }
    notifyListeners();
  }

  void resetSearch() { searchResults = List.from(_items); notifyListeners(); } // 👈 إضافة دالة الإرجاع
  void toggleItem(T item) { final currentList = List<T>.from(tempValue ?? []); if (currentList.contains(item)) currentList.remove(item); else currentList.add(item); updateTemp(currentList.isEmpty ? null : currentList); }
  void removeItem(T item) { final currentList = List<T>.from(tempValue ?? []); currentList.remove(item); updateTemp(currentList.isEmpty ? null : currentList); }
}
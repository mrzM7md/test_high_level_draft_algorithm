// --- base_data_filter_controller.dart ---
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  List<T> _items = [];
  List<T> get items => _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BaseDataFilterController({
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired, // 🔥 تمرير الخاصية للآباء
  });

  @override
  void onParentValueChanged() {
    _items = [];
    tempValue = null;
    super.onParentValueChanged();
    if (isVisible == null || isVisible!()) {
      refreshData();
    }
  }

  Future<void> refreshData() async { await _fetchInternal(); }

  Future<void> _fetchInternal() async {
    _isLoading = true;
    notifyListeners();
    try {
      final newData = await fetchDataFromServer();
      T? syncItem(T? currentItem) {
        if (currentItem == null) return null;
        if (!newData.contains(currentItem)) return currentItem;
        return newData.firstWhere((e) => e == currentItem);
      }
      tempValue = syncItem(tempValue);
      appliedValue = syncItem(appliedValue);
      _items = newData;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "عذراً، تعذر تحديث البيانات.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await _fetchInternal();
  }

  Future<List<T>> fetchDataFromServer();
}
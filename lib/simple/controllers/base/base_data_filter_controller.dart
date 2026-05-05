import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import '../general/models/filter_fetch_exception.dart';

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  List<T> _items = [];
  List<T> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final T? Function(List<T> items)? defaultSelectionBuilder;

  // 🏎️ توكن الحماية لمنع سباق التنازع عند تغير الكنترولر الأب بسرعة
  int _fetchToken = 0;

  BaseDataFilterController({
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton,
    this.defaultSelectionBuilder,
  });

  @override
  void onParentValueChanged() {
    _items = [];
    tempValue = null;
    validationError = null;
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData(forceReload: false);
    }
  }

  Future<void> refreshData({bool forceReload = false}) async {
    await _fetchInternal(forceReload: forceReload);
  }

  Future<void> _fetchInternal({bool forceReload = false}) async {
    final currentFetchToken = ++_fetchToken; // توليد توكن جديد

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawData = await fetchDataFromServer(forceReload: forceReload);

      // 🏎️ إجهاض إذا تغير الاعتماد أثناء الجلب لمنع تدمير البيانات
      if (_fetchToken != currentFetchToken) return;

      final safeNewData = List<T>.from(rawData);

      T? syncItem(T? currentItem) {
        if (currentItem == null) return null;
        if (safeNewData.contains(currentItem)) {
          return safeNewData.firstWhere((e) => e == currentItem);
        } else {
          return currentItem;
        }
      }

      tempValue = syncItem(tempValue);
      appliedValue = syncItem(appliedValue);
      _items = safeNewData;

      if (tempValue == null && defaultSelectionBuilder != null) {
        tempValue = defaultSelectionBuilder!(_items);
        if (tempValue != null) {
          appliedValue = tempValue;
        }
      }

    } on FilterFetchException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "عذراً، تعذر تحديث البيانات.";
    } finally {
      if (_fetchToken == currentFetchToken) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await _fetchInternal();
  }

  Future<List<T>> fetchDataFromServer({bool forceReload = false});
}
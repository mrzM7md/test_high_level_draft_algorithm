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
  int _searchToken = 0;

  // 🚀 حماية سباق الاعتماديات
  int _fetchToken = 0;

  GenericMultiSearchController({
    required this.initialFetchFunction,
    required this.searchFunction,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) {
      validationError = null;
      return true;
    }
    if (isRequired && (tempValue == null || tempValue!.isEmpty)) {
      validationError = "هذا الحقل مطلوب";
      notifyListeners();
      return false;
    }
    validationError = null;
    notifyListeners();
    return true;
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await refreshData();
  }

  @override
  void onParentValueChanged() {
    _items = [];
    searchResults = [];
    tempValue = [];
    super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    final currentFetchToken = ++_fetchToken; // 🚀 توكن الجلب

    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final rawData = await initialFetchFunction(forceReload: forceReload);

      // 🚀 إجهاض إذا تغير الاعتماد (الأب) أثناء الجلب!
      if (_fetchToken != currentFetchToken) return;

      final List<T> safeNewData = List<T>.from(rawData);

      List<T>? syncList(List<T>? currentList) {
        if (currentList == null || currentList.isEmpty) return [];
        List<T> synced = [];
        for (var item in currentList) {
          if (safeNewData.contains(item)) {
            synced.add(safeNewData.firstWhere((e) => e == item));
          } else {
            // 🚀 إضافة كمسودة فقط للحفاظ عليها بالواجهة، بدون تلويث القائمة الرئيسية
            synced.add(item);
          }
        }
        return synced;
      }

      tempValue = syncList(tempValue);
      appliedValue = syncList(appliedValue);
      _items = safeNewData;

      if (!isSearching && !_debouncer.isTimerActive) {
        searchResults = List.from(_items);
      }
    } on FilterFetchException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "فشل التحميل.";
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
      _searchToken++;
      notifyListeners();
      return;
    }

    final currentToken = ++_searchToken;

    _debouncer.run(() async {
      isSearching = true;
      notifyListeners();
      try {
        final results = await searchFunction(query);
        if (_searchToken == currentToken) {
          searchResults = results;
        }
      } catch (e) {
        if (_searchToken == currentToken) searchResults = [];
      } finally {
        if (_searchToken == currentToken) {
          isSearching = false;
          notifyListeners();
        }
      }
    });
  }

  void resetSearch() {
    _searchToken++;
    searchResults = List.from(_items);
    isSearching = false;
    notifyListeners();
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
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}

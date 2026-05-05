import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_data_filter_controller.dart';

class GenericOfflineSearchController<T> extends BaseDataFilterController<T> {
  final Future<List<T>> Function({bool forceReload}) fetchAllFunction;
  final bool Function(T item, String query) localFilterFunction;

  List<T> searchResults = [];

  bool isSearching = false;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 300); // 300ms كافية جداً للمحلي
  int _searchToken = 0;

  GenericOfflineSearchController({
    required this.fetchAllFunction,
    required this.localFilterFunction,
    super.defaultSelectionBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  Future<List<T>> fetchDataFromServer({bool forceReload = false}) => fetchAllFunction(forceReload: forceReload);

  @override
  void onParentValueChanged() { searchResults = []; super.onParentValueChanged(); }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();

    if (query.trim().isEmpty) {
      searchResults = List.from(items);
      isSearching = false;
      notifyListeners();
      return;
    }

    final currentToken = ++_searchToken;

    _debouncer.run(() async {
      isSearching = true;
      notifyListeners();

      try {
        final lowerQuery = query.toLowerCase().trim();

        // 🚀 الحل: فلترة مباشرة وسريعة بدون استخدام Isolates لتجنب الانهيار
        final results = items.where((item) => localFilterFunction(item, lowerQuery)).toList();

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
  void resetSearch() { searchResults = List.from(items); isSearching = false; notifyListeners(); }

  @override
  void dispose() { _debouncer.cancel(); super.dispose(); }

  @override
  Future<void> refreshData({bool forceReload = false}) async {
    await super.refreshData(forceReload: forceReload);
    // 🚀 السحر هنا: بعد انتهاء الأب من الجلب، نقوم بمزامنة نتائج البحث الافتراضية
    if (!isSearching && !_debouncer.isTimerActive) {
      searchResults = List.from(items);
      // نستدعي التحديث فقط إذا كنا قد تأكدنا أن الكنترولر لم يمت
      // (notifyListeners الموجودة في الأب محمية تلقائياً)
      notifyListeners();
    }
  }
}
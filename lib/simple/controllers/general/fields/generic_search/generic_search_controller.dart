import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_data_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';

class GenericSearchController<T> extends BaseDataFilterController<T> {
  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;

  List<T> searchResults = [];
  bool isSearching = false;
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  int _searchToken = 0;

  GenericSearchController({required this.initialFetchFunction, required this.searchFunction, super.defaultValue, super.dependencies, super.isVisible, super.isRequired});

  @override Future<List<T>> fetchDataFromServer({bool forceReload = false}) => initialFetchFunction(forceReload: forceReload);

  @override void onParentValueChanged() { searchResults = []; super.onParentValueChanged(); }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) { searchResults = List.from(items); isSearching = false; notifyListeners(); return; }

    final currentToken = ++_searchToken;

    _debouncer.run(() async {
      isSearching = true; notifyListeners();
      try {
        final results = await searchFunction(query);
        if (_searchToken == currentToken) {
          searchResults = results;
        }
      } catch (e) {
        if (_searchToken == currentToken) {
          searchResults = [];
        }
      } finally {
        if (_searchToken == currentToken) {
          isSearching = false;
          notifyListeners();
        }
      }
    });
  }

  void resetSearchState() { searchResults = List.from(items); isSearching = false; notifyListeners(); }
  @override void dispose() { _debouncer.cancel(); super.dispose(); }

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
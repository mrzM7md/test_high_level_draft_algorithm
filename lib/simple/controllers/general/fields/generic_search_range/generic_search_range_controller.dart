import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericSearchRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final Future<List<T>> Function({bool forceReload}) initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;

  final bool Function(T? from, T? to)? customRangeValidator;
  final String? customRangeErrorMessage;

  List<T> _items = [];
  List<T> get items => _items;
  List<T> searchResults = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool isSearching = false;
  String? errorMessage;

  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);
  int _searchToken = 0;

  int _fetchToken = 0;

  GenericSearchRangeController({
    required this.initialFetchFunction, required this.searchFunction,
    this.customRangeValidator, this.customRangeErrorMessage,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }

    final fromVal = tempValue?.fromValue;
    final toVal = tempValue?.toValue;

    if (isRequired && fromVal == null && toVal == null) {
      validationError = "يجب اختيار عنصر واحد على الأقل";
      notifyListeners();
      return false;
    }

    if (customRangeValidator != null) {
      if (!customRangeValidator!(fromVal, toVal)) {
        validationError = customRangeErrorMessage ?? "النطاق المحدد غير منطقي";
        notifyListeners();
        return false;
      }
    }

    validationError = null;
    notifyListeners();
    return true;
  }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) { searchResults = List.from(_items); isSearching = false; notifyListeners(); return; }

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

  void resetSearch() { searchResults = List.from(_items); isSearching = false; notifyListeners(); }

  @override
  void onParentValueChanged() {
    _items = []; searchResults = []; tempValue = null; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    final currentFetchToken = ++_fetchToken;

    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final rawData = await initialFetchFunction(forceReload: forceReload);
      if (_fetchToken != currentFetchToken) return;

      final safeNewData = List<T>.from(rawData);

      DropdownRange<T>? syncRange(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue; T? t = currentRange.toValue;

        if (f != null) {
          if (safeNewData.contains(f)) f = safeNewData.firstWhere((e) => e == f);
          // 🚀 تم حذف عملية الإدراج
        }
        if (t != null) {
          if (safeNewData.contains(t)) t = safeNewData.firstWhere((e) => e == t);
          // 🚀 تم حذف عملية الإدراج
        }
        return DropdownRange<T>(fromValue: f, toValue: t);
      }

      if (tempValue != null) tempValue = syncRange(tempValue);
      if (appliedValue != null) appliedValue = syncRange(appliedValue);

      _items = safeNewData;

      if (!isSearching && !_debouncer.isTimerActive) {
        searchResults = List.from(_items);
      }
    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل التحميل."; } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await refreshData(forceReload: false);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';

class GenericDropdownRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final Future<List<T>> Function({bool forceReload}) fetchFunction;
  final bool Function(T? from, T? to)? customRangeValidator;
  final String? customRangeErrorMessage;

  List<T> _items = [];
  List<T> get items => _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? errorMessage;
  int _fetchToken = 0;

  GenericDropdownRangeController({
    required this.fetchFunction,
    this.customRangeValidator,
    this.customRangeErrorMessage,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }

    final fromVal = tempValue?.fromValue;
    final toVal = tempValue?.toValue;

    if (isRequired && (fromVal == null || toVal == null)) {
      validationError = "هذا الحقل مطلوب بالكامل ولا يمكن تركه فارغاً";
      notifyListeners();
      return false;
    }

    // 🚀 الحماية المطلقة: لا تنفذ دالة التحقق إذا كان الحقل اختيارياً وفارغاً!
    if (!isRequired && fromVal == null && toVal == null) {
      validationError = null;
      notifyListeners();
      return true;
    }

    if (customRangeValidator != null) {
      if (!customRangeValidator!(fromVal, toVal)) {
        validationError = customRangeErrorMessage ?? "نطاق غير صالح (تأكد أن 'من' يسبق 'إلى')";
        notifyListeners();
        return false;
      }
    }

    validationError = null;
    notifyListeners();
    return true;
  }

  @override
  void onParentValueChanged() {
    _items = []; tempValue = null; super.onParentValueChanged();
    if (isVisible == null || isVisible!()) refreshData(forceReload: false);
  }

  Future<void> refreshData({bool forceReload = false}) async {
    final currentFetchToken = ++_fetchToken;
    _isLoading = true; errorMessage = null; notifyListeners();
    try {
      final rawData = await fetchFunction(forceReload: forceReload);
      if (_fetchToken != currentFetchToken) return;

      final safeNewData = List<T>.from(rawData);

      DropdownRange<T>? syncWithNewList(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue; T? t = currentRange.toValue;
        if (f != null && safeNewData.contains(f)) f = safeNewData.firstWhere((e) => e == f);
        if (t != null && safeNewData.contains(t)) t = safeNewData.firstWhere((e) => e == t);
        return DropdownRange<T>(fromValue: f, toValue: t);
      }

      if (tempValue != null) tempValue = syncWithNewList(tempValue);
      if (appliedValue != null) appliedValue = syncWithNewList(appliedValue);
      _items = safeNewData;

    } on FilterFetchException catch (e) { errorMessage = e.message; } catch (e) { errorMessage = "فشل تحميل البيانات."; } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await refreshData(forceReload: false);
  }
}
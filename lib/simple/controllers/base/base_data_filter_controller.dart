import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  List<T> _items = [];
  List<T> get items => _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BaseDataFilterController({super.defaultValue, super.dependencies, super.isVisible});

  // نستعمل الخطاف الجديد الذي لا يُستدعى إلا عند التغير الحقيقي
// --- base_data_filter_controller.dart ---
  @override
  void onParentValueChanged() {
    _items = []; // مسح الكاش القديم
    tempValue = null; // مسح المسودة لأنها لم تعد متوافقة مع الأب الجديد

    // ملاحظة: لا نمسح الـ appliedValue لضمان التراجع الآمن
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData(); // جلب البيانات المتوافقة مع مسودة الأب
    }
  }

  Future<void> refreshData() async {
    await _fetchInternal();
  }

  Future<void> _fetchInternal() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newData = await fetchDataFromServer();

      // مزامنة ذكية: ربط المسودة والقيمة المعتمدة بالقائمة الجديدة
      T? syncItem(T? currentItem) {
        if (currentItem == null) return null;
        // إذا لم تكن القيمة المعتمدة موجودة في بيانات الأب الجديد، نحتفظ بمرجعها
        // حتى يتم استعادتها لو تراجع المستخدم عن تغيير الأب
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
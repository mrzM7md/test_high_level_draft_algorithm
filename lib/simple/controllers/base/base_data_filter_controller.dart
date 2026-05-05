import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import '../general/models/filter_fetch_exception.dart'; // 🔥 تأكد من مسار الاستثناء

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  List<T> _items = [];
  List<T> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 🔥 المعامل الجديد: دالة اختيار القيمة الافتراضية بذكاء بعد جلب البيانات
  final T? Function(List<T> items)? defaultSelectionBuilder;

  BaseDataFilterController({
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton,
    this.defaultSelectionBuilder, // 🔥 تمرير المعامل
  });

  @override
  void onParentValueChanged() {
    _items = [];
    tempValue = null;
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData(forceReload: false);
    }
  }

  Future<void> refreshData({bool forceReload = false}) async {
    await _fetchInternal(forceReload: forceReload);
  }

  Future<void> _fetchInternal({bool forceReload = false}) async {
    _isLoading = true;
    _errorMessage = null; // تصفير الخطأ عند المحاولة الجديدة
    notifyListeners();

    try {
      // 3. 🔥 تمرير أمر الإجبار لدالة الجلب الفعلي التي ستُبنى في الكنترولرات الابنة
      final newData = await fetchDataFromServer(forceReload: forceReload);

      // دالة المزامنة المعتادة
      T? syncItem(T? currentItem) {
        if (currentItem == null) return null;
        if (!newData.contains(currentItem)) return currentItem;
        return newData.firstWhere((e) => e == currentItem);
      }

      tempValue = syncItem(tempValue);
      appliedValue = syncItem(appliedValue);
      _items = newData;

      // السحر هنا: تطبيق القيمة الافتراضية الذكية إذا لم يكن هناك قيمة مختارة
      if (tempValue == null && defaultSelectionBuilder != null) {
        tempValue = defaultSelectionBuilder!(_items);

        // نجعلها مطبقة فوراً (Applied) لكي تُحسب في فلاتر الأبناء إن وُجدت
        if (tempValue != null) {
          appliedValue = tempValue;
        }
      }

    } on FilterFetchException catch (e) {
      _errorMessage = e.message; // التقاط خطأ السيرفر المخصص
    } catch (e) {
      _errorMessage = "عذراً، تعذر تحديث البيانات."; // خطأ عام
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureDataLoaded() async {
    // إيقاف حلقة إعادة البناء اللانهائية إذا كان هناك خطأ
    if (_items.isNotEmpty || _isLoading || _errorMessage != null) return;
    await _fetchInternal();
  }

  // 4. 🔥 إضافة المعامل لتوقيع الدالة التجريدية لكي تلتزم به كل الكنترولرات
  Future<List<T>> fetchDataFromServer({bool forceReload = false});
}
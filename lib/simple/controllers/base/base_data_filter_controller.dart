// --- base_data_filter_controller.dart ---
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  // هنا نحفظ البيانات (بديل firstData العمياء)
  List<T> _items = [];
  List<T> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // هذه الدالة السحرية للتحميل لمرة واحدة فقط
  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return; // تم التحميل مسبقاً

    _isLoading = true;
    _errorMessage = null;
    // نبلغ الواجهة برسم دائرة التحميل
    notifyListeners(); 

    try {
      _items = await fetchDataFromServer();
    } catch (e) {
      _errorMessage = "حدث خطأ أثناء جلب البيانات";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // كل فلتر يقرر من أين يجلب بياناته
  Future<List<T>> fetchDataFromServer();
}
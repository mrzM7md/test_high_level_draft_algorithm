// --- base_data_filter_controller.dart ---
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

abstract class BaseDataFilterController<T> extends BaseFilterController<T> {
  List<T> _items = [];
  List<T> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await _fetchInternal();
  }

  // التعديل الجوهري: حذف سطر _items = [];
  Future<void> refreshData() async {
    await _fetchInternal();
  }

  Future<void> _fetchInternal() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // نجلب البيانات في متغير مؤقت أولاً
      final newData = await fetchDataFromServer();

      // التعديل الجوهري: لا نستبدل القائمة إلا عند النجاح
      _items = newData;
      _errorMessage = null;
    } catch (e) {
      // في حالة الفشل: تبقى _items كما هي (البيانات القديمة)
      _errorMessage = "عذراً، تعذر تحديث البيانات. تأكد من الاتصال.";
      // يمكنك هنا استخدام snackbar أو toast لعرض الخطأ دون تدمير الواجهة
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<T>> fetchDataFromServer();
}
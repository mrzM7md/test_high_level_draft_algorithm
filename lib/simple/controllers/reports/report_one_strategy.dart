import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/imp/category_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/imp/date_range_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

// 1. التقرير الأول
class ReportOneStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير المبيعات (التقرير الأول)";

  // تعريف الفلاتر الخاصة بهذا التقرير
  final _dateFilter = DateRangeFilterController();
  final _categoryFilter = CategoryFilterController(ApiRepository()); // المشترك

  @override
  List<BaseFilterController> get filterControllers => [_dateFilter, _categoryFilter];

  @override
  Future<List<String>> fetchReportData() async {
    final dates = _dateFilter.appliedValue;
    final category = _categoryFilter.appliedValue;
    
    // إرسال البيانات للـ API...
    await Future.delayed(const Duration(milliseconds: 500));
    return ["مبيعات ${category?.name ?? 'الكل'} من ${dates?.fromDate.day} إلى ${dates?.toDate.day}"];
  }
}

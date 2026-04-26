

import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/imp/category_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/imp/customer_server_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير العملاء (بحث السيرفر المباشر)";

  // 1. إنشاء الـ Repository (الذي سيتصل بالـ Backend)
  final ApiRepository repo = ApiRepository();

  // 2. تعريف الكنترولر الجديد الذي صممناه
  late final CategoryFilterController _categoryFilter;
  late final CustomerServerSearchController _customerFilter; // الكلاس الجديد!

  ReportTwoStrategy() {
    // 3. تمرير الـ Repository للكنترولرات عند بناء التقرير (Dependency Injection)
    _categoryFilter = CategoryFilterController(repo);
    _customerFilter = CustomerServerSearchController(repo);
  }

  // 4. تجميعها للواجهة
  @override
  List<BaseFilterController> get filterControllers => [_categoryFilter, _customerFilter];

  // 5. جلب بيانات التقرير النهائية
  @override
  Future<List<String>> fetchReportData() async {
    final category = _categoryFilter.appliedValue;
    final customer = _customerFilter.appliedValue;

    // هنا يتم إرسال القيم المعتمدة النهائية لجلب التقرير الفعلي
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      "نتيجة التقرير:",
      "العميل المختار: ${customer?.name ?? 'الكل'}",
      "رقم هاتفه: ${customer?.phone ?? '---'}",
      "التصنيف: ${category?.name ?? 'الكل'}"
    ];
  }
}
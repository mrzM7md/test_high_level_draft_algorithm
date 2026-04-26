import '../../repos/api_repository.dart';
import '../base/base_filter_controller.dart';
import '../imp/category_filter_controller.dart';
import '../imp/customer_search_filter_controller.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير العملاء المتقدم";

  // حقن الاعتماديات (Dependency Injection)
  final ApiRepository repo = ApiRepository();

  late final CategoryFilterController _categoryFilter;
  late final CustomerSearchFilterController _customerFilter;

  ReportTwoStrategy() {
    // تعريف الفلاتر وربطها بالـ Repository
    _categoryFilter = CategoryFilterController(repo);
    _customerFilter = CustomerSearchFilterController(repo);
  }

  @override
  List<BaseFilterController> get filterControllers => [_categoryFilter, _customerFilter];

  @override
  Future<List<String>> fetchReportData() async {
    final category = _categoryFilter.appliedValue;
    final customer = _customerFilter.appliedValue;

    print("🚀 إرسال طلب التقرير للسيرفر...");
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      "نتيجة البحث:",
      "العميل: ${customer?.name ?? 'الكل'}",
      "التصنيف: ${category?.name ?? 'الكل'}"
    ];
  }
}
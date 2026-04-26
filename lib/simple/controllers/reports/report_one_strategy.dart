// --- report_one_strategy.dart ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_date_controller.dart'; // استيراد الحقل الجديد
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_date_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/data_range.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportOneStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير حركة المبيعات المتقدم";

  final ApiRepository repo = ApiRepository();

  // 1. الفلتر الأول: مدى تاريخ ديناميكي (من وإلى)
  late final GenericDateRangeController _dateRangeFilter;

  // 2. الفلتر الثاني: تاريخ منفرد ديناميكي (إضافة جديدة)
  late final GenericDateController _singleDateFilter;

  // 3. الفلتر الثالث: قائمة منسدلة ديناميكية
  late final GenericDropdownController _categoryFilter;

  late final GenericDropdownRangeController<CategoryModel> _categoryRangeFilter;

  late final GenericSearchRangeController<CustomerModel> _customerRangeFilter;

  ReportOneStrategy() {
    // بناء فلتر مدى التاريخ
    _dateRangeFilter = GenericDateRangeController(
      labelText: "فترة الفواتير",
      fromLabelText: "من تاريخ",
      toLabelText: "حتى تاريخ",
      defaultRange: DateRange(
          fromDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          toDate: DateTime.now()
      ),
    );

    // بناء فلتر التاريخ المنفرد (مثلاً لتحديد موعد استحقاق معين)
    _singleDateFilter = GenericDateController(
      labelText: "تاريخ الاستحقاق",
      hintText: "اضغط لتحديد التاريخ...",
      defaultValue: DateTime.now(), // القيمة الافتراضية هي اليوم
    );

    // بناء فلتر التصنيفات
    _categoryFilter = GenericDropdownController(
      labelText: "اختر التصنيف",
      fetchFunction: () => repo.fetchCategories(),
      itemLabelBuilder: (cat) => cat.name,
    );

    _categoryRangeFilter = GenericDropdownRangeController<CategoryModel>(
      labelText: "نطاق التصنيفات",
      fromLabelText: "من تصنيف",
      toLabelText: "إلى تصنيف",
      fetchFunction: () => repo.fetchCategories(),
      itemLabelBuilder: (cat) => cat.name,
    );

    _customerRangeFilter = GenericSearchRangeController<CustomerModel>(
      labelText: "نطاق العملاء (أونلاين)",
      fromLabelText: "من عميل",
      toLabelText: "إلى عميل",
      hintText: "اختر...",
      initialFetchFunction: () => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      // التصميم الديناميكي لعنصر العميل داخل قائمة البحث
      itemBuilder: (customer, isSelected) {
        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.blue.withOpacity(0.1),
          title: Text(customer.name, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold)),
          subtitle: Text(customer.phone),
          leading: CircleAvatar(
            backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
            child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.black54),
          ),
          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
        );
      },
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    _dateRangeFilter,
    _singleDateFilter,
    _categoryFilter,
    _categoryRangeFilter,
    _customerRangeFilter,
  ];

  @override
  Future<List<String>> fetchReportData() async {
    final dates = _dateRangeFilter.appliedValue;
    final singleDate = _singleDateFilter.appliedValue;
    final cat = _categoryFilter.appliedValue;
    final catRange = _categoryRangeFilter.appliedValue;
    final cstRange = _customerRangeFilter.appliedValue;

    // محاكاة معالجة البيانات بناءً على الفلاتر الثلاثة
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      "تقرير مبيعات ${cat?.name ?? 'الكل'}",
      "الفترة: من ${dates?.fromDate} إلى ${dates?.toDate}",
      "تاريخ الاستحقاق المختار: ${singleDate ?? 'لم يحدد'}",
      "من تصنيف: ${catRange?.fromValue?.name}",
      "إلى تصنيف: ${catRange?.toValue?.name}",
      "من حقل: ${cstRange?.fromValue?.name}",
      "إلى حقل: ${cstRange?.toValue?.name}",
    ];
  }
}
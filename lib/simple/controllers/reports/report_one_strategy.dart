// 🚫 تأكد من عدم وجود أي استيراد لـ flutter/material.dart

import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker/generic_date_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker_range/generic_date_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text/generic_text_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/numeric_field/generic_number_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportOneStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير حركة المبيعات المتقدم";

  final ApiRepository repo = ApiRepository();

  // 1. فلاتر التاريخ
  late final GenericDateRangeController dateRangeFilter;
  late final GenericDateController singleDateFilter;

  // 2. فلاتر التصنيفات
  late final GenericDropdownController<CategoryModel> categoryFilter;
  late final GenericDropdownRangeController<CategoryModel> categoryRangeFilter;

  // 3. فلاتر العملاء (مفرد ونطاق)
  late final GenericSearchController<CustomerModel> customerFilter;
  late final GenericSearchRangeController<CustomerModel> customerRangeFilter;

  // 4. فلاتر النصوص والأرقام
  late final GenericTextController noteFilter;
  late final GenericNumberController amountFilter;

  ReportOneStrategy() {

    // بناء فلتر فترة التاريخ
    dateRangeFilter = GenericDateRangeController(
      defaultValue: DateRange(
          fromDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          toDate: DateTime.now()
      ),
      // 🚀 حماية التواريخ العكسية
      customRangeValidator: (from, to) {
        if (from == null || to == null) return true; // يتم تجاهله إذا كان أحدهما فارغاً
        return from.isBefore(to) || from.isAtSameMomentAs(to);
      },
      customRangeErrorMessage: "تاريخ البداية (من) لا يمكن أن يكون بعد تاريخ النهاية (إلى)",
    );

    // بناء فلتر التاريخ المفرد
    singleDateFilter = GenericDateController(
      defaultValue: DateTime.now(),
    );

    // بناء فلتر التصنيفات
    categoryFilter = GenericDropdownController<CategoryModel>(
      fetchFunction: ({bool forceReload = false}) => repo.fetchCategories(),
    );

    // بناء فلتر نطاق التصنيفات
    categoryRangeFilter = GenericDropdownRangeController<CategoryModel>(
      fetchFunction: ({bool forceReload = false}) => repo.fetchCategories(),
      // 🚀 حماية الترتيب: كمثال نقارن الـ ID أو يمكنك التعديل لمقارنة أي حقل ترتيب
      customRangeValidator: (from, to) {
        if (from == null || to == null) return true;
        return from.id.toString().compareTo(to.id.toString()) <= 0;
      },
      customRangeErrorMessage: "تصنيف (من) يجب أن يكون قبل أو يساوي تصنيف (إلى)",
    );

    // بناء فلتر البحث المفرد للعملاء
    customerFilter = GenericSearchController<CustomerModel>(
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
    );

    // بناء فلتر نطاق البحث للعملاء
    customerRangeFilter = GenericSearchRangeController<CustomerModel>(
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      // 🚀 حماية الترتيب: كمثال نقارن الأسماء أبجدياً
      customRangeValidator: (from, to) {
        if (from == null || to == null) return true;
        return from.name.compareTo(to.name) <= 0;
      },
      customRangeErrorMessage: "اسم العميل في (من) يجب أن يسبق أبجدياً اسم العميل في (إلى)",
    );

    // فلتر الملاحظات النصية
    noteFilter = GenericTextController();

    // فلتر الأرقام
    amountFilter = GenericNumberController(
      isRequired: true,
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    dateRangeFilter,
    singleDateFilter,
    categoryFilter,
    categoryRangeFilter,
    customerFilter,
    customerRangeFilter,
    noteFilter,
    amountFilter
  ];

  @override
  Future<List<String>> fetchReportData() async {
    final dates = dateRangeFilter.appliedValue;
    final singleDate = singleDateFilter.appliedValue;
    final cat = categoryFilter.appliedValue;
    final catRange = categoryRangeFilter.appliedValue;
    final cust = customerFilter.appliedValue;
    final cstRange = customerRangeFilter.appliedValue;
    final noteValue = noteFilter.appliedValue;
    final amountValue = amountFilter.appliedValue;

    await Future.delayed(const Duration(milliseconds: 500));

    return [
      "تقرير مبيعات ${cat?.name ?? 'الكل'}",
      "الفترة: من ${dates?.fromDate} إلى ${dates?.toDate}",
      "تاريخ الاستحقاق المختار: ${singleDate ?? 'لم يحدد'}",
      "من تصنيف: ${catRange?.fromValue?.name}",
      "إلى تصنيف: ${catRange?.toValue?.name}",
      "العميل المحدد: ${cust?.name ?? 'الكل'}",
      "من عميل (نطاق): ${cstRange?.fromValue?.name}",
      "إلى عميل (نطاق): ${cstRange?.toValue?.name}",
      "ملاحظة: $noteValue",
      "إالكمية: $amountValue",
    ];
  }
}
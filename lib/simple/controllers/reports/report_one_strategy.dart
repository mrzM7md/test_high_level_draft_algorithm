import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_date_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_date_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_number_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportOneStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير حركة المبيعات المتقدم";

  final ApiRepository repo = ApiRepository();

  // 1. فلاتر التاريخ
  late final GenericDateRangeController _dateRangeFilter;
  late final GenericDateController _singleDateFilter;

  // 2. فلاتر التصنيفات
  late final GenericDropdownController _categoryFilter;
  late final GenericDropdownRangeController<CategoryModel> _categoryRangeFilter;

  // 3. فلاتر العملاء (مفرد ونطاق)
  late final GenericSearchController<CustomerModel> _customerFilter; // الحقل الجديد
  late final GenericSearchRangeController<CustomerModel> _customerRangeFilter;

  late final GenericTextController _noteFilter;
  late final GenericNumberController _amountFilter;

  ReportOneStrategy() {
    // بناء فلاتر التاريخ
    _dateRangeFilter = GenericDateRangeController(
      labelText: "فترة الفواتير",
      fromLabelText: "من تاريخ",
      toLabelText: "حتى تاريخ",
      defaultRange: DateRange(
          fromDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          toDate: DateTime.now()
      ),
    );

    _singleDateFilter = GenericDateController(
      labelText: "تاريخ الاستحقاق",
      hintText: "اضغط لتحديد التاريخ...",
      defaultValue: DateTime.now(),
    );

    // بناء فلاتر التصنيفات
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

    // بناء فلتر البحث المفرد للعملاء
    _customerFilter = GenericSearchController<CustomerModel>(
      labelText: "العميل (بحث مفرد)",
      hintText: "اضغط للبحث عن عميل...",
      initialFetchFunction: () => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
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

    // بناء فلتر نطاق البحث للعملاء
    _customerRangeFilter = GenericSearchRangeController<CustomerModel>(
      labelText: "نطاق العملاء (أونلاين)",
      fromLabelText: "من عميل",
      toLabelText: "إلى عميل",
      hintText: "اختر...",
      initialFetchFunction: () => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
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

    _noteFilter = GenericTextController(
      labelText: "ملاحظات الفاتورة",
      hintText: "ابحث بكلمة في الملاحظات...",
    );

    _amountFilter = GenericNumberController(
      labelText: "مبلغ الفاتورة (أكبر من)",
      hintText: "0.0",
      isRequired: true, // يمكن جعله إجبارياً أيضاً!
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    _dateRangeFilter,
    _singleDateFilter,
    _categoryFilter,
    _categoryRangeFilter,
    _customerFilter, // تم وضعه فوق حقل النطاق
    _customerRangeFilter,
    _noteFilter,
    _amountFilter
  ];

  @override
  Future<List<String>> fetchReportData() async {
    final dates = _dateRangeFilter.appliedValue;
    final singleDate = _singleDateFilter.appliedValue;
    final cat = _categoryFilter.appliedValue;
    final catRange = _categoryRangeFilter.appliedValue;
    final cust = _customerFilter.appliedValue; // القيمة المعتمدة للبحث المفرد
    final cstRange = _customerRangeFilter.appliedValue;
    final noteFilter = _noteFilter.appliedValue;
    final amountFilter = _amountFilter.appliedValue;

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
      "ملاحظة: $noteFilter",
      "إالكمية: $amountFilter",
    ];
  }
}
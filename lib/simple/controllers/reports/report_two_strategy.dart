import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير الترابط الديناميكي المتقدم";

  final ApiRepository repo = ApiRepository();

  // 1. فلاتر التصنيفات (الموجودة مسبقاً)
  late final GenericDropdownController<CategoryModel> _mainCategoryFilter;
  late final GenericDropdownRangeController<CategoryModel> _subCategoryRangeFilter;

  // 2. الفلاتر الجديدة: البحث المترابط
  late final GenericSearchController<CustomerModel> _mainCustomerSearch;
  late final GenericSearchRangeController<CustomerModel> _customerRangeSearch;

  ReportTwoStrategy() {
    // --- قسم التصنيفات ---
    _mainCategoryFilter = GenericDropdownController<CategoryModel>(
      labelText: "التصنيف الرئيسي",
      fetchFunction: () => repo.fetchCategories(),
      itemLabelBuilder: (category) => category.name,
    );

    _subCategoryRangeFilter = GenericDropdownRangeController<CategoryModel>(
      labelText: "نطاق التصنيفات الفرعية",
      fromLabelText: "من فرعي",
      toLabelText: "إلى فرعي",
      fetchFunction: () => repo.fetchSubCategories(_mainCategoryFilter.tempValue!.id),
      itemLabelBuilder: (category) => category.name,
      dependencies: [_mainCategoryFilter],
      isVisible: () {
        final parentValue = _mainCategoryFilter.tempValue;
        final parentItems = _mainCategoryFilter.items;
        if (parentValue == null || parentItems.isEmpty) return false;
        return parentValue != parentItems.last;
      },
    );

    // --- قسم البحث المترابط (العملاء) ---

    // أولاً: حقل البحث المفرد (الأب)
    _mainCustomerSearch = GenericSearchController<CustomerModel>(
      labelText: "اختيار العميل الرئيسي",
      hintText: "ابحث عن العميل الأب...",
      initialFetchFunction: () => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(customer.phone),
        leading: const CircleAvatar(child: Icon(Icons.person)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),
    );

    // ثانياً: حقل نطاق البحث (الابن المعتمد)
    _customerRangeSearch = GenericSearchRangeController<CustomerModel>(
      labelText: "نطاق الفروع/المناديب",
      fromLabelText: "من فرع",
      toLabelText: "إلى فرع",
      hintText: "بحث...",
      // السحر: جلب بيانات النطاق بناءً على ID العميل المختار في الحقل الأول
      initialFetchFunction: () => repo.fetchRelatedCustomers(_mainCustomerSearch.tempValue!.id),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name),
        leading: const Icon(Icons.location_on),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),

      // ربط الاعتمادية والظهور المشروط
      dependencies: [_mainCustomerSearch],
      isVisible: () => _mainCustomerSearch.tempValue != null, // يظهر فقط إذا اخترنا عميلاً
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    _mainCategoryFilter,
    _subCategoryRangeFilter,
    _mainCustomerSearch,   // الحقل الجديد الأول
    _customerRangeSearch,  // الحقل الجديد الثاني (المعتمد)
  ];

  @override
  Future<List<String>> fetchReportData() async {
    final mainCust = _mainCustomerSearch.appliedValue;
    final rangeCust = _customerRangeSearch.appliedValue;

    return [
      "العميل الأب: ${mainCust?.name ?? '---'}",
      "نطاق الفروع من: ${rangeCust?.fromValue?.name ?? '---'}",
      "نطاق الفروع إلى: ${rangeCust?.toValue?.name ?? '---'}",
    ];
  }
}
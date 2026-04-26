// --- report_two_strategy.dart ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير ديناميكي (Dynamic Report)";

  final ApiRepository repo = ApiRepository();

  // 1. إنشاء فلتر تصنيفات (بدون كلاس مخصص!)
  late final GenericDropdownController<CategoryModel> _categoryFilter;

  // 2. إنشاء فلتر عملاء (بدون كلاس مخصص!)
  late final GenericSearchController<CustomerModel> _customerFilter;

  ReportTwoStrategy() {
    // بناء فلتر التصنيفات
    _categoryFilter = GenericDropdownController<CategoryModel>(
      labelText: "اختر التصنيف",
      fetchFunction: () => repo.fetchCategories(), // دالة الجلب
      itemLabelBuilder: (category) => category.name, // كيف يعرض النص
    );

    // بناء فلتر العملاء وتصميم الكرت الخاص به!
    _customerFilter = GenericSearchController<CustomerModel>(
      labelText: "العميل",
      hintText: "اضغط للبحث عن عميل...",
      initialFetchFunction: () => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      // 🔥 التصميم الديناميكي: هنا تبني شكل الـ ListTile للعميل
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
  List<BaseFilterController> get filterControllers => [_categoryFilter, _customerFilter];

  @override
  Future<List<String>> fetchReportData() async {
    final cat = _categoryFilter.appliedValue;
    final cust = _customerFilter.appliedValue;
    return ["العميل: ${cust?.name}", "التصنيف: ${cat?.name}"];
  }
}
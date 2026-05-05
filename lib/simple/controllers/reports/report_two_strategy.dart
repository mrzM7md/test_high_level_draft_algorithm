// 🚫 تم حذف استيراد flutter/material.dart نهائياً!

import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/check_box/generic_checkbox_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_offline_search/generic_multi_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search/generic_multi_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range/generic_multi_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_offline_search/generic_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير الترابط الديناميكي المتقدم";

  final ApiRepository repo = ApiRepository();

  late final GenericDropdownController<CategoryModel> mainCategoryFilter;
  late final GenericDropdownRangeController<CategoryModel> subCategoryRangeFilter;
  late final GenericSearchController<CustomerModel> mainCustomerSearch;
  late final GenericSearchRangeController<CustomerModel> customerRangeSearch;
  late final GenericMultiSearchController<CustomerModel> multiCustomerSearch;
  late final GenericMultiSearchRangeController<CustomerModel> multiRangeCustomerSearch;
  late final GenericOfflineSearchController<CustomerModel> offlineCustomerSearch;
  late final GenericMultiOfflineSearchController<CustomerModel> offlineMultiBranchSearch;
  late final GenericCheckboxController hideZeroBalancesFilter;
  late final FilterGroupController advancedSettingsGroup;

  ReportTwoStrategy() {
    mainCategoryFilter = GenericDropdownController<CategoryModel>(
      fetchFunction: ({bool forceReload = false}) => repo.fetchCategories(),
      isRequired: true,
    );

    subCategoryRangeFilter = GenericDropdownRangeController<CategoryModel>(
      // 🛠️ تم الإصلاح: الحماية من الـ Null Pointer Exception
      fetchFunction: ({bool forceReload = false}) async {
        final parentCat = mainCategoryFilter.tempValue;
        if (parentCat == null) return []; // أرجع قائمة فارغة في حال عدم وجود أب
        return repo.fetchSubCategories(parentCat.id);
      },
      dependencies: [mainCategoryFilter],
      isVisible: () {
        final parentValue = mainCategoryFilter.tempValue;
        final parentItems = mainCategoryFilter.items;
        if (parentValue == null || parentItems.isEmpty) return false;
        return parentValue != parentItems.last;
      },
    );

    mainCustomerSearch = GenericSearchController<CustomerModel>(
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
    );

    customerRangeSearch = GenericSearchRangeController<CustomerModel>(
      // 🛠️ تم الإصلاح: الحماية للعميل الأب أيضاً
      initialFetchFunction: ({bool forceReload = false}) async {
        final parentCust = mainCustomerSearch.tempValue;
        if (parentCust == null) return [];
        return repo.fetchRelatedCustomers(parentCust.id);
      },
      searchFunction: (query) => repo.searchCustomers(query),
      dependencies: [mainCustomerSearch],
      isVisible: () => mainCustomerSearch.tempValue != null,
    );

    multiCustomerSearch = GenericMultiSearchController<CustomerModel>(
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      isRequired: true,
    );

    multiRangeCustomerSearch = GenericMultiSearchRangeController<CustomerModel>(
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      isRequired: true,
    );

    offlineCustomerSearch = GenericOfflineSearchController<CustomerModel>(
      fetchAllFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      localFilterFunction: (customer, query) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      },
      isRequired: true,
    );

    offlineMultiBranchSearch = GenericMultiOfflineSearchController<CustomerModel>(
      fetchAllFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      localFilterFunction: (customer, query) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      },
      isRequired: true,
    );

    hideZeroBalancesFilter = GenericCheckboxController(
      defaultValue: true,
    );

    advancedSettingsGroup = FilterGroupController(
      dependencies: [mainCategoryFilter],
      titleBuilder: () {
        final selectedCategory = mainCategoryFilter.tempValue;
        if (selectedCategory == null) {
          return "إعدادات متقدمة (اختر تصنيفاً أولاً)";
        }
        return "إعدادات مخصصة لـ (${selectedCategory.name})";
      },
      childrenFilters: [
        subCategoryRangeFilter,
        hideZeroBalancesFilter,
      ],
      // 🛠️ تم الإصلاح: حذف isExpandable لكي لا يسبب خطأ Compile
      isVisible: () => mainCategoryFilter.tempValue != null,
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    mainCategoryFilter,
    subCategoryRangeFilter,
    mainCustomerSearch,
    customerRangeSearch,
    multiCustomerSearch,
    multiRangeCustomerSearch,
    offlineCustomerSearch,
    offlineMultiBranchSearch,
    hideZeroBalancesFilter,
    advancedSettingsGroup,
  ];

  @override
  Future<List<String>> fetchReportData() async {
    final mainCust = mainCustomerSearch.appliedValue;
    final rangeCust = customerRangeSearch.appliedValue;

    return [
      "العميل الأب: ${mainCust?.name ?? '---'}",
      "نطاق الفروع من: ${rangeCust?.fromValue?.name ?? '---'}",
      "نطاق الفروع إلى: ${rangeCust?.toValue?.name ?? '---'}",
    ];
  }
}
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_checkbox_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_offline_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';
import 'package:test_high_level_draft_algorithm/simple/repos/api_repository.dart';

class ReportTwoStrategy implements ReportStrategy<String> {
  @override
  String get reportTitle => "تقرير الترابط الديناميكي المتقدم";

  final ApiRepository repo = ApiRepository();

  late final GenericDropdownController<CategoryModel> _mainCategoryFilter;
  late final GenericDropdownRangeController<CategoryModel> _subCategoryRangeFilter;
  late final GenericSearchController<CustomerModel> _mainCustomerSearch;
  late final GenericSearchRangeController<CustomerModel> _customerRangeSearch;
  late final GenericMultiSearchController<CustomerModel> _multiCustomerSearch;
  late final GenericMultiSearchRangeController<CustomerModel> _multiRangeCustomerSearch;
  late final GenericOfflineSearchController<CustomerModel> _offlineCustomerSearch;
  late final GenericMultiOfflineSearchController<CustomerModel> _offlineMultiBranchSearch;
  late final GenericCheckboxController _hideZeroBalancesFilter;
  late final FilterGroupController _advancedSettingsGroup;

  ReportTwoStrategy() {
    _mainCategoryFilter = GenericDropdownController<CategoryModel>(
      labelText: "التصنيف الرئيسي",
      // 🔥 تمرير
      fetchFunction: ({bool forceReload = false}) => repo.fetchCategories(),
      isRequired: true,
      itemLabelBuilder: (category) => category.name,
    );

    _subCategoryRangeFilter = GenericDropdownRangeController<CategoryModel>(
      labelText: "نطاق التصنيفات الفرعية",
      fromLabelText: "من فرعي",
      toLabelText: "إلى فرعي",
      // 🔥 تمرير
      fetchFunction: ({bool forceReload = false}) => repo.fetchSubCategories(_mainCategoryFilter.tempValue!.id),
      itemLabelBuilder: (category) => category.name,
      dependencies: [_mainCategoryFilter],
      isVisible: () {
        final parentValue = _mainCategoryFilter.tempValue;
        final parentItems = _mainCategoryFilter.items;
        if (parentValue == null || parentItems.isEmpty) return false;
        return parentValue != parentItems.last;
      },
    );

    _mainCustomerSearch = GenericSearchController<CustomerModel>(
      labelText: "اختيار العميل الرئيسي",
      hintText: "ابحث عن العميل الأب...",
      // 🔥 تمرير
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
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

    _customerRangeSearch = GenericSearchRangeController<CustomerModel>(
      labelText: "نطاق الفروع/المناديب",
      fromLabelText: "من فرع",
      toLabelText: "إلى فرع",
      hintText: "بحث...",
      // 🔥 تمرير
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchRelatedCustomers(_mainCustomerSearch.tempValue!.id),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name),
        leading: const Icon(Icons.location_on),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),
      dependencies: [_mainCustomerSearch],
      isVisible: () => _mainCustomerSearch.tempValue != null,
    );

    _multiCustomerSearch = GenericMultiSearchController<CustomerModel>(
      labelText: "تحديد الفروع أو المناديب",
      hintText: "اضغط لاختيار أكثر من فرع...",
      // 🔥 إذا كانت repo.fetchCustomers تُعرّف هكذا `fetchCustomers({bool forceReload = false})`
      // فيمكنك إبقاء الاختصار `initialFetchFunction: repo.fetchCustomers`,
      // وإلا نكتبها بشكل صريح لتوافق التوقيع الجديد:
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        selectedTileColor: Colors.blue.shade50,
        title: Text(customer.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(customer.phone),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (val) {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      isRequired: true,
    );

    _multiRangeCustomerSearch = GenericMultiSearchRangeController<CustomerModel>(
      labelText: "نطاقات العملاء المتعددة",
      fromLabelText: "من عميل",
      toLabelText: "إلى عميل",
      hintText: "اختر...",
      // 🔥 تمرير
      initialFetchFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      searchFunction: (query) => repo.searchCustomers(query),
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),
      isRequired: true,
    );

    _offlineCustomerSearch = GenericOfflineSearchController<CustomerModel>(
      labelText: "اختر العميل (بحث سريع)",
      hintText: "ابحث بالاسم أو الرقم...",
      // 🔥 تمرير
      fetchAllFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      localFilterFunction: (customer, query) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      },
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(customer.phone),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),
      isRequired: true,
    );

    _offlineMultiBranchSearch = GenericMultiOfflineSearchController<CustomerModel>(
      labelText: "تحديد الفروع المعنية (بحث سريع)",
      hintText: "اضغط لاختيار فروع...",
      showReloadButton: false,
      // 🔥 تمرير
      fetchAllFunction: ({bool forceReload = false}) => repo.fetchCustomers(),
      localFilterFunction: (customer, query) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      },
      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        selectedTileColor: Colors.blue.shade50,
        title: Text(customer.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(customer.phone),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (val) {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      isRequired: true,
    );

    _hideZeroBalancesFilter = GenericCheckboxController(
      labelText: "إخفاء الأرصدة الصفرية من التقرير",
      defaultValue: true,
    );

    _advancedSettingsGroup = FilterGroupController(
      dependencies: [_mainCategoryFilter],
      titleBuilder: () {
        final selectedCategory = _mainCategoryFilter.tempValue;
        if (selectedCategory == null) {
          return "إعدادات متقدمة (اختر تصنيفاً أولاً)";
        }
        return "إعدادات مخصصة لـ (${selectedCategory.name})";
      },
      childrenFilters: [
        _subCategoryRangeFilter,
        _hideZeroBalancesFilter,
      ],
      isExpandable: true,
      isVisible: () => _mainCategoryFilter.tempValue != null,
    );
  }

  @override
  List<BaseFilterController> get filterControllers => [
    _mainCategoryFilter,
    _subCategoryRangeFilter,
    _mainCustomerSearch,
    _customerRangeSearch,
    _multiCustomerSearch,
    _multiRangeCustomerSearch,
    _offlineCustomerSearch,
    _offlineMultiBranchSearch,
    _hideZeroBalancesFilter,
    _advancedSettingsGroup,
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
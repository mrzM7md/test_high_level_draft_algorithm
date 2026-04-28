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

  // 1. فلاتر التصنيفات (الموجودة مسبقاً)
  late final GenericDropdownController<CategoryModel> _mainCategoryFilter;
  late final GenericDropdownRangeController<CategoryModel> _subCategoryRangeFilter;

  // 2. الفلاتر الجديدة: البحث المترابط
  late final GenericSearchController<CustomerModel> _mainCustomerSearch;
  late final GenericSearchRangeController<CustomerModel> _customerRangeSearch;
  late final GenericMultiSearchController<CustomerModel> _multiCustomerSearch;
  late final GenericMultiSearchRangeController<CustomerModel> _multiRangeCustomerSearch;
  late final GenericOfflineSearchController<CustomerModel> _offlineCustomerSearch;
  late final GenericMultiOfflineSearchController<CustomerModel> _offlineMultiBranchSearch;
  late final GenericCheckboxController _hideZeroBalancesFilter;
  late final FilterGroupController _advancedSettingsGroup;

  ReportTwoStrategy() {
    // --- قسم التصنيفات ---
    _mainCategoryFilter = GenericDropdownController<CategoryModel>(
      labelText: "التصنيف الرئيسي",
      fetchFunction: () => repo.fetchCategories(),
      isRequired: true,
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

    _multiCustomerSearch = GenericMultiSearchController<CustomerModel>(
      labelText: "تحديد الفروع أو المناديب",
      hintText: "اضغط لاختيار أكثر من فرع...",

      // الدوال المعتادة للبحث وجلب البيانات
      initialFetchFunction: repo.fetchCustomers,
      searchFunction: (query) => repo.searchCustomers(query),

      // لاستخراج النص في الـ Chips الصغيرة
      selectedItemLabel: (customer) => customer.name,

      // تصميم العنصر في قائمة البحث
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        selectedTileColor: Colors.blue.shade50,
        title: Text(customer.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(customer.phone),
        // عرض مربع اختيار (Checkbox) ليكون أوضح للمستخدم
        trailing: Checkbox(
          value: isSelected,
          onChanged: (val) {}, // يتم التحكم به عبر onTap الخاص بالـ InkWell
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      isRequired: true, // يدعم الـ Validation تلقائياً!
    );

    _multiRangeCustomerSearch = GenericMultiSearchRangeController<CustomerModel>(
      labelText: "نطاقات العملاء المتعددة",
      fromLabelText: "من عميل",
      toLabelText: "إلى عميل",
      hintText: "اختر...",

      initialFetchFunction: repo.fetchCustomers,

      // initialFetchFunction: () async {
      //   final result = await repo.fetchCustomersEither();
      //   return result.fold(
      //         (fail) => throw FilterFetchException(fail.message),
      //         (data) => data,
      //   );
      // },

      searchFunction: (query) => repo.searchCustomers(query),

      selectedItemLabel: (customer) => customer.name,
      itemBuilder: (customer, isSelected) => ListTile(
        selected: isSelected,
        title: Text(customer.name),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      ),
      isRequired: true, // يدعم الإجبار الذكي!
    );

    _offlineCustomerSearch = GenericOfflineSearchController<CustomerModel>(
      labelText: "اختر العميل (بحث سريع)",
      hintText: "ابحث بالاسم أو الرقم...",

      fetchAllFunction: repo.fetchCustomers,
      // 1. الدالة التي تجلب كل البيانات دفعة واحدة (تستدعى مرة واحدة)
      // fetchAllFunction: () async {
      //   final result = await repo.fetchCustomersEither();
      //   return result.fold(
      //         (fail) => throw FilterFetchException(fail.message),
      //         (data) => data,
      //   );
      // },

      // 2. السحر هنا: كيف تبحث في البيانات المجلوبة؟ (بدون إنترنت)
      localFilterFunction: (customer, query) {
        // يمكنك البحث في أكثر من حقل (الاسم أو رقم الهاتف)
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
      // جلب البيانات مرة واحدة فقط
      fetchAllFunction: repo.fetchCustomers,

      // fetchAllFunction: () async {
      //   final result = await repo.fetchCustomersEither();
      //   return result.fold(
      //         (fail) => throw FilterFetchException(fail.message),
      //         (data) => data,
      //   );
      // },

      // الفلترة تتم محلياً بسرعة البرق بمجرد كتابة أي حرف
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

    // داخل المشيد (Constructor)
    _hideZeroBalancesFilter = GenericCheckboxController(
      labelText: "إخفاء الأرصدة الصفرية من التقرير",
      defaultValue: true,
    );

    _advancedSettingsGroup = FilterGroupController(
      // نربطه بحقل التصنيف الرئيسي لكي يستمع لتغيراته
      dependencies: [_mainCategoryFilter],

      // نحدد كيف يُبنى العنوان بناءً على القيمة الحالية
      titleBuilder: () {
        final selectedCategory = _mainCategoryFilter.tempValue;
        if (selectedCategory == null) {
          return "إعدادات متقدمة (اختر تصنيفاً أولاً)";
        }
        return "إعدادات مخصصة لـ (${selectedCategory.name})";
      },

      // نضع الحقول التي نريدها داخل الصندوق
      childrenFilters: [
        _subCategoryRangeFilter,
        _hideZeroBalancesFilter, // حقل الـ Checkbox الذي صنعناه
      ],
      isExpandable: true, // سيكون صندوقاً قابلاً للطي

      // يمكنك حتى إخفاء الصندوق بالكامل إذا لم يتم اختيار تصنيف!
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
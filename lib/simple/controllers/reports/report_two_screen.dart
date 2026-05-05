import 'package:flutter/material.dart';

// تأكد من مطابقة هذه المسارات لمشروعك
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/check_box/generic_checkbox_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_offline_search/generic_multi_offline_search_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search/generic_multi_search_widgetr.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range/generic_multi_search_range_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_offline_search/generic_offline_search_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_two_strategy.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';

class ReportTwoScreen extends StatefulWidget {
  final ReportTwoStrategy strategy;

  const ReportTwoScreen({super.key, required this.strategy});

  @override
  State<ReportTwoScreen> createState() => _ReportTwoScreenState();
}

class _ReportTwoScreenState extends State<ReportTwoScreen> {

  Widget _customerItemBuilder(CustomerModel customer, bool isSelected) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.indigo.shade50,
      title: Text(customer.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(customer.phone),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.indigo) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strategy.reportTitle),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          GenericDropdownWidget<CategoryModel>(
            controller: widget.strategy.mainCategoryFilter,
            labelText: "التصنيف الرئيسي",
            itemLabelBuilder: (cat) => cat.name,
          ),

          // 🛠️ تم الإصلاح: مسح كود بناء الكروت اليدوي واستخدام الكلاس الجاهز مباشرة
          FilterGroupWidget(
            controller: widget.strategy.advancedSettingsGroup,
            isExpandable: true,
            headerColor: Colors.indigo,
            childrenWidgets: [
              GenericDropdownRangeWidget<CategoryModel>(
                controller: widget.strategy.subCategoryRangeFilter,
                labelText: "نطاق التصنيفات الفرعية",
                fromLabelText: "من فرعي",
                toLabelText: "إلى فرعي",
                itemLabelBuilder: (cat) => cat.name,
              ),
              GenericCheckboxWidget(
                controller: widget.strategy.hideZeroBalancesFilter,
                labelText: "إخفاء الأرصدة الصفرية من التقرير",
              ),
            ],
          ),

          const Divider(height: 30),

          GenericSearchWidget<CustomerModel>(
            controller: widget.strategy.mainCustomerSearch,
            labelText: "اختيار العميل الرئيسي",
            hintText: "ابحث عن العميل الأب...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          GenericSearchRangeWidget<CustomerModel>(
            controller: widget.strategy.customerRangeSearch,
            labelText: "نطاق الفروع/المناديب",
            fromLabelText: "من فرع",
            toLabelText: "إلى فرع",
            hintText: "بحث...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          const Divider(height: 30),

          GenericMultiSearchWidget<CustomerModel>(
            controller: widget.strategy.multiCustomerSearch,
            labelText: "تحديد الفروع أو المناديب",
            hintText: "اضغط لاختيار أكثر من فرع...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: (customer, isSelected) => ListTile(
              selected: isSelected,
              title: Text(customer.name),
              trailing: Checkbox(value: isSelected, onChanged: (_) {}),
            ),
          ),

          GenericMultiSearchRangeWidget<CustomerModel>(
            controller: widget.strategy.multiRangeCustomerSearch,
            labelText: "نطاقات العملاء المتعددة",
            fromLabelText: "من عميل",
            toLabelText: "إلى عميل",
            hintText: "اختر...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          const Divider(height: 30),

          GenericOfflineSearchWidget<CustomerModel>(
            controller: widget.strategy.offlineCustomerSearch,
            labelText: "اختر العميل (بحث سريع)",
            hintText: "ابحث بالاسم أو الرقم...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          GenericMultiOfflineSearchWidget<CustomerModel>(
            controller: widget.strategy.offlineMultiBranchSearch,
            labelText: "تحديد الفروع المعنية (بحث سريع)",
            hintText: "اضغط لاختيار فروع...",
            showReloadButton: false,
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: (customer, isSelected) => ListTile(
              selected: isSelected,
              title: Text(customer.name),
              trailing: Checkbox(value: isSelected, onChanged: (_) {}),
            ),
          ),

          const SizedBox(height: 30),

          // زر التطبيق
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              bool isValid = true;
              for (var controller in widget.strategy.filterControllers) {
                if (!controller.validate()) isValid = false;
              }

              if (isValid) {
                // 🛠️ تم الإصلاح: استخدام commit بدلاً من النقل المباشر لتجنب مشكلة Pass-by-Reference
                for (var controller in widget.strategy.filterControllers) {
                  controller.commit();
                }

                // 🛠️ تم الإصلاح: إعطاء النافذة سياقها الخاص لحمايتها من الانهيار
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
                );

                final reportData = await widget.strategy.fetchReportData();

                if (mounted) {
                  // 🛠️ إغلاق نافذة التحميل بأمان
                  Navigator.of(context, rootNavigator: true).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم جلب ${reportData.length} أسطر بنجاح!")),
                  );
                }
              }
            },
            child: const Text("تطبيق الفلاتر وبحث", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
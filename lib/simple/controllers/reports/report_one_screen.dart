import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker/generic_date_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text/generic_text_widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/numeric_field/generic_number_controller.widget.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_one_strategy.dart';
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';

class ReportOneScreen extends StatefulWidget {
  const ReportOneScreen({super.key, required this.strategy});
  final ReportOneStrategy strategy;

  @override
  State<ReportOneScreen> createState() => _ReportOneScreenState();
}

class _ReportOneScreenState extends State<ReportOneScreen> {

  // تصميم موحد لعناصر قائمة العملاء لإعادة استخدامه
  Widget _customerItemBuilder(CustomerModel customer, bool isSelected) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strategy.reportTitle),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. ربط الواجهات بالكنترولرات النقية وتخصيص النصوص والتصميم

          GenericDateRangeWidget(
            controller: widget.strategy.dateRangeFilter,
            labelText: "فترة الفواتير",
            fromLabelText: "من تاريخ",
            toLabelText: "حتى تاريخ",
          ),

          GenericDateWidget(
            controller: widget.strategy.singleDateFilter,
            labelText: "تاريخ الاستحقاق",
            hintText: "اضغط لتحديد التاريخ...",
          ),

          const Divider(height: 30),

          GenericDropdownWidget<CategoryModel>(
            controller: widget.strategy.categoryFilter,
            labelText: "اختر التصنيف",
            itemLabelBuilder: (cat) => cat.name,
            decoration: InputDecoration(
              labelText: "اختر التصنيف",
              filled: true, fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          GenericDropdownRangeWidget<CategoryModel>(
            controller: widget.strategy.categoryRangeFilter,
            labelText: "نطاق التصنيفات",
            fromLabelText: "من تصنيف",
            toLabelText: "إلى تصنيف",
            itemLabelBuilder: (cat) => cat.name,
          ),

          const Divider(height: 30),

          GenericSearchWidget<CustomerModel>(
            controller: widget.strategy.customerFilter,
            labelText: "العميل (بحث مفرد)",
            hintText: "اضغط للبحث عن عميل...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          GenericSearchRangeWidget<CustomerModel>(
            controller: widget.strategy.customerRangeFilter,
            labelText: "نطاق العملاء (أونلاين)",
            fromLabelText: "من عميل",
            toLabelText: "إلى عميل",
            hintText: "اختر...",
            selectedItemLabel: (customer) => customer.name,
            itemBuilder: _customerItemBuilder,
          ),

          const Divider(height: 30),

          GenericTextWidget(
            controller: widget.strategy.noteFilter,
            labelText: "ملاحظات الفاتورة",
            hintText: "ابحث بكلمة في الملاحظات...",
          ),

          GenericNumberWidget(
            controller: widget.strategy.amountFilter,
            labelText: "مبلغ الفاتورة (أكبر من)",
            hintText: "0.0",
          ),

          const SizedBox(height: 30),

          // زر التطبيق (يتواصل مع الـ widget.strategy للتحقق وجلب البيانات)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // التحقق من صحة جميع الفلاتر
              bool isValid = true;
              for (var controller in widget.strategy.filterControllers) {
                if (!controller.validate()) isValid = false;
              }

              if (isValid) {
                // تطبيق الفلاتر وجلب التقرير
                for (var controller in widget.strategy.filterControllers) {
                  controller.appliedValue = controller.tempValue;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                final reportData = await widget.strategy.fetchReportData();

                Navigator.pop(context); // إغلاق مؤشر التحميل

                // عرض النتيجة
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم جلب ${reportData.length} أسطر من التقرير بنجاح!")),
                );
              }
            },
            child: const Text("تطبيق الفلاتر وعرض التقرير", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
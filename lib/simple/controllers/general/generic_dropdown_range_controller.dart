import 'package:flutter/material.dart';
import '../base/base_filter_controller.dart';
import '../../models/dropdown_range.dart';

class GenericDropdownRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  
  // مفوضات جلب وعرض البيانات (نفس فكرة الـ Dropdown العادي)
  final Future<List<T>> Function() fetchFunction;
  final String Function(T item) itemLabelBuilder;

  // إدارة الحالة الداخلية للبيانات (Caching)
  List<T> _items = [];
  bool _isLoading = false;

  GenericDropdownRangeController({
    required this.labelText,
    required this.fetchFunction,
    required this.itemLabelBuilder,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    super.defaultValue,
  });

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await refreshData(isInitialLoad: true);
  }

  // التحديث مع ميزة "الاحتفاظ بالاختيار" (Stale-While-Revalidate)
  Future<void> refreshData({bool isInitialLoad = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newData = await fetchFunction();

      // الحفاظ على القيم المختارة (من وإلى) إذا كانت موجودة
      if (tempValue != null) {
        T? newFrom = tempValue?.fromValue;
        T? newTo = tempValue?.toValue;

        // التحقق من "من"
        if (newFrom != null) {
          if (!newData.contains(newFrom)) {
            newData.insert(0, newFrom);
          } else {
            newFrom = newData.firstWhere((e) => e == newFrom);
          }
        }
        // التحقق من "إلى"
        if (newTo != null) {
          if (!newData.contains(newTo)) {
            newData.insert(0, newTo);
          } else {
            newTo = newData.firstWhere((e) => e == newTo);
          }
        }

        // تحديث المراجع في الذاكرة
        final updatedRange = DropdownRange<T>(fromValue: newFrom, toValue: newTo);
        tempValue = updatedRange;
        if (appliedValue != null) appliedValue = updatedRange;
      }

      _items = newData;
    } catch (e) {
      // التعامل مع الخطأ بصمت للحفاظ على استقرار الواجهة
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          // استخدام InputDecorator لتوحيد التصميم مع باقي الحقول
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              // تقليل الارتفاع الداخلي قليلاً ليناسب الـ Dropdowns
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                    onPressed: () => refreshData(),
                  ),
                  if (tempValue?.fromValue != null || tempValue?.toValue != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => clear(),
                    ),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: fromLabelText,
                    value: tempValue?.fromValue,
                    isFrom: true,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 30, color: Colors.grey.shade300), // الخط الفاصل الأنيق
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: toLabelText,
                    value: tempValue?.toValue,
                    isFrom: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // الـ Widget الداخلي لبناء كل Dropdown بدون خط سفلي
  Widget _buildDropdown(BuildContext context, {required String label, required T? value, required bool isFrom}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true, // مهم جداً لمنع الـ Overflow
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.blue),
            value: _items.contains(value) ? value : null,
            hint: const Text("اختر...", style: TextStyle(fontSize: 13)),
            items: _items.map((item) => DropdownMenuItem(
              value: item,
              // قطع النص الطويل بـ ellipsis لتجنب كسر الشاشة
              child: Text(
                itemLabelBuilder(item), 
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), 
                overflow: TextOverflow.ellipsis
              ),
            )).toList(),
            onChanged: (val) {
              final current = tempValue ?? DropdownRange<T>();
              // تحديث القيمة (من أو إلى) مع الحفاظ على القيمة الأخرى
              updateTemp(DropdownRange<T>(
                fromValue: isFrom ? val : current.fromValue,
                toValue: !isFrom ? val : current.toValue,
              ));
            },
          ),
        ),
      ],
    );
  }
}
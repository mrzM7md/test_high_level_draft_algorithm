// --- generic_date_controller.dart ---
import 'package:flutter/material.dart';
import '../base/base_filter_controller.dart';

class GenericDateController extends BaseFilterController<DateTime> {
  final String labelText;
  final String hintText;
  
  // حدود التواريخ المسموحة
  final DateTime? firstDate;
  final DateTime? lastDate;

  GenericDateController({
    required this.labelText,
    this.hintText = "اختر التاريخ...",
    super.defaultValue,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          // توحيد التصميم باستخدام InputDecorator
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              // أيقونات التحكم جهة اليسار
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر المسح (يظهر فقط إذا كان هناك قيمة)
                  if (tempValue != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => clear(),
                    ),
                  const Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            child: InkWell(
              onTap: () => _pickDate(context),
              child: Text(
                tempValue != null 
                    ? "${tempValue!.year}-${tempValue!.month.toString().padLeft(2, '0')}-${tempValue!.day.toString().padLeft(2, '0')}" 
                    : hintText,
                style: TextStyle(
                  fontWeight: tempValue != null ? FontWeight.bold : FontWeight.normal,
                  color: tempValue != null ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tempValue ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    
    if (picked != null) {
      updateTemp(picked);
    }
  }
}
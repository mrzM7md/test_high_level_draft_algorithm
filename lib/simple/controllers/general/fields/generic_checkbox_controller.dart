import 'package:flutter/material.dart';
import '../../base/base_filter_controller.dart';

class GenericCheckboxController extends BaseFilterController<bool> {
  final String labelText;

  GenericCheckboxController({
    required this.labelText,
    bool defaultValue = false, // القيمة الافتراضية دائماً false (غير محدد)
    super.dependencies,
    super.isVisible,
    super.isRequired, // اختياري كباقي الحقول
  }) : super(defaultValue: defaultValue) {
    // التأكد من أن القيم الأولية ليست Null بل False كحالة منطقية سليمة
    tempValue ??= false;
    appliedValue ??= false;
  }

  @override
  void clear() {
    // مسح الفلتر يعني إعادته لحالة عدم التحديد (false)
    super.updateTemp(false);
    validationError = null;
    notifyListeners();
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        final currentValue = tempValue ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: validationError, // سيعمل فقط إذا تم تمرير null بطريقة ما
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
            child: InkWell(
              // لجعل كامل الإطار قابلاً للضغط وليس المربع فقط
              onTap: () => updateTemp(!currentValue),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Checkbox(
                    value: currentValue,
                    onChanged: (val) => updateTemp(val ?? false),
                    activeColor: Colors.blue,
                  ),
                  Expanded(
                    child: Text(
                      labelText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: currentValue ? FontWeight.bold : FontWeight.normal,
                        color: currentValue ? Colors.blue.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
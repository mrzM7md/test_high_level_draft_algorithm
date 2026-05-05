import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/check_box/generic_checkbox_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/check_box/generic_checkbox_style.dart';
// استيراد الستايل

class GenericCheckboxWidget extends StatelessWidget {
  final GenericCheckboxController controller;
  final String labelText;
  final GenericCheckboxStyle? style;

  // 🚀 التحديث العبقري: تمرير الكنترولر للبنّاء ليمنح المبرمج قوة مطلقة (Clear, Update, Validate)
  final Widget Function(
      BuildContext context,
      bool isChecked,
      GenericCheckboxController controller // 👈 السلاح السري
      )? customBuilder;

  const GenericCheckboxWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.style,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (style ?? const GenericCheckboxStyle()).mergeWithDefault(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();

        final currentValue = controller.tempValue ?? false;

        // 🚀 السحر 1: هل نستخدم البناء المخصص؟
        if (customBuilder != null) {
          // المبرمج لديه الكنترولر الآن، يمكنه استدعاء controller.clear() داخل تصميمه!
          return customBuilder!(context, currentValue, controller);
        }

        // 🚀 السحر 2: الواجهة الذكية الافتراضية (Auto-Suffix Actions)
        Widget? suffixActions;

        // إذا كانت القيمة true، نظهر زر المسح (Clear) تلقائياً!
        if (currentValue == true) {
          suffixActions = IconButton(
            icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
            onPressed: () => controller.clear(), // زر مسح مدمج ومجاني!
            splashRadius: 20,
          );
        }

        return Padding(
          padding: appliedStyle.padding!,
          child: InputDecorator(
            decoration: appliedStyle.decoration!.copyWith(
              errorText: controller.validationError,
              // دمج الأزرار التلقائية في الديكور
              suffixIcon: suffixActions,
            ),
            child: InkWell(
              onTap: () => controller.updateTemp(!currentValue),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Checkbox(
                    value: currentValue,
                    onChanged: (val) => controller.updateTemp(val ?? false),
                    activeColor: appliedStyle.activeColor,
                    checkColor: appliedStyle.checkColor,
                  ),
                  Expanded(
                    child: Text(
                      labelText,
                      style: currentValue
                          ? appliedStyle.activeTextStyle
                          : appliedStyle.defaultTextStyle,
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
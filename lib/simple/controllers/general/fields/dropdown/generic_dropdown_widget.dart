// generic_dropdown_widget.dart
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown/generic_dropdown_controller.dart';


class GenericDropdownWidget<T> extends StatelessWidget {
  final GenericDropdownController<T> controller;

  final String Function(T item) itemLabelBuilder;

  final String? labelText;
  final InputDecoration? decoration;
  final bool showReloadButton;
  final Widget? customLoadingIndicator;
  final Icon? customReloadIcon;
  final Icon? customClearIcon;

  const GenericDropdownWidget({
    super.key,
    required this.controller,
    required this.itemLabelBuilder,
    this.labelText,
    this.decoration,
    this.showReloadButton = true,
    this.customLoadingIndicator,
    this.customReloadIcon,
    this.customClearIcon,
  });

  @override
  Widget build(BuildContext context) {
    // التأكد من جلب البيانات عند بناء الواجهة[cite: 16]
    controller.ensureDataLoaded();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // إدارة الظهور والاختفاء (isVisible) تتم هنا في الواجهة!
        if (controller.isVisible != null && !controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<T>(
            // استخدام تصميم المستخدم إذا وُجد، أو التصميم الافتراضي
            decoration: decoration ?? InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: controller.errorMessage ?? controller.validationError,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.isLoading)
                    customLoadingIndicator ?? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),

                  if (showReloadButton)
                    IconButton(
                        icon: customReloadIcon ?? const Icon(Icons.refresh, color: Colors.blue, size: 20),
                        onPressed: () => controller.refreshData(forceReload: true)
                    ),

                  if (controller.tempValue != null)
                    IconButton(
                        icon: customClearIcon ?? const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () => controller.clear()
                    ),
                ],
              ),
            ),
            value: controller.items.contains(controller.tempValue) ? controller.tempValue : null,
            items: controller.items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(itemLabelBuilder(item))
            )).toList(),
            onChanged: (val) => controller.updateTemp(val), // تحديث القيمة في الكنترولر[cite: 16]
          ),
        );
      },
    );
  }
}
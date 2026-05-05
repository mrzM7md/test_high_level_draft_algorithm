import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/check_box/generic_checkbox_controller.dart';

class GenericCheckboxWidget extends StatelessWidget {
  final GenericCheckboxController controller;
  final String labelText;
  final InputDecoration? decoration;

  const GenericCheckboxWidget({super.key, required this.controller, required this.labelText, this.decoration});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();

        final currentValue = controller.tempValue ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: decoration ?? InputDecoration(
              border: const OutlineInputBorder(),
              errorText: controller.validationError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
            child: InkWell(
              onTap: () => controller.updateTemp(!currentValue),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Checkbox(value: currentValue, onChanged: (val) => controller.updateTemp(val ?? false), activeColor: Colors.blue),
                  Expanded(
                    child: Text(
                      labelText,
                      style: TextStyle(fontSize: 14, fontWeight: currentValue ? FontWeight.bold : FontWeight.normal, color: currentValue ? Colors.blue.shade800 : Colors.black87),
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

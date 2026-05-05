import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/dropdown_range/generic_dropdown_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';

class GenericDropdownRangeWidget<T> extends StatelessWidget {
  final GenericDropdownRangeController<T> controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String Function(T item) itemLabelBuilder;
  final bool showReloadButton;

  const GenericDropdownRangeWidget({super.key, required this.controller, required this.labelText, required this.itemLabelBuilder, this.fromLabelText = "من", this.toLabelText = "إلى", this.showReloadButton = true});

  @override
  Widget build(BuildContext context) {
    controller.ensureDataLoaded();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText, border: const OutlineInputBorder(), errorText: controller.errorMessage ?? controller.validationError,
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                if (controller.isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                if (showReloadButton && !controller.isLoading) IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => controller.refreshData(forceReload: true)),
                if (controller.tempValue?.fromValue != null || controller.tempValue?.toValue != null) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()),
              ]),
            ),
            child: Row(
              children: [
                Expanded(child: _buildDropdown(label: fromLabelText, value: controller.tempValue?.fromValue, isFrom: true)),
                Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                Expanded(child: _buildDropdown(label: toLabelText, value: controller.tempValue?.toValue, isFrom: false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({required String label, required T? value, required bool isFrom}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true, isDense: true, icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.blue),
            value: controller.items.contains(value) ? value : null,
            hint: const Text("اختر...", style: TextStyle(fontSize: 13)),
            items: controller.items.map((item) => DropdownMenuItem(value: item, child: Text(itemLabelBuilder(item), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (val) {
              final current = controller.tempValue ?? DropdownRange<T>();
              controller.updateTemp(DropdownRange<T>(fromValue: isFrom ? val : current.fromValue, toValue: !isFrom ? val : current.toValue));
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker/generic_date_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/date_picker_range/generic_date_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';

class GenericDateWidget extends StatelessWidget {
  final GenericDateController controller;
  final String labelText;
  final String hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const GenericDateWidget({super.key, required this.controller, required this.labelText, this.hintText = "اختر التاريخ...", this.firstDate, this.lastDate});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: controller.tempValue ?? DateTime.now(), firstDate: firstDate ?? DateTime(2000), lastDate: lastDate ?? DateTime(2100));
    if (picked != null) controller.updateTemp(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();
        final temp = controller.tempValue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText, border: const OutlineInputBorder(), errorText: controller.validationError,
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                if (temp != null) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()),
                const Icon(Icons.calendar_month, color: Colors.blue, size: 20), const SizedBox(width: 8),
              ]),
            ),
            child: InkWell(
              onTap: () => _pickDate(context),
              child: Text(temp != null ? "${temp.year}-${temp.month.toString().padLeft(2,'0')}-${temp.day.toString().padLeft(2,'0')}" : hintText, style: TextStyle(fontWeight: temp != null ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
        );
      },
    );
  }
}

class GenericDateRangeWidget extends StatelessWidget {
  final GenericDateRangeController controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const GenericDateRangeWidget({super.key, required this.controller, required this.labelText, this.fromLabelText = "من", this.toLabelText = "إلى", this.firstDate, this.lastDate});

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: isFrom ? (controller.tempValue?.fromDate ?? now) : (controller.tempValue?.toDate ?? now), firstDate: firstDate ?? DateTime(2000), lastDate: lastDate ?? DateTime(2100));
    if (picked != null) {
      final current = controller.tempValue ?? DateRange(fromDate: picked, toDate: picked);
      controller.updateTemp(DateRange(fromDate: isFrom ? picked : current.fromDate, toDate: !isFrom ? picked : current.toDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder(), errorText: controller.validationError, suffixIcon: controller.tempValue != null ? IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()) : null),
            child: Row(
              children: [
                Expanded(child: InkWell(onTap: () => _pickDate(context, isFrom: true), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(fromLabelText, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text(controller.tempValue?.fromDate.toString().split(' ')[0] ?? "---", style: const TextStyle(fontWeight: FontWeight.bold))]))),
                Container(width: 1, height: 30, color: Colors.grey.shade300), const SizedBox(width: 8),
                Expanded(child: InkWell(onTap: () => _pickDate(context, isFrom: false), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(toLabelText, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text(controller.tempValue?.toDate.toString().split(' ')[0] ?? "---", style: const TextStyle(fontWeight: FontWeight.bold))]))),
              ],
            ),
          ),
        );
      },
    );
  }
}
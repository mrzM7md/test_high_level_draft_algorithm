import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';
import '../../base/base_filter_controller.dart';

class GenericDateRangeController extends BaseFilterController<DateRange> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  GenericDateRangeController({
    required this.labelText,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    DateRange? defaultRange,
    this.firstDate,
    this.lastDate,
    super.dependencies,
    super.isVisible,
    super.isRequired, // 🔥 إضافة الخاصية
  }) : super(defaultValue: defaultRange);

  @override
  Widget buildFilterWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: validationError, // 🔥 عرض نص الخطأ
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: tempValue != null
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => clear(),
              )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    context,
                    label: fromLabelText,
                    date: tempValue?.fromDate,
                    isFrom: true,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateButton(
                    context,
                    label: toLabelText,
                    date: tempValue?.toDate,
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

  Widget _buildDateButton(BuildContext context, {required String label, required DateTime? date, required bool isFrom}) {
    return InkWell(
      onTap: () => _pickDate(context, isFrom: isFrom),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" : "---",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Icon(Icons.calendar_month, size: 16, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (tempValue?.fromDate ?? now) : (tempValue?.toDate ?? now),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      final current = tempValue ?? DateRange(fromDate: picked, toDate: picked);
      updateTemp(DateRange(
        fromDate: isFrom ? picked : current.fromDate,
        toDate: !isFrom ? picked : current.toDate,
      ));
    }
  }
}
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/models/data_range.dart';

class DateRangeFilterController extends BaseFilterController<DateRange> {
  @override
  Widget buildWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(tempValue?.fromDate.toString().split(' ')[0] ?? "من تاريخ"),
                  onPressed: () => _pickDate(context, isFrom: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(tempValue?.toDate.toString().split(' ')[0] ?? "إلى تاريخ"),
                  onPressed: () => _pickDate(context, isFrom: false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
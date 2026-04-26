import 'package:flutter/material.dart';
import '../../base/base_data_filter_controller.dart';

class GenericDropdownController<T> extends BaseDataFilterController<T> {
  final String labelText;
  final Future<List<T>> Function() fetchFunction;
  final String Function(T item) itemLabelBuilder;

  GenericDropdownController({
    required this.labelText,
    required this.fetchFunction,
    required this.itemLabelBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired, // 🔥 استلام الخاصية من الاستراتيجية
  });

  @override
  Future<List<T>> fetchDataFromServer() => fetchFunction();

  @override
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: validationError, // 🔥 السحر هنا: عرض رسالة الخطأ إن وُجدت
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData()),
                  if (tempValue != null) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                ],
              ),
            ),
            value: items.contains(tempValue) ? tempValue : null,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(itemLabelBuilder(item)))).toList(),
            onChanged: (val) => updateTemp(val),
          ),
        );
      },
    );
  }
}
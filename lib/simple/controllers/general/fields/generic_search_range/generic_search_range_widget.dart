
// --- 2. THE WIDGET ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search_range/generic_search_range_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/dropdown_range.dart';

class GenericSearchRangeWidget<T> extends StatelessWidget {
  final GenericSearchRangeController<T> controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String hintText;
  final String Function(T item) selectedItemLabel;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final bool showReloadButton;

  const GenericSearchRangeWidget({super.key, required this.controller, required this.labelText, this.fromLabelText = "من", this.toLabelText = "إلى", this.hintText = "بحث...", required this.selectedItemLabel, required this.itemBuilder, this.showReloadButton = true});

  void _openSearchSheet(BuildContext context, {required bool isFrom}) {
    controller.resetSearch();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: "بحث (${isFrom ? fromLabelText : toLabelText})...", prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()), onChanged: controller.onSearchQueryChanged),
              const SizedBox(height: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    if (controller.isSearching) return const Center(child: CircularProgressIndicator());
                    if (controller.searchResults.isEmpty) return const Center(child: Text("لا توجد نتائج."));
                    return ListView.builder(
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = controller.searchResults[index];
                        final isSelected = isFrom ? item == controller.tempValue?.fromValue : item == controller.tempValue?.toValue;
                        return InkWell(
                          onTap: () {
                            final current = controller.tempValue ?? DropdownRange<T>();
                            controller.updateTemp(DropdownRange<T>(fromValue: isFrom ? item : current.fromValue, toValue: !isFrom ? item : current.toValue));
                            Navigator.pop(sheetContext);
                          },
                          child: itemBuilder(item, isSelected),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                Expanded(child: _buildSearchButton(context, label: fromLabelText, value: controller.tempValue?.fromValue, isFrom: true)),
                Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                Expanded(child: _buildSearchButton(context, label: toLabelText, value: controller.tempValue?.toValue, isFrom: false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, {required String label, required T? value, required bool isFrom}) {
    return InkWell(
      onTap: () => _openSearchSheet(context, isFrom: isFrom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(value != null ? selectedItemLabel(value) : hintText, style: TextStyle(fontWeight: value != null ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.search, size: 16, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}
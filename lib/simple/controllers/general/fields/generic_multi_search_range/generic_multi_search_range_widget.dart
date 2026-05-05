import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search_range/generic_multi_search_range_controller.dart';

class GenericMultiSearchRangeWidget<T> extends StatelessWidget {
  final GenericMultiSearchRangeController<T> controller;
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String hintText;
  final String Function(T item) selectedItemLabel;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final bool showReloadButton;

  const GenericMultiSearchRangeWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "اختر...",
    required this.selectedItemLabel,
    required this.itemBuilder,
    this.showReloadButton = true,
  });

  void _openSearchSheet(BuildContext context, {required bool isFrom}) {
    controller.resetSearch();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
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
                    final currentList = isFrom ? (controller.tempValue?.fromValue ?? []) : (controller.tempValue?.toValue ?? []);
                    return ListView.builder(
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = controller.searchResults[index];
                        final isSelected = currentList.contains(item);
                        return InkWell(onTap: () => controller.toggleItem(item, isFrom: isFrom), child: itemBuilder(item, isSelected));
                      },
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity, padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) {
                        final count = isFrom ? (controller.tempValue?.fromValue?.length ?? 0) : (controller.tempValue?.toValue?.length ?? 0);
                        return Text(count > 0 ? "موافق ($count)" : "إغلاق");
                      }),
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
        final fromList = controller.tempValue?.fromValue ?? [];
        final toList = controller.tempValue?.toValue ?? [];
        final hasAnyItems = fromList.isNotEmpty || toList.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText, border: const OutlineInputBorder(), errorText: controller.errorMessage ?? controller.validationError,
                  suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (controller.isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    if (showReloadButton && !controller.isLoading) IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => controller.refreshData(forceReload: true)),
                    if (hasAnyItems) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()),
                  ]),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchButton(context, label: fromLabelText, count: fromList.length, isFrom: true)),
                    Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                    Expanded(child: _buildSearchButton(context, label: toLabelText, count: toList.length, isFrom: false)),
                  ],
                ),
              ),
              if (fromList.isNotEmpty) ...[
                const SizedBox(height: 10), Text("المختارة في ($fromLabelText):", style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                Wrap(spacing: 6.0, runSpacing: 4.0, children: fromList.map((item) => Chip(label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)), deleteIcon: const Icon(Icons.cancel, size: 16), onDeleted: () => controller.removeItem(item, isFrom: true), backgroundColor: Colors.blue.shade50, side: BorderSide(color: Colors.blue.shade200))).toList()),
              ],
              if (toList.isNotEmpty) ...[
                const SizedBox(height: 10), Text("المختارة في ($toLabelText):", style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                Wrap(spacing: 6.0, runSpacing: 4.0, children: toList.map((item) => Chip(label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)), deleteIcon: const Icon(Icons.cancel, size: 16), onDeleted: () => controller.removeItem(item, isFrom: false), backgroundColor: Colors.green.shade50, side: BorderSide(color: Colors.green.shade200))).toList()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, {required String label, required int count, required bool isFrom}) {
    return InkWell(
      onTap: () => _openSearchSheet(context, isFrom: isFrom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(count > 0 ? "مختار ($count)" : hintText, style: TextStyle(fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.search, size: 16, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}
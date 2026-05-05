import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_multi_search/generic_multi_search_controller.dart';

class GenericMultiSearchWidget<T> extends StatelessWidget {
  final GenericMultiSearchController<T> controller;
  final String labelText;
  final String hintText;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item) selectedItemLabel;
  final bool showReloadButton;

  const GenericMultiSearchWidget({super.key, required this.controller, required this.labelText, this.hintText = "ابحث واختر...", required this.itemBuilder, required this.selectedItemLabel, this.showReloadButton = true});

  void _openSearchSheet(BuildContext context) {
    controller.resetSearch();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          child: Column(
            children: [
              TextField(decoration: const InputDecoration(labelText: "بحث...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: controller.onSearchQueryChanged),
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
                        final isSelected = controller.tempValue?.contains(item) ?? false;
                        return InkWell(onTap: () => controller.toggleItem(item), child: itemBuilder(item, isSelected));
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
                  child: ListenableBuilder(listenable: controller, builder: (context, _) => Text((controller.tempValue?.length ?? 0) > 0 ? "موافق (${controller.tempValue?.length})" : "إغلاق")),
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
        final hasItems = controller.tempValue != null && controller.tempValue!.isNotEmpty;
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
                    if (hasItems) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()),
                  ]),
                ),
                child: InkWell(
                  onTap: () => _openSearchSheet(context),
                  child: Text(hasItems ? "تم اختيار (${controller.tempValue!.length}) عناصر" : hintText, style: TextStyle(fontWeight: hasItems ? FontWeight.bold : FontWeight.normal, color: hasItems ? Colors.blue.shade700 : Colors.grey.shade600)),
                ),
              ),
              if (hasItems)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Wrap(
                    spacing: 6.0, runSpacing: 4.0,
                    children: controller.tempValue!.map((item) => Chip(
                      label: Text(selectedItemLabel(item), style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.cancel, size: 16), onDeleted: () => controller.removeItem(item),
                      backgroundColor: Colors.blue.shade50, side: BorderSide(color: Colors.blue.shade200),
                    )).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
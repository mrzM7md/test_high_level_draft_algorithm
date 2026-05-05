import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_search/generic_search_controller.dart';

class GenericSearchWidget<T> extends StatelessWidget {
  final GenericSearchController<T> controller;
  final String labelText;
  final String hintText;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final String Function(T item) selectedItemLabel;
  final bool showReloadButton;

  const GenericSearchWidget({super.key, required this.controller, required this.labelText, required this.hintText, required this.itemBuilder, required this.selectedItemLabel, this.showReloadButton = true});

  void _openSearchSheet(BuildContext context) {
    controller.resetSearchState();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
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
                        final isSelected = item == controller.tempValue;
                        return InkWell(
                          onTap: () { controller.updateTemp(item); Navigator.pop(sheetContext); },
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
                if (controller.tempValue != null) IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => controller.clear()),
              ]),
            ),
            child: InkWell(
              onTap: () => _openSearchSheet(context),
              child: Text(controller.tempValue != null ? selectedItemLabel(controller.tempValue as T) : hintText, style: TextStyle(fontWeight: controller.tempValue != null ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
        );
      },
    );
  }
}
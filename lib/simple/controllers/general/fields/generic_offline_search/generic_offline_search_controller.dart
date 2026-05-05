import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_data_filter_controller.dart';

class GenericOfflineSearchController<T> extends BaseDataFilterController<T> {
  final Future<List<T>> Function({bool forceReload}) fetchAllFunction;
  final bool Function(T item, String query) localFilterFunction;
  List<T> searchResults = [];

  GenericOfflineSearchController({
    required this.fetchAllFunction, required this.localFilterFunction,
    super.defaultSelectionBuilder, super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override Future<List<T>> fetchDataFromServer({bool forceReload = false}) => fetchAllFunction(forceReload: forceReload);

  @override void onParentValueChanged() { searchResults = []; super.onParentValueChanged(); }

  void onSearchQueryChanged(String query) {
    if (query.trim().isEmpty) { searchResults = List.from(items); } 
    else { final lowerQuery = query.toLowerCase().trim(); searchResults = items.where((item) => localFilterFunction(item, lowerQuery)).toList(); }
    notifyListeners();
  }

  void resetSearch() { searchResults = List.from(items); notifyListeners(); }
}


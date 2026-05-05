// generic_dropdown_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_data_filter_controller.dart';

class GenericDropdownController<T> extends BaseDataFilterController<T> {
  final Future<List<T>> Function({bool forceReload}) fetchFunction;

  GenericDropdownController({
    required this.fetchFunction,
    super.defaultSelectionBuilder,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  Future<List<T>> fetchDataFromServer({bool forceReload = false}) =>
      fetchFunction(forceReload: forceReload);
}
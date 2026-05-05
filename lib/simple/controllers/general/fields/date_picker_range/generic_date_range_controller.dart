import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';

class GenericDateRangeController extends BaseFilterController<DateRange> {
  GenericDateRangeController({DateRange? defaultRange, super.dependencies, super.isVisible, super.isRequired}) : super(defaultValue: defaultRange);
}
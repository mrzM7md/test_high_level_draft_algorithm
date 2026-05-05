import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericCheckboxController extends BaseFilterController<bool> {
  GenericCheckboxController({
    bool defaultValue = false,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  }) : super(defaultValue: defaultValue) {
    tempValue ??= defaultValue;
    appliedValue ??= defaultValue;
  }

  @override
  void onParentValueChanged() {
    super.onParentValueChanged();
    if (tempValue == null) {
      updateTemp(defaultValue ?? false);
    }
  }

  @override
  void clear() {
    super.updateTemp(false);
    validationError = null;
    notifyListeners();
  }
}
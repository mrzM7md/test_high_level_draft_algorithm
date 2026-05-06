import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class FilterGroupController extends BaseFilterController<void> {
  final String Function()? titleBuilder;
  final List<BaseFilterController> childrenFilters;

  FilterGroupController({
    this.titleBuilder,
    required this.childrenFilters,
    super.dependencies,
    super.isVisible,
  });

  @override
  void onParentValueChanged() {
    super.onParentValueChanged();
    // 🛡️ درع البيانات الشبحية: تفريغ الأبناء إذا اختفت المجموعة بسبب الأب
    if (isVisible != null && !isVisible!()) {
      for (var child in childrenFilters) {
        child.clear();
      }
    }
    notifyListeners();
  }

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) return true;

    bool isValid = true;
    for (var child in childrenFilters) {
      if (!child.validate()) {
        isValid = false;
      }
    }
    return isValid;
  }

  @override
  void commit() {
    super.commit();
    for (var child in childrenFilters) child.commit();
  }

  @override
  void discard() {
    super.discard();
    for (var child in childrenFilters) child.discard();
  }

  @override
  void clear() {
    super.clear();
    for (var child in childrenFilters) child.clear();
  }

  @override
  void resetToDefault() {
    super.resetToDefault();
    for (var child in childrenFilters) child.resetToDefault();
  }
}
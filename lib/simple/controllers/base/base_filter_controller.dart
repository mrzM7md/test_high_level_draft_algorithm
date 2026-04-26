// --- base_filter_controller.dart ---
import 'package:flutter/material.dart';

abstract class BaseFilterController<T> extends ChangeNotifier {
  T? appliedValue;
  T? tempValue;
  final T? defaultValue;

  final List<BaseFilterController>? dependencies;
  final bool Function()? isVisible;

  final bool isRequired;
  String? validationError;

  List<dynamic>? _lastDependencyValues;

  // 🔥 الحل الجذري هنا: نستقبل isRequired كقيمة قد تكون null (بسبب أخطاء الوراثة)
  // ونقوم بإنقاذها وتحويلها إلى false في قائمة التهيئة (Initializer List)
  BaseFilterController({
    this.defaultValue,
    this.dependencies,
    this.isVisible,
    bool? isRequired, // 1. نجعلها تقبل Null مؤقتاً
  }) : isRequired = isRequired ?? false { // 2. نؤمنها هنا بأمان تام!
    appliedValue = defaultValue;
    tempValue = defaultValue;

    if (dependencies != null) {
      _lastDependencyValues = dependencies!.map((d) => d.tempValue).toList();
      for (var dep in dependencies!) {
        dep.addListener(_handleDependencyChange);
      }
    }
  }

  void _handleDependencyChange() {
    if (dependencies == null || _lastDependencyValues == null) return;

    bool hasActualChange = false;
    for (int i = 0; i < dependencies!.length; i++) {
      if (dependencies![i].tempValue != _lastDependencyValues![i]) {
        hasActualChange = true;
        _lastDependencyValues![i] = dependencies![i].tempValue;
      }
    }

    if (!hasActualChange) return;

    onParentValueChanged();
    notifyListeners();
  }

  void onParentValueChanged() {
    if (isVisible != null && !isVisible!()) {
      tempValue = null;
    }
  }

  bool validate() {
    if (isVisible != null && !isVisible!()) {
      validationError = null;
      return true;
    }

    if (isRequired && tempValue == null) {
      validationError = "هذا الحقل مطلوب ولا يمكن تركه فارغاً";
      notifyListeners();
      return false;
    }

    validationError = null;
    notifyListeners();
    return true;
  }

  void resetToDefault() {
    tempValue = defaultValue;
    validationError = null;
    notifyListeners();
  }

  void clear() {
    tempValue = null;
    validationError = null;
    notifyListeners();
  }

  void updateTemp(T? value) {
    tempValue = value;
    validationError = null;
    notifyListeners();
  }

  void commit() { appliedValue = tempValue; notifyListeners(); }

  void discard() {
    tempValue = appliedValue;
    validationError = null;
    notifyListeners();
  }

  Widget buildWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        if (isVisible != null && !isVisible!()) return const SizedBox.shrink();
        return buildFilterWidget(context);
      },
    );
  }

  Widget buildFilterWidget(BuildContext context);
}

abstract class ReportStrategy<T> {
  String get reportTitle;
  List<BaseFilterController> get filterControllers;
  Future<List<T>> fetchReportData();
}
// --- base_filter_controller.dart ---
import 'package:flutter/material.dart';

abstract class BaseFilterController<T> extends ChangeNotifier {
  T? appliedValue;
  T? tempValue;
  final T? defaultValue;

  // جعلنا الاعتمادية تقبل BaseFilterController لنتمكن من تتبع التغيير الحقيقي
  final List<BaseFilterController>? dependencies;
  final bool Function()? isVisible;

  // ذاكرة لتتبع القيم السابقة للآباء لمنع "النيران الصديقة" عند الـ Commit
  List<dynamic>? _lastDependencyValues;

  BaseFilterController({
    this.defaultValue,
    this.dependencies,
    this.isVisible,
  }) {
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
      // نتحقق: هل تغيرت القيمة في المسودة فعلاً؟
      if (dependencies![i].tempValue != _lastDependencyValues![i]) {
        hasActualChange = true;
        _lastDependencyValues![i] = dependencies![i].tempValue;
      }
    }

    // إذا لم تتغير قيمة المسودة (مثلاً عند الـ commit)، نتجاهل التحديث
    if (!hasActualChange) return;

    // إبلاغ الابن أن الأب تغير (في مستوى المسودة فقط)
    onParentValueChanged();
    notifyListeners();
  }

  // دالة مخصصة للآبناء للتعامل مع تغير الأب
  void onParentValueChanged() {
    if (isVisible != null && !isVisible!()) {
      tempValue = null;
      // 🔥 ملاحظة: لا نمسح الـ appliedValue هنا أبداً!
    }
  }

  void resetToDefault() { tempValue = defaultValue; notifyListeners(); }
  void clear() { tempValue = null; notifyListeners(); }
  void updateTemp(T? value) { tempValue = value; notifyListeners(); }
  void commit() { appliedValue = tempValue; notifyListeners(); }

  // عند التراجع: نستعيد القيمة المعتمدة (التي لم نمسحها)
  void discard() {
    tempValue = appliedValue;
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
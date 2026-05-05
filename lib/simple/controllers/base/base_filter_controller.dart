import 'package:flutter/material.dart';

abstract class BaseFilterController<T> extends ChangeNotifier {
  T? appliedValue;
  T? tempValue;
  final T? defaultValue;

  final List<BaseFilterController>? dependencies;
  final bool Function()? isVisible;

  final bool isRequired;
  final bool showReloadButton;
  String? validationError;

  List<dynamic>? _lastDependencyValues;

  // 🛡️ درع الحماية المركزي لمنع تحديث واجهة ميتة
  bool _isDisposed = false;

  BaseFilterController({
    this.defaultValue,
    this.dependencies,
    this.isVisible,
    bool? isRequired,
    bool? showReloadButton,
  }) : isRequired = isRequired ?? false,
        showReloadButton = showReloadButton ?? true {
    appliedValue = defaultValue;
    tempValue = defaultValue;

    if (dependencies != null) {
      _lastDependencyValues = dependencies!.map((d) => d.tempValue).toList();
      for (var dep in dependencies!) {
        dep.addListener(_handleDependencyChange); // 👈 ربط التنصت
      }
    }
  }

  // 🛡️ حماية مركزية: لا تقم بتحديث الشاشة إذا كان الكنترولر قد مات
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  // ☢️ الحل العبقري لتسرب الذاكرة (Memory Leak Prevention)
  @override
  void dispose() {
    _isDisposed = true; // إعلان الوفاة
    if (dependencies != null) {
      for (var dep in dependencies!) {
        dep.removeListener(_handleDependencyChange); // 👈 فك التنصت وتنظيف الذاكرة
      }
    }
    super.dispose();
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
}

abstract class ReportStrategy<T> {
  String get reportTitle;
  List<BaseFilterController> get filterControllers;
  Future<List<T>> fetchReportData();
}
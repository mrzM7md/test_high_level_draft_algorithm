// --- base_filter_controller.dart ---
import 'package:flutter/cupertino.dart';

abstract class BaseFilterController<T> extends ChangeNotifier {
  T? appliedValue;
  T? tempValue;
  final T? defaultValue;

  BaseFilterController({this.defaultValue}) {
    appliedValue = defaultValue;
    tempValue = defaultValue;
  }
  // الدالة الجديدة: إعادة التعيين للقيم الافتراضية
  void resetToDefault() {
    tempValue = defaultValue;
    notifyListeners();
  }

  // دالة الحذف (تصفر القيمة المعتمدة والمؤقتة)
  void clear() {
    tempValue = null;
    notifyListeners();
  }

  void updateTemp(T? value) {
    tempValue = value;
    notifyListeners();
  }

  void commit() {
    appliedValue = tempValue;
    notifyListeners();
  }

  void discard() {
    tempValue = appliedValue;
    notifyListeners();
  }

  Widget buildWidget(BuildContext context);
}

abstract class ReportStrategy<T> {
  String get reportTitle;
  List<BaseFilterController> get filterControllers;
  Future<List<T>> fetchReportData();
}
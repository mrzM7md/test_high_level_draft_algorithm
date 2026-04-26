// --- core_architecture.dart ---
import 'package:flutter/material.dart';

// 1. الكلاس الأساسي لكل الفلاتر الذكية (Smart Filter Controller)
abstract class BaseFilterController<T> extends ChangeNotifier {
  T? appliedValue;
  T? tempValue;
  final T? defaultValue;

  BaseFilterController({this.defaultValue}) {
    appliedValue = defaultValue;
    tempValue = defaultValue;
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

  // كل فلتر يُجبر على رسم نفسه
  Widget buildWidget(BuildContext context);
}

// 2. عقد الاستراتيجية (الواجهة التي يلتزم بها كل تقرير)
abstract class ReportStrategy<T> {
  String get reportTitle;
  List<BaseFilterController> get filterControllers;
  Future<List<T>> fetchReportData();
}
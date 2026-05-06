import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericDateController extends BaseFilterController<DateTime> {
  // 🚀 إضافة خيار التحقق من صحة التاريخ (مثلاً: يمنع اختيار تاريخ في الماضي)
  final bool Function(DateTime? date)? customValidator;
  final String? customErrorMessage;

  GenericDateController({
    this.customValidator,
    this.customErrorMessage,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired
  });

  @override
  bool validate() {
    if (!super.validate()) return false; // فحص isRequired و isVisible من الأب

    if (customValidator != null && tempValue != null) {
      if (!customValidator!(tempValue)) {
        validationError = customErrorMessage ?? "التاريخ المحدد غير صالح";
        notifyListeners();
        return false;
      }
    }
    return true;
  }
}
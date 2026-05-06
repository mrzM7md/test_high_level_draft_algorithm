import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericNumberController extends BaseFilterController<double> {
  // 🚀 ترقية: دروع حماية البيانات الكمية
  final double? minValue;
  final double? maxValue;
  final bool Function(double? value)? customValidator;
  final String? customErrorMessage;

  GenericNumberController({
    this.minValue,
    this.maxValue,
    this.customValidator,
    this.customErrorMessage,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  bool validate() {
    if (!super.validate()) return false;

    final val = tempValue;

    if (!isRequired && val == null) {
      validationError = null;
      notifyListeners();
      return true;
    }

    if (val != null) {
      // 🚀 حماية الحد الأدنى
      if (minValue != null && val < minValue!) {
        validationError =
            customErrorMessage ??
            "القيمة يجب أن تكون أكبر من أو تساوي $minValue";
        notifyListeners();
        return false;
      }

      // 🚀 حماية الحد الأقصى
      if (maxValue != null && val > maxValue!) {
        validationError =
            customErrorMessage ??
            "القيمة يجب أن تكون أصغر من أو تساوي $maxValue";
        notifyListeners();
        return false;
      }

      // 🚀 حماية اللوجيك المخصص (مثال: يجب أن يكون الرقم زوجياً)
      if (customValidator != null && !customValidator!(val)) {
        validationError = customErrorMessage ?? "القيمة المدخلة غير صالحة";
        notifyListeners();
        return false;
      }
    }

    validationError = null;
    notifyListeners();
    return true;
  }
}

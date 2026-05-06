import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericTextController extends BaseFilterController<String> {
  // 🚀 ترقية: إضافة مدققات قوية للتحكم بالمدخلات
  final bool Function(String? value)? customValidator;
  final String? customErrorMessage;

  final RegExp? regexPattern;
  final String? regexErrorMessage;

  GenericTextController({
    this.customValidator,
    this.customErrorMessage,
    this.regexPattern,
    this.regexErrorMessage,
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  });

  @override
  bool validate() {
    // 1. فحص الرؤية والإلزامية من الأب
    if (!super.validate()) return false;

    final val = tempValue;

    // إذا كان الحقل اختيارياً وفارغاً، نمرره بنجاح
    if (!isRequired && (val == null || val.trim().isEmpty)) {
      validationError = null;
      notifyListeners();
      return true;
    }

    if (val != null && val.trim().isNotEmpty) {
      // 2. 🚀 فحص الـ Regex (ممتاز للإيميلات، أرقام الهواتف، الهويات)
      if (regexPattern != null && !regexPattern!.hasMatch(val)) {
        validationError = regexErrorMessage ?? "صيغة الإدخال غير صحيحة";
        notifyListeners();
        return false;
      }

      // 3. 🚀 فحص اللوجيك المخصص
      if (customValidator != null && !customValidator!(val)) {
        validationError = customErrorMessage ?? "إدخال غير صالح";
        notifyListeners();
        return false;
      }
    }

    validationError = null;
    notifyListeners();
    return true;
  }
}

import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/data_range.dart';

class GenericDateRangeController extends BaseFilterController<DateRange> {
  // 🚀 استقبال دالة التحقق
  final bool Function(DateTime? fromDate, DateTime? toDate)? customRangeValidator;
  final String? customRangeErrorMessage;

  GenericDateRangeController({
    this.customRangeValidator,
    this.customRangeErrorMessage,
    super.defaultValue, super.dependencies, super.isVisible, super.isRequired,
  });

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) { validationError = null; return true; }

    final fromDate = tempValue?.fromDate;
    final toDate = tempValue?.toDate;

    if (isRequired && fromDate == null && toDate == null) {
      validationError = "هذا الحقل مطلوب";
      notifyListeners();
      return false;
    }

    // 🚀 تنفيذ شرط التحقق للتواريخ
    if (customRangeValidator != null) {
      if (!customRangeValidator!(fromDate, toDate)) {
        validationError = customRangeErrorMessage ?? "تاريخ البداية يجب أن يكون قبل تاريخ النهاية";
        notifyListeners();
        return false;
      }
    } else {
      // 💡 حماية افتراضية للتواريخ إذا لم يرسل المبرمج شرطاً!
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        validationError = customRangeErrorMessage ?? "تاريخ (من) لا يمكن أن يكون بعد تاريخ (إلى)";
        notifyListeners();
        return false;
      }
    }

    validationError = null;
    notifyListeners();
    return true;
  }
}
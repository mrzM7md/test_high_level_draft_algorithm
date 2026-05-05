import '../../base/base_filter_controller.dart';

class FilterGroupController extends BaseFilterController<void> {
  // دالة لجلب العنوان بناءً على حالة الاعتماديات
  final String Function()? titleBuilder;

  // قائمة الكنترولرات الأبناء (لأغراض المنطق والتمرير فقط)
  final List<BaseFilterController> childrenFilters;

  FilterGroupController({
    this.titleBuilder,
    required this.childrenFilters,
    super.dependencies,
    super.isVisible,
  });

  // ==========================================
  // 🔥 التمرير الذكي لتفريغ بيانات الأبناء عند الاختفاء
  // ==========================================
  @override
  void onParentValueChanged() {
    super.onParentValueChanged();
    // إذا أصبحت الحاوية مخفية بسبب تغير الأب، نأمر جميع الأبناء بمسح بياناتهم فوراً!
    if (isVisible != null && !isVisible!()) {
      for (var child in childrenFilters) {
        child.clear();
      }
    }
  }

  // ==========================================
  // تمرير أوامر النظام للأبناء
  // ==========================================
  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) return true;

    bool isValid = true;
    for (var child in childrenFilters) {
      if (!child.validate()) {
        isValid = false; // إذا فشل ابن واحد، تفشل المجموعة
      }
    }
    return isValid;
  }

  @override
  void commit() {
    super.commit();
    for (var child in childrenFilters) {
      child.commit();
    }
  }

  @override
  void discard() {
    super.discard();
    for (var child in childrenFilters) {
      child.discard();
    }
  }

  @override
  void clear() {
    super.clear();
    for (var child in childrenFilters) {
      child.clear();
    }
  }

  @override
  void resetToDefault() {
    super.resetToDefault();
    for (var child in childrenFilters) child.resetToDefault();
  }
}
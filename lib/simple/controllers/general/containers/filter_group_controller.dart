import 'package:flutter/material.dart';

import '../../base/base_filter_controller.dart';

class FilterGroupController extends BaseFilterController<void> {
  // 🔥 دالة تُبنى في وقت التشغيل لجلب العنوان بناءً على حالة الاعتماديات
  final String Function() titleBuilder;

  // قائمة الحقول التي ستعيش داخل هذه الحاوية
  final List<BaseFilterController> childrenFilters;

  // لمسة UI: هل تريد الحاوية قابلة للطي (ExpansionTile) أم ثابتة؟
  final bool isExpandable;

  FilterGroupController({
    required this.titleBuilder,
    required this.childrenFilters,
    this.isExpandable = true,
    super.dependencies, // نمرر الاعتماديات ليستمع الأب لتغيراتها
    super.isVisible,
  });

  // ==========================================
  // 🔥 السحر هنا: تمرير أوامر النظام للأبناء
  // ==========================================

  @override
  bool validate() {
    if (isVisible != null && !isVisible!()) return true;

    bool isValid = true;
    for (var child in childrenFilters) {
      if (!child.validate()) {
        isValid = false; // إذا فشل ابن واحد، تفشل المجموعة بالكامل
      }
    }
    return isValid;
  }

  @override
  void commit() {
    super.commit();
    for (var child in childrenFilters) child.commit();
  }

  @override
  void discard() {
    super.discard();
    for (var child in childrenFilters) child.discard();
  }

  @override
  void clear() {
    super.clear();
    for (var child in childrenFilters) child.clear();
  }

  @override
  void resetToDefault() {
    super.resetToDefault();
    for (var child in childrenFilters) child.resetToDefault();
  }

  // ==========================================
  // 🎨 بناء واجهة الحاوية
  // ==========================================

  @override
  Widget buildFilterWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this, // سيتم استدعاؤه تلقائياً عندما يتغير أي حقل في الـ dependencies
      builder: (context, _) {
        // جلب العنوان الجديد لحظياً
        final title = titleBuilder();

        // بناء الأبناء
        Widget childrenWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: childrenFilters.map((c) => c.buildWidget(context)).toList(),
        );

        if (isExpandable) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
            child: ExpansionTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15),
              ),
              initiallyExpanded: true,
              childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              children: [childrenWidget],
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                ),
                const Divider(),
                childrenWidget,
              ],
            ),
          );
        }
      },
    );
  }
}
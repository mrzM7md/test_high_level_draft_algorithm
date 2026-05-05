import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_controller.dart';
// import 'filter_group_controller.dart';

class FilterGroupWidget extends StatelessWidget {
  final FilterGroupController controller;

  // 🔥 هنا نستقبل الواجهات المرسومة للأبناء من الشاشة!
  final List<Widget> childrenWidgets;

  // تخصيص الواجهة
  final bool isExpandable;
  final Color? headerColor;

  const FilterGroupWidget({
    super.key,
    required this.controller,
    required this.childrenWidgets,
    this.isExpandable = true,
    this.headerColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // التحقق من الإظهار والاخفاء
        if (controller.isVisible != null && !controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final title = controller.titleBuilder?.call() ?? "مجموعة فلاتر";

        // بناء عامود الأبناء
        Widget childrenColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: childrenWidgets,
        );

        // رسم الواجهة بناءً على اختيار المبرمج
        if (isExpandable) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200)
            ),
            child: ExpansionTile(
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: headerColor, fontSize: 15),
              ),
              initiallyExpanded: true,
              childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              children: [childrenColumn],
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: headerColor),
                ),
                const Divider(),
                childrenColumn,
              ],
            ),
          );
        }
      },
    );
  }
}
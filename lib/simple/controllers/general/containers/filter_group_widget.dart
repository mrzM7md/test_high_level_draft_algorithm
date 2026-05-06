import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/containers/filter_group_style.dart';
// لا تنس استيراد FilterGroupStyle

class FilterGroupWidget extends StatelessWidget {
  final FilterGroupController controller;
  final List<Widget> childrenWidgets;
  final bool isExpandable;
  final FilterGroupStyle? style;

  // 🚀 البنّاء الخارق لتوزيع الحقول (Grid, Wrap, Column...)
  final Widget Function(BuildContext context, List<Widget> children)?
  customLayoutBuilder;

  const FilterGroupWidget({
    super.key,
    required this.controller,
    required this.childrenWidgets,
    this.isExpandable = true,
    this.style,
    this.customLayoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final appliedStyle = (style ?? const FilterGroupStyle()).mergeWithDefault(
      context,
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isVisible != null && !controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final title = controller.titleBuilder?.call() ?? "مجموعة فلاتر";

        // 🚀 الحرية المطلقة: إذا وفر المبرمج تخطيطاً نستخدمه، وإلا نستخدم العمود الافتراضي
        final Widget layoutContent = customLayoutBuilder != null
            ? customLayoutBuilder!(context, childrenWidgets)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: childrenWidgets,
              );

        if (isExpandable) {
          return Card(
            elevation: 0,
            // نعتمد على الحدود (Border) لتصميم عصري مسطح (Flat Design)
            color: appliedStyle.backgroundColor,
            margin: appliedStyle.margin,
            shape: appliedStyle.shape,
            child: Theme(
              // إزالة خط التقسيم القبيح الافتراضي في ExpansionTile
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(title, style: appliedStyle.titleTextStyle),
                initiallyExpanded: true,
                maintainState: true,
                // 🛡️ حماية حالة الأبناء (Focus & Temporary values) من التدمير عند الطي
                childrenPadding: appliedStyle.childrenPadding,
                iconColor: appliedStyle.headerColor,
                collapsedIconColor: appliedStyle.headerColor,
                children: [layoutContent],
              ),
            ),
          );
        } else {
          return Container(
            margin: appliedStyle.margin,
            padding: appliedStyle.childrenPadding,
            decoration: BoxDecoration(
              border: Border.all(color: appliedStyle.borderColor!),
              borderRadius:
                  (appliedStyle.shape as RoundedRectangleBorder?)
                      ?.borderRadius ??
                  BorderRadius.circular(8),
              color: appliedStyle.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(title, style: appliedStyle.titleTextStyle),
                ),
                Divider(color: appliedStyle.borderColor),
                layoutContent,
              ],
            ),
          );
        }
      },
    );
  }
}

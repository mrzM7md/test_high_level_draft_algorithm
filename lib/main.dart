// --- main.dart ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_one_strategy.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_two_strategy.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const MainMenuScreen(),
    );
  }
}

// شاشة اختيار التقارير
class MainMenuScreen extends StatelessWidget {
  // 🔥 السحر هنا: قمنا بإنشاء "نسخة واحدة ثابتة" (Singleton Cache) من كل تقرير
  // هذه المتغيرات ستبقى حية في الذاكرة ومحتفظة بكل الفلاتر ما دام التطبيق يعمل
  static final ReportOneStrategy _cachedReportOne = ReportOneStrategy();
  static final ReportTwoStrategy _cachedReportTwo = ReportTwoStrategy();

  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("نظام التقارير الذكي")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                // 🔥 التعديل هنا: نمرر النسخة المحفوظة في الذاكرة بدلاً من ()ReportOneStrategy
                builder: (_) => DynamicReportScreen(strategy: _cachedReportOne),
              )),
              child: const Text("فتح التقرير الأول"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                // 🔥 التعديل هنا: نمرر النسخة المحفوظة للتقرير الثاني
                builder: (_) => DynamicReportScreen(strategy: _cachedReportTwo),
              )),
              child: const Text("فتح التقرير الثاني"),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// الشاشة الديناميكية الموحدة للتقارير والـ Bottom Sheet
// ----------------------------------------------------
class DynamicReportScreen extends StatefulWidget {
  final ReportStrategy strategy;
  const DynamicReportScreen({super.key, required this.strategy});

  @override
  State<DynamicReportScreen> createState() => _DynamicReportScreenState();
}

class _DynamicReportScreenState extends State<DynamicReportScreen> {
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    // لمسة إضافية لراحة المستخدم: إذا كان هناك بيانات مسودة معتمدة مسبقاً، اجلب التقرير تلقائياً عند الدخول
    bool hasAppliedFilters = widget.strategy.filterControllers.any((f) => f.appliedValue != null);
    if (hasAppliedFilters) {
      _loadData();
    }
  }

  void _loadData() async {
    final result = await widget.strategy.fetchReportData();
    setState(() => _data = result);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20, left: 16, right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("خيارات الفلترة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              // رسم الفلاتر آلياً
              ...widget.strategy.filterControllers.map((f) => f.buildWidget(context)),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child:
                    ElevatedButton(
                      onPressed: () {
                        // 1. تشغيل دالة التحقق على جميع الفلاتر أولاً
                        bool isValid = true;
                        for (var controller in widget.strategy.filterControllers) {
                          // نستدعي validate()، وإذا أرجعت false لأي حقل، نجعل isValid = false
                          if (!controller.validate()) {
                            isValid = false;
                          }
                        }

                        // 2. إذا كانت جميع الحقول الإجبارية ممتلئة بشكل صحيح
                        if (isValid) {
                          for (var controller in widget.strategy.filterControllers) {
                            controller.commit(); // نعتمد القيم
                          }
                          Navigator.pop(context); // نغلق الـ Sheet
                          _loadData(); // نجلب بيانات التقرير
                        } else {
                          // يمكنك إضافة اهتزاز (Haptic) أو رسالة Snackbar هنا مستقبلاً
                          print("⚠️ هناك حقول إجبارية ناقصة!");
                        }
                      },
                      child: const Text("تطبيق الفلاتر وبحث"),
                    ),
                  ),
                  // زر إعادة التعيين الكلي
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        for (var controller in widget.strategy.filterControllers) {
                          controller.resetToDefault();
                        }
                      },
                      icon: const Icon(Icons.restore, color: Colors.orange, size: 20),
                      label: const Text("إعادة تعيين الكل", style: TextStyle(color: Colors.orange)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    ).then((_) {
      // عند إغلاق الـ Sheet بدون ضغط "تطبيق"، نتراجع عن المسودات
      for (var f in widget.strategy.filterControllers) {
        f.discard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strategy.reportTitle),
        actions: [
          IconButton(icon: const Icon(Icons.filter_alt), onPressed: _openFilterSheet),
        ],
      ),
      body: _data.isEmpty
          ? const Center(child: Text("اضغط على الفلتر لجلب البيانات"))
          : ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) => ListTile(title: Text(_data[index].toString())),
      ),
    );
  }
}
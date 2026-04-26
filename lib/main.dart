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
      // دعم اللغة العربية (اختياري لكن مفضل)
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const MainMenuScreen(),
    );
  }
}

// شاشة اختيار التقارير
class MainMenuScreen extends StatelessWidget {
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
                builder: (_) => DynamicReportScreen(strategy: ReportOneStrategy()),
              )),
              child: const Text("فتح التقرير الأول"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => DynamicReportScreen(strategy: ReportTwoStrategy()),
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
                    child: ElevatedButton(
                      onPressed: () {
                        // اعتماد المسودة وإغلاق الشاشة
                        for (var f in widget.strategy.filterControllers) {
                          f.commit();
                        }
                        Navigator.pop(context);
                        _loadData(); // جلب البيانات تلقائياً بعد الفلترة
                      },
                      child: const Text("تطبيق الفلاتر وبحث"),
                    ),
                  ),
                  // زر إعادة التعيين الكلي
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        // السحر هنا: نمر على كل كنترولر في الاستراتيجية ونصفره
                        for (var controller in widget.strategy.filterControllers) {
                          controller.resetToDefault();
                        }
                        // اختياري: يمكنك إغلاق الشاشة أو تحديث البيانات فوراً
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
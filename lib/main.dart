import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_one_screen.dart';

// استيراد الـ Strategies (المنطق)
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_one_strategy.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_two_screen.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/reports/report_two_strategy.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      appBar: AppBar(
        title: const Text("نظام التقارير الذكي"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                // 🔥 التوجيه المباشر للشاشة الأولى المخصصة
                builder: (_) => ReportOneScreen(strategy: _cachedReportOne),
              )),
              child: const Text("فتح التقرير الأول", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                // 🔥 التوجيه المباشر للشاشة الثانية المخصصة
                builder: (_) => ReportTwoScreen(strategy: _cachedReportTwo),
              )),
              child: const Text("فتح التقرير الثاني", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 🚫 تم حذف DynamicReportScreen بالكامل! لم نعد بحاجة إليها.
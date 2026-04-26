// --- api_repository.dart ---
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';

class ApiRepository {
  // محاكاة جلب التصنيفات من السيرفر
  Future<List<CategoryModel>> fetchCategories() async {
    print("🌐 [API] جاري جلب التصنيفات من السيرفر...");
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة
    return [
      CategoryModel(id: "1", name: "إلكترونيات"),
      CategoryModel(id: "2", name: "مواد غذائية"),
      CategoryModel(id: "3", name: "ملابس"),
    ];
  }

  // محاكاة جلب تصنيفات فرعية بناءً على التصنيف الرئيسي
  Future<List<CategoryModel>> fetchSubCategories(String parentId) async {
    print("🌐 [API] جاري جلب التصنيفات الفرعية للأب $parentId...");
    await Future.delayed(const Duration(seconds: 1));

    if (parentId == "1") { // إلكترونيات
      return [CategoryModel(id: "101", name: "جوالات"), CategoryModel(id: "102", name: "لابتوبات")];
    } else { // مواد غذائية وغيرها
      return [CategoryModel(id: "201", name: "معلبات"), CategoryModel(id: "202", name: "مشروبات")];
    }
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    print("🌐 [API] جاري البحث في السيرفر عن: '$query'...");
    await Future.delayed(const Duration(milliseconds: 800)); // محاكاة تأخير الشبكة

    // محاكاة لنتائج السيرفر بناءً على البحث
    final allDatabase = [
      CustomerModel(id: "1", name: "محمد الرياض", phone: "777111222"),
      CustomerModel(id: "2", name: "أحمد علي", phone: "733000000"),
      CustomerModel(id: "3", name: "شركة الأفق للتجارة", phone: "01444555"),
      CustomerModel(id: "4", name: "مؤسسة الرواد", phone: "711999888"),
    ];

    if (query.isEmpty) return [];

    return allDatabase
        .where((c) => c.name.contains(query) || c.phone.contains(query))
        .toList();
  }

  // محاكاة جلب العملاء من السيرفر
  Future<List<CustomerModel>> fetchCustomers() async {
    print("🌐 [API] جاري جلب قائمة العملاء من السيرفر...");
    await Future.delayed(const Duration(seconds: 2));
    return [
      // تم جلب البيانات الحقيقية
      CustomerModel(id: "1", name: "محمد الرياض عبدالرحيم الزمير", phone: "777111222"),
      CustomerModel(id: "2", name: "أحمد علي", phone: "733000000"),
      CustomerModel(id: "3", name: "شركة الأفق للتجارة", phone: "01444555"),
      CustomerModel(id: "4", name: "مؤسسة الرواد", phone: "711999888"),
    ];
  }

  // 🔥 الدالة الجديدة المضافة: محاكاة جلب الفروع/المناديب بناءً على العميل الأب
  Future<List<CustomerModel>> fetchRelatedCustomers(String parentId) async {
    print("🌐 [API] جاري جلب الفروع/المناديب للعميل الأب $parentId...");
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة

    // محاكاة: إرجاع فروع مختلفة بناءً على العميل المختار
    if (parentId == "1") { // إذا اختار "محمد الرياض"
      return [
        CustomerModel(id: "101", name: "فرع الرياض الرئيسي", phone: "01111111"),
        CustomerModel(id: "102", name: "فرع جدة", phone: "01222222"),
        CustomerModel(id: "103", name: "فرع الدمام", phone: "01333333"),
      ];
    } else if (parentId == "3") { // إذا اختار "شركة الأفق"
      return [
        CustomerModel(id: "301", name: "مندوب مبيعات المنطقة الشرقية", phone: "05555555"),
        CustomerModel(id: "302", name: "مندوب مبيعات المنطقة الغربية", phone: "06666666"),
      ];
    } else {
      // فروع افتراضية لأي عميل آخر
      return [
        CustomerModel(id: "999", name: "الفرع الرئيسي الوحيد", phone: "00000000"),
      ];
    }
  }
}
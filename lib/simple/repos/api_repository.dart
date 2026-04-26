// --- repository.dart ---
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
}
import 'package:test_high_level_draft_algorithm/simple/models/category_model.dart';
import 'package:test_high_level_draft_algorithm/simple/models/customer_model.dart';

class ApiRepository {
  Future<List<CategoryModel>> fetchCategories() async {
    print("🌐 [API] جاري طلب التصنيفات...");
    await Future.delayed(const Duration(seconds: 1)); // محاكاة وقت استجابة السيرفر

    // 🔥 افتعال الخطأ هنا: سنرمي استثناءً بدلاً من إرجاع البيانات
    // throw FilterFetchException("عفواً، ليس لديك صلاحية لعرض هذه التصنيفات أو السيرفر معطل.");

    return [
      CategoryModel(id: "1", name: "إلكترونيات"),
      CategoryModel(id: "2", name: "مواد غذائية"),
      CategoryModel(id: "3", name: "ملابس"),
    ];
  }

  // --- باقي الدوال تعمل بشكل طبيعي ---

  Future<List<CategoryModel>> fetchSubCategories(String parentId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (parentId == "1") {
      return [CategoryModel(id: "101", name: "جوالات"), CategoryModel(id: "102", name: "لابتوبات")];
    } else {
      return [CategoryModel(id: "201", name: "معلبات"), CategoryModel(id: "202", name: "مشروبات")];
    }
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final allDatabase = [
      CustomerModel(id: "1", name: "محمد الرياض", phone: "777111222"),
      CustomerModel(id: "2", name: "أحمد علي", phone: "733000000"),
    ];
    if (query.isEmpty) return [];
    return allDatabase.where((c) => c.name.contains(query) || c.phone.contains(query)).toList();
  }

  Future<List<CustomerModel>> fetchCustomers() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      CustomerModel(id: "1", name: "محمد الرياض", phone: "777111222"),
      CustomerModel(id: "2", name: "أحمد علي", phone: "733000000"),
    ];
  }

  Future<List<CustomerModel>> fetchRelatedCustomers(String parentId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (parentId == "1") {
      return [
        CustomerModel(id: "101", name: "فرع الرياض الرئيسي", phone: "01111111"),
      ];
    } else {
      return [
        CustomerModel(id: "999", name: "الفرع الرئيسي الوحيد", phone: "00000000"),
      ];
    }
  }
}
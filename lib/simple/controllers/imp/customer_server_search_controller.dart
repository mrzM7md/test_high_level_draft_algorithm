import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../repos/api_repository.dart';
import '../base/base_filter_controller.dart';


class CustomerServerSearchController extends BaseFilterController<CustomerModel> {
  final ApiRepository repository;

  // متغيرات خاصة بالبحث الحي
  List<CustomerModel> searchResults = [];
  bool isSearching = false;
  Timer? _debounceTimer;

  CustomerServerSearchController(this.repository);

  // دالة البحث مع خاصية الـ Debounce لحماية السيرفر
  void onSearchQueryChanged(String query) {
    // 1. إذا كان هناك مؤقت يعمل مسبقاً، قم بإلغائه
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    // 2. إنشاء مؤقت جديد (ينتظر نصف ثانية بعد آخر حرف تم كتابته)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isSearching = true;
      notifyListeners(); // إبلاغ الواجهة لإظهار دائرة التحميل

      try {
        searchResults = await repository.searchCustomers(query);
      } catch (e) {
        searchResults = [];
      } finally {
        isSearching = false;
        notifyListeners(); // إبلاغ الواجهة برسم النتائج
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text("العميل (بحث أونلاين)"),
            subtitle: Text(tempValue?.name ?? "اضغط للبحث في السيرفر..."),
            trailing: const Icon(Icons.search),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () => _openSearchSheet(context),
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    // تصفير نتائج البحث السابقة عند فتح الشاشة
    searchResults.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ServerSearchSheet(
        controller: this, // نمرر الكنترولر للـ Sheet لتستمع لنتائج البحث الحية
        onCustomerSelected: (customer) {
          updateTemp(customer); // اعتماد الاختيار في المسودة
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// هذا الكلاس يمكن وضعه في نفس الملف السابق
class _ServerSearchSheet extends StatelessWidget {
  final CustomerServerSearchController controller;
  final Function(CustomerModel) onCustomerSelected;

  const _ServerSearchSheet({
    required this.controller,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20, left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom, // الرفع مع الكيبورد
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // 1. حقل إدخال البحث
            TextField(
              decoration: const InputDecoration(
                labelText: "ابحث عن عميل (أونلاين)...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // إرسال النص مباشرة للكنترولر
              onChanged: controller.onSearchQueryChanged,
            ),
            const SizedBox(height: 10),

            // 2. الاستماع لتحديثات الكنترولر (دائرة تحميل أو النتائج)
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  // حالة التحميل من السيرفر
                  if (controller.isSearching) {
                    return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("جاري البحث في السيرفر...")
                          ],
                        )
                    );
                  }

                  // حالة عدم وجود نتائج (بعد البحث)
                  if (controller.searchResults.isEmpty) {
                    return const Center(child: Text("لا توجد نتائج مطابقة، اكتب اسماً للبحث."));
                  }

                  // رسم النتائج القادمة من السيرفر
                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final customer = controller.searchResults[index];
                      return ListTile(
                        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer.phone),
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        onTap: () => onCustomerSelected(customer),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
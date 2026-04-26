import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';

import '../../models/customer_model.dart';
import '../../repos/api_repository.dart';
import '../base/base_data_filter_controller.dart';

// 2. التعديل الثاني: الوراثة من BaseDataFilterController
class CustomerServerSearchController extends BaseDataFilterController<CustomerModel> {
  final ApiRepository repository;

  // متغيرات خاصة بالبحث الحي
  List<CustomerModel> searchResults = [];
  bool isSearching = false;

  // تعريف كائن الـ Debouncer الجاهز
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  CustomerServerSearchController(this.repository);

  // 3. التعديل الثالث: إضافة دالة جلب البيانات الأولية التلقائية
  @override
  Future<List<CustomerModel>> fetchDataFromServer() async {
    return await repository.fetchCustomers();
  }

  // دالة البحث مع الاعتماد على الـ Debouncer لحماية السيرفر
  void onSearchQueryChanged(String query) {
    _debouncer.cancel(); // إلغاء أي عملية بحث معلقة

    if (query.trim().isEmpty) {
      // 4. التعديل الرابع: إذا مسح المستخدم النص، نعرض البيانات الأولية المحملة
      searchResults = List.from(items);
      isSearching = false;
      notifyListeners();
      return;
    }

    _debouncer.run(() async {
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

// --- customer_server_search_controller.dart ---
  @override
  Widget buildWidget(BuildContext context) {
    ensureDataLoaded().then((_) {
      if (searchResults.isEmpty && items.isNotEmpty) {
        searchResults = List.from(items);
        notifyListeners();
      }
    });

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text("العميل (بحث أونلاين)"),
            subtitle: Text(tempValue?.name ?? "اضغط للبحث في السيرفر..."),
            // التعديل هنا: إضافة Row يحتوي على الأزرار
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  onPressed: () => refreshData(),
                ),
                if (tempValue != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () => clear(),
                  ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () {
              ensureDataLoaded();
              _openSearchSheet(context);
            },
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    // تجهيز القائمة قبل فتح الشاشة
    if (searchResults.isEmpty && items.isNotEmpty) {
      searchResults = List.from(items);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ServerSearchSheet(
        controller: this,
        onCustomerSelected: (customer) {
          updateTemp(customer);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------
// واجهة الـ BottomSheet
// ---------------------------------------------------------
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
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "ابحث عن عميل (أونلاين)...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: controller.onSearchQueryChanged,
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
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

                  if (controller.searchResults.isEmpty) {
                    return const Center(child: Text("لا توجد نتائج."));
                  }

                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final customer = controller.searchResults[index];

                      // 1. فحص هل هذا العنصر هو العنصر المختار حالياً؟
                      final bool isSelected = customer == controller.tempValue;

                      return ListTile(
                        // 2. تفعيل حالة الاختيار (يغير لون النص تلقائياً)
                        selected: isSelected,
                        // 3. تغيير لون الخلفية للعنصر المختار بلون خفيف
                        selectedTileColor: Colors.blue.withOpacity(0.1),

                        title: Text(
                          customer.name,
                          style: TextStyle(
                            // خط أعرض للعنصر المختار
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(customer.phone),

                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),

                        // 4. وضع علامة "صح" جهة اليسار إذا كان مختاراً
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,

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
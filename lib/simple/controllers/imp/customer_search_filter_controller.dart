import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../repos/api_repository.dart';
import '../base/base_data_filter_controller.dart';

class CustomerSearchFilterController extends BaseDataFilterController<CustomerModel> {
  final ApiRepository repository;

  CustomerSearchFilterController(this.repository);

  @override
  Future<List<CustomerModel>> fetchDataFromServer() {
    return repository.fetchCustomers();
  }

  @override
  Widget buildWidget(BuildContext context) {
    // بدء التحميل في الخلفية إذا لم تكن محملة
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text("العميل (بحث متقدم)"),
            subtitle: Text(tempValue?.name ?? "اضغط للبحث عن عميل..."),
            trailing: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () {
              if (isLoading) return; // منع الفتح أثناء التحميل
              if (items.isEmpty) {
                // عرض رسالة أنه لا يوجد بيانات
                return;
              }
              _openSearchSheet(context);
            },
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CustomerSearchSheet(
        // نمرر البيانات التي جلبناها من السيرفر مسبقاً (items) للواجهة لتبحث بداخلها
        allData: items,
        onCustomerSelected: (customer) {
          updateTemp(customer); // تحديث المسودة
          Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// الـ BottomSheet أصبحت (Dumb UI) لا علاقة لها بالسيرفر
// وظيفتها فقط عرض الـ List المُمرر لها والبحث داخله محلياً
// ---------------------------------------------------------
class _CustomerSearchSheet extends StatefulWidget {
  final List<CustomerModel> allData;
  final Function(CustomerModel) onCustomerSelected;

  const _CustomerSearchSheet({required this.allData, required this.onCustomerSelected});

  @override
  State<_CustomerSearchSheet> createState() => _CustomerSearchSheetState();
}

class _CustomerSearchSheetState extends State<_CustomerSearchSheet> {
  late List<CustomerModel> _filtered;

  @override
  void initState() {
    super.initState();
    // في البداية نعرض كل البيانات
    _filtered = widget.allData;
  }

  void _search(String query) {
    setState(() {
      _filtered = widget.allData.where((c) => c.name.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20, left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6, // أخذ 60% من الشاشة
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                  labelText: "ابحث بالاسم...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final customer = _filtered[index];
                  return ListTile(
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.phone),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    onTap: () => widget.onCustomerSelected(customer),
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
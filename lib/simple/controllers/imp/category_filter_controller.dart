// --- category_filter_controller.dart ---
import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repos/api_repository.dart';
import '../base/base_data_filter_controller.dart';

class CategoryFilterController extends BaseDataFilterController<CategoryModel> {
  final ApiRepository repository;

  CategoryFilterController(this.repository);

  @override
  Future<List<CategoryModel>> fetchDataFromServer() {
    return repository.fetchCategories();
  }

  @override
  Widget buildWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<CategoryModel>(
            decoration: InputDecoration(
              labelText: "اختر التصنيف",
              border: const OutlineInputBorder(),
              // عرض أيقونة التحميل بجانب زر التحديث
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
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
                ],
              ),
            ),
            // 🔥 حماية الـ Dropdown: إذا لم نجد العنصر (لأي سبب) نضع null
            value: items.contains(tempValue) ? tempValue : null,
            items: items.map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat.name),
            )).toList(),
            onChanged: (val) => updateTemp(val),
          ),
        );
      },
    );
  }
}
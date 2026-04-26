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
    // بمجرد بناء الواجهة، نطلب التأكد من البيانات
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (errorMessage != null) {
          return Text(errorMessage!, style: const TextStyle(color: Colors.red));
        }

        // استخدام items التي تم جلبها
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<CategoryModel>(
            decoration: const InputDecoration(
              labelText: "اختر التصنيف",
              border: OutlineInputBorder(),
            ),
            value: tempValue,
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
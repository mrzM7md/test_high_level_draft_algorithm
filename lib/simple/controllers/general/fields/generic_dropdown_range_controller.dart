import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/models/filter_fetch_exception.dart';
import '../../base/base_filter_controller.dart';
import '../models/dropdown_range.dart';

class GenericDropdownRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final Future<List<T>> Function({bool forceReload}) fetchFunction;
  final String Function(T item) itemLabelBuilder;

  List<T> _items = [];
  bool _isLoading = false;
  String? errorMessage;

  GenericDropdownRangeController({
    required this.labelText,
    required this.fetchFunction,
    required this.itemLabelBuilder,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
    super.showReloadButton,
  });

  @override
  void onParentValueChanged() {
    _items = [];
    tempValue = null;
    super.onParentValueChanged();

    if (isVisible == null || isVisible!()) {
      refreshData(forceReload: false); // لا نجبر التحديث التلقائي
    }
  }

  Future<void> refreshData({bool forceReload = false}) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newData = await fetchFunction(forceReload: forceReload);

      DropdownRange<T>? syncWithNewList(DropdownRange<T>? currentRange) {
        if (currentRange == null) return null;
        T? f = currentRange.fromValue;
        T? t = currentRange.toValue;

        if (f != null) {
          if (!newData.contains(f)) {
            newData.insert(0, f);
          } else {
            f = newData.firstWhere((e) => e == f);
          }
        }
        if (t != null) {
          if (!newData.contains(t)) {
            newData.insert(0, t);
          } else {
            t = newData.firstWhere((e) => e == t);
          }
        }
        return DropdownRange<T>(fromValue: f, toValue: t);
      }

      if (tempValue != null) tempValue = syncWithNewList(tempValue);
      if (appliedValue != null) appliedValue = syncWithNewList(appliedValue);

      _items = newData;

    } on FilterFetchException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "فشل تحميل البيانات، تأكد من الاتصال.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading || errorMessage != null) return;
    await refreshData(forceReload: false);
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              errorText: errorMessage ?? validationError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (showReloadButton)
                  // 4. 🔥 تفعيل الإجبار عند الضغط اليدوي
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.blue, size: 20), onPressed: () => refreshData(forceReload: true)),
                  if (tempValue?.fromValue != null || tempValue?.toValue != null)
                    IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => clear()),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildDropdown(context, label: fromLabelText, value: tempValue?.fromValue, isFrom: true)),
                const SizedBox(width: 8),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown(context, label: toLabelText, value: tempValue?.toValue, isFrom: false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown(BuildContext context, {required String label, required T? value, required bool isFrom}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.blue),
            value: _items.contains(value) ? value : null,
            hint: const Text("اختر...", style: TextStyle(fontSize: 13)),
            items: _items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(itemLabelBuilder(item), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) {
              final current = tempValue ?? DropdownRange<T>();
              updateTemp(DropdownRange<T>(
                fromValue: isFrom ? val : current.fromValue,
                toValue: !isFrom ? val : current.toValue,
              ));
            },
          ),
        ),
      ],
    );
  }
}
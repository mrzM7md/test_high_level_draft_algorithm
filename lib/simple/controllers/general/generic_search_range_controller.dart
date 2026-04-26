// --- generic_search_range_controller.dart ---
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/helpers/debouncer_helper.dart';
import '../base/base_filter_controller.dart';
import '../../models/dropdown_range.dart'; // نستخدم نفس كلاس النطاق الذي أنشأناه سابقاً

class GenericSearchRangeController<T> extends BaseFilterController<DropdownRange<T>> {
  final String labelText;
  final String fromLabelText;
  final String toLabelText;
  final String hintText;

  // مفوضات جلب وبحث البيانات
  final Future<List<T>> Function() initialFetchFunction;
  final Future<List<T>> Function(String query) searchFunction;
  
  // مفوضات العرض والتصميم
  final String Function(T item) selectedItemLabel;
  final Widget Function(T item, bool isSelected) itemBuilder;

  // إدارة الحالة للبيانات الأولية ونتائج البحث
  List<T> _items = [];
  List<T> searchResults = [];
  bool _isLoading = false;
  bool isSearching = false;
  
  final DebouncerHelper _debouncer = DebouncerHelper(milliseconds: 500);

  GenericSearchRangeController({
    required this.labelText,
    this.fromLabelText = "من",
    this.toLabelText = "إلى",
    this.hintText = "بحث...",
    required this.initialFetchFunction,
    required this.searchFunction,
    required this.selectedItemLabel,
    required this.itemBuilder,
    super.defaultValue,
  });

  Future<void> ensureDataLoaded() async {
    if (_items.isNotEmpty || _isLoading) return;
    await refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newData = await initialFetchFunction();

      // الحفاظ على القيم المختارة (Stale-While-Revalidate)
      if (tempValue != null) {
        T? newFrom = tempValue?.fromValue;
        T? newTo = tempValue?.toValue;

        if (newFrom != null) {
          if (!newData.contains(newFrom)) newData.insert(0, newFrom);
          else {
            newFrom = newData.firstWhere((e) => e == newFrom);
          }
        }
        if (newTo != null) {
          if (!newData.contains(newTo)) newData.insert(0, newTo);
          else {
            newTo = newData.firstWhere((e) => e == newTo);
          }
        }

        final updatedRange = DropdownRange<T>(fromValue: newFrom, toValue: newTo);
        tempValue = updatedRange;
        if (appliedValue != null) appliedValue = updatedRange;
      }

      _items = newData;
      searchResults = List.from(_items); // تحديث نتائج البحث الافتراضية
    } catch (e) {
      // تجاهل الخطأ للحفاظ على الواجهة
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    _debouncer.cancel();
    if (query.trim().isEmpty) {
      searchResults = List.from(_items);
      isSearching = false;
      notifyListeners();
      return;
    }

    _debouncer.run(() async {
      isSearching = true;
      notifyListeners();
      try {
        searchResults = await searchFunction(query);
      } catch (e) {
        searchResults = [];
      } finally {
        isSearching = false;
        notifyListeners();
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    ensureDataLoaded();

    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          // توحيد التصميم مع حقول التاريخ والـ Dropdown Range
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                    onPressed: () => refreshData(),
                  ),
                  if (tempValue?.fromValue != null || tempValue?.toValue != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => clear(),
                    ),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchButton(
                    context,
                    label: fromLabelText,
                    value: tempValue?.fromValue,
                    isFrom: true,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 30, color: Colors.grey.shade300), // خط فاصل
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSearchButton(
                    context,
                    label: toLabelText,
                    value: tempValue?.toValue,
                    isFrom: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, {required String label, required T? value, required bool isFrom}) {
    return InkWell(
      onTap: () {
        ensureDataLoaded();
        _openSearchSheet(context, isFrom: isFrom);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null ? selectedItemLabel(value) : hintText,
                    style: TextStyle(
                      fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                      color: value != null ? Colors.black : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, size: 16, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSearchSheet(BuildContext context, {required bool isFrom}) {
    // تصفير نتائج البحث للوضع الافتراضي قبل الفتح
    searchResults = List.from(_items);
    isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "بحث (${isFrom ? fromLabelText : toLabelText})...", 
                  prefixIcon: const Icon(Icons.search), 
                  border: const OutlineInputBorder()
                ),
                onChanged: onSearchQueryChanged,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: this,
                  builder: (context, _) {
                    if (isSearching) return const Center(child: CircularProgressIndicator());
                    if (searchResults.isEmpty) return const Center(child: Text("لا توجد نتائج."));
                    
                    return ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        // تحديد هل هذا العنصر هو المختار حالياً (لـ "من" أو لـ "إلى" حسب جهة الفتح)
                        final isSelected = isFrom ? item == tempValue?.fromValue : item == tempValue?.toValue;
                        
                        return InkWell(
                          onTap: () {
                            final current = tempValue ?? DropdownRange<T>();
                            updateTemp(DropdownRange<T>(
                              fromValue: isFrom ? item : current.fromValue,
                              toValue: !isFrom ? item : current.toValue,
                            ));
                            Navigator.pop(sheetContext);
                          },
                          // تمرير التصميم المخصص للمبرمج
                          child: itemBuilder(item, isSelected),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
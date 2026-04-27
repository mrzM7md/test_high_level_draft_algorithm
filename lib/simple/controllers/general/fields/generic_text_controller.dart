import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericTextController extends BaseFilterController<String> {
  final String labelText;
  final String hintText;
  
  // الكنترولر الداخلي للتحكم في واجهة الـ TextField
  final TextEditingController _textController = TextEditingController();

  GenericTextController({
    required this.labelText,
    this.hintText = "",
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  }) {
    // تعيين القيمة الافتراضية عند البناء
    _textController.text = defaultValue ?? "";
  }

  // --- التحديث الخارجي (مزامنة الـ TextField مع أوامر النظام) ---
  
  @override
  void updateTemp(String? value) {
    super.updateTemp(value);
    if (_textController.text != (value ?? "")) {
      _textController.text = value ?? "";
    }
  }

  @override
  void clear() {
    super.clear();
    _textController.clear();
  }

  @override
  void resetToDefault() {
    super.resetToDefault();
    _textController.text = defaultValue ?? "";
  }

  @override
  void discard() {
    super.discard();
    _textController.text = appliedValue ?? "";
  }

  @override
  void onParentValueChanged() {
    super.onParentValueChanged();
    _textController.text = tempValue ?? "";
  }

  @override
  Widget buildFilterWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _textController,
            // التحديث الداخلي: نستخدم super مباشرة لمنع قفز مؤشر الكتابة
            onChanged: (val) => super.updateTemp(val.isEmpty ? null : val),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              border: const OutlineInputBorder(),
              errorText: validationError, // دعم نظام التحقق من الصحة
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: tempValue != null && tempValue!.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => clear(),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
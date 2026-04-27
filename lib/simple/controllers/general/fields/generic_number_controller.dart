import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ضروري لـ TextInputFormatter
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class GenericNumberController extends BaseFilterController<double> {
  final String labelText;
  final String hintText;
  
  final TextEditingController _textController = TextEditingController();

  GenericNumberController({
    required this.labelText,
    this.hintText = "",
    super.defaultValue,
    super.dependencies,
    super.isVisible,
    super.isRequired,
  }) {
    _textController.text = defaultValue?.toString() ?? "";
  }

  @override
  void updateTemp(double? value) {
    super.updateTemp(value);
    final strVal = value?.toString() ?? "";
    if (_textController.text != strVal && double.tryParse(_textController.text) != value) {
      _textController.text = strVal;
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
    _textController.text = defaultValue?.toString() ?? "";
  }

  @override
  void discard() {
    super.discard();
    _textController.text = appliedValue?.toString() ?? "";
  }

  @override
  void onParentValueChanged() {
    super.onParentValueChanged();
    _textController.text = tempValue?.toString() ?? "";
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
            // 1. إجبار لوحة المفاتيح لتكون رقمية
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // 2. فلترة المدخلات لمنع الأحرف (يسمح بأرقام ونقطة عشرية واحدة)
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (val) {
              final parsed = double.tryParse(val);
              super.updateTemp(val.isEmpty ? null : parsed);
            },
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              border: const OutlineInputBorder(),
              errorText: validationError,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: tempValue != null
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
import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/base/base_filter_controller.dart';

class TextFilterController extends BaseFilterController<String> {
  final String title;
  late final TextEditingController _textController;

  TextFilterController(this.title) {
    _textController = TextEditingController(text: tempValue);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) => updateTemp(val.isEmpty ? null : val),
      ),
    );
  }

  @override
  void discard() {
    super.discard();
    _textController.text = tempValue ?? ''; // تحديث حقل النص عند التراجع
  }
}
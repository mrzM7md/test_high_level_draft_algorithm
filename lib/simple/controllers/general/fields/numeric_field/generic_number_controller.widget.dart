import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/numeric_field/generic_number_controller.dart';

class GenericNumberWidget extends StatefulWidget {
  final GenericNumberController controller;
  final String labelText;
  final String hintText;

  const GenericNumberWidget({super.key, required this.controller, required this.labelText, this.hintText = ""});

  @override
  State<GenericNumberWidget> createState() => _GenericNumberWidgetState();
}

class _GenericNumberWidgetState extends State<GenericNumberWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.tempValue?.toString() ?? "");
    widget.controller.addListener(_syncText);
  }

  void _syncText() {
    final strVal = widget.controller.tempValue?.toString() ?? "";
    if (_textController.text != strVal && double.tryParse(_textController.text) != widget.controller.tempValue) {
      _textController.text = strVal;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncText);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null && !widget.controller.isVisible!()) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (val) => widget.controller.updateTemp(val.isEmpty ? null : double.tryParse(val)),
            decoration: InputDecoration(
              labelText: widget.labelText, hintText: widget.hintText, border: const OutlineInputBorder(), errorText: widget.controller.validationError,
              suffixIcon: widget.controller.tempValue != null ? IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => widget.controller.clear()) : null,
            ),
          ),
        );
      },
    );
  }
}
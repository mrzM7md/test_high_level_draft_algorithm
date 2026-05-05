import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text/generic_text_controller.dart';

class GenericTextWidget extends StatefulWidget {
  final GenericTextController controller;
  final String labelText;
  final String hintText;

  const GenericTextWidget({super.key, required this.controller, required this.labelText, this.hintText = ""});

  @override
  State<GenericTextWidget> createState() => _GenericTextWidgetState();
}

class _GenericTextWidgetState extends State<GenericTextWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.tempValue ?? "");
    widget.controller.addListener(_syncText);
  }

  void _syncText() {
    final strVal = widget.controller.tempValue ?? "";
    if (_textController.text != strVal) {
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
            onChanged: (val) => widget.controller.updateTemp(val.isEmpty ? null : val),
            decoration: InputDecoration(
              labelText: widget.labelText, hintText: widget.hintText, border: const OutlineInputBorder(),
              errorText: widget.controller.validationError, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: widget.controller.tempValue != null && widget.controller.tempValue!.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => widget.controller.clear())
                  : null,
            ),
          ),
        );
      },
    );
  }
}
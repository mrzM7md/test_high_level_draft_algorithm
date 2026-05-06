import 'package:flutter/material.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text/generic_text_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/generic_text/generic_text_style.dart';
// لا تنس استيراد GenericTextStyle

class GenericTextWidget extends StatefulWidget {
  final GenericTextController controller;
  final String labelText;
  final String hintText;
  final GenericTextStyle? style;

  // 🚀 خيارات لوحة المفاتيح والتحكم المطلق
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;

  const GenericTextWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = "",
    this.style,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
  });

  @override
  State<GenericTextWidget> createState() => _GenericTextWidgetState();
}

class _GenericTextWidgetState extends State<GenericTextWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.tempValue ?? "",
    );
    widget.controller.addListener(_syncText);
  }

  void _syncText() {
    final strVal = widget.controller.tempValue ?? "";
    if (_textController.text != strVal) {
      // 🛡️ درع حماية المؤشر (Cursor Protection): يمنع قفز المؤشر عند التحديث من الخارج!
      final previousSelection = _textController.selection;
      _textController.text = strVal;

      if (previousSelection.isValid && previousSelection.end <= strVal.length) {
        _textController.selection = previousSelection;
      } else {
        _textController.selection = TextSelection.collapsed(
          offset: strVal.length,
        );
      }
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
    final appliedStyle = (widget.style ?? const GenericTextStyle())
        .mergeWithDefault(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final hasText =
            widget.controller.tempValue != null &&
            widget.controller.tempValue!.isNotEmpty;

        return Padding(
          padding: appliedStyle.padding!,
          child: TextField(
            controller: _textController,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            // حماية: كلمات المرور دائماً سطر واحد
            maxLength: widget.maxLength,
            style: appliedStyle.textStyle,
            onChanged: (val) =>
                widget.controller.updateTemp(val.isEmpty ? null : val),
            decoration: appliedStyle.decoration!.copyWith(
              labelText: widget.labelText,
              hintText: widget.hintText,
              hintStyle: appliedStyle.hintStyle,
              errorText: widget.controller.validationError,
              prefixIcon: widget.prefixIcon,
              suffixIcon: hasText
                  ? IconButton(
                      icon: appliedStyle.clearIcon!,
                      onPressed: () => widget.controller.clear(),
                      splashRadius: 20,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

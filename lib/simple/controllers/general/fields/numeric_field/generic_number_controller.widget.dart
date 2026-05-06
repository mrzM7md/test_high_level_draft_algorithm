import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/numeric_field/generic_number_controller.dart';
import 'package:test_high_level_draft_algorithm/simple/controllers/general/fields/numeric_field/generic_number_style.dart';
// لا تنس استيراد GenericNumberStyle

class GenericNumberWidget extends StatefulWidget {
  final GenericNumberController controller;
  final String labelText;
  final String hintText;
  final GenericNumberStyle? style;

  // 🚀 تحكم مطلق في نوع الأرقام المسموحة
  final bool allowDecimal;
  final bool allowNegative;

  const GenericNumberWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = "",
    this.style,
    this.allowDecimal = true,
    this.allowNegative = false, // الافتراضي: موجب مع كسور
  });

  @override
  State<GenericNumberWidget> createState() => _GenericNumberWidgetState();
}

class _GenericNumberWidgetState extends State<GenericNumberWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: _formatValue(widget.controller.tempValue),
    );
    widget.controller.addListener(_syncText);
  }

  String _formatValue(double? value) {
    if (value == null) return "";
    // إزالة الصفر العشري إذا كان الرقم صحيحاً (مثال: 10.0 تصبح 10)
    return value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toString();
  }

  void _syncText() {
    final strVal = _formatValue(widget.controller.tempValue);
    // نتأكد أن النص الفعلي يختلف رياضياً عما هو موجود لتجنب تحديثات غير ضرورية
    if (_textController.text != strVal &&
        double.tryParse(_textController.text) != widget.controller.tempValue) {
      // 🛡️ السلاح المضاد لـ "قفز المؤشر" المالي
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
    final appliedStyle = (widget.style ?? const GenericNumberStyle())
        .mergeWithDefault(context);

    // بناء تعبير قياسي ذكي بناءً على الخصائص المسموحة
    final regexString =
        '^${widget.allowNegative ? r'-?' : ''}[0-9]*${widget.allowDecimal ? r'\.?[0-9]*' : ''}';

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isVisible != null &&
            !widget.controller.isVisible!()) {
          return const SizedBox.shrink();
        }

        final hasValue = widget.controller.tempValue != null;

        return Padding(
          padding: appliedStyle.padding!,
          child: TextField(
            controller: _textController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.allowDecimal,
              signed: widget.allowNegative,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(regexString)),
            ],
            onChanged: (val) {
              if (val.isEmpty || val == '-') {
                widget.controller.updateTemp(null);
              } else {
                widget.controller.updateTemp(double.tryParse(val));
              }
            },
            style: appliedStyle.textStyle,
            decoration: appliedStyle.decoration!.copyWith(
              labelText: widget.labelText,
              hintText: widget.hintText,
              hintStyle: appliedStyle.hintStyle,
              errorText: widget.controller.validationError,
              prefixIcon: appliedStyle.prefixIcon,
              suffix: appliedStyle.suffixText,
              suffixIcon: hasValue
                  ? IconButton(
                      icon: appliedStyle.clearIcon!,
                      onPressed: () {
                        _textController.clear();
                        widget.controller.clear();
                      },
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

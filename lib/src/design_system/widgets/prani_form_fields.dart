import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';

/// Single-line form field with BN-first typography and scroll padding for keyboards.
class PraniTextField extends StatelessWidget {
  const PraniTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.readOnly = false,
    this.inputFormatters,
    this.autovalidateMode,
    this.onTapOutside,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool obscureText;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final TapRegionCallback? onTapOutside;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      style: PraniTextStyles.input(scheme, textTheme),
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      obscureText: obscureText,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      onTapOutside:
          onTapOutside ?? (_) => FocusManager.instance.primaryFocus?.unfocus(),
      scrollPadding: EdgeInsets.only(
        bottom: PraniFormTokens.scrollBottomInset(context),
      ),
      minLines: 1,
      maxLines: 1,
    );
  }
}

/// Multi-line form field with comfortable padding.
class PraniTextArea extends StatelessWidget {
  const PraniTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 6,
    this.inputFormatters,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      style: PraniTextStyles.input(scheme, textTheme),
      decoration: decoration,
      keyboardType: keyboardType ?? TextInputType.multiline,
      textInputAction: textInputAction ?? TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      scrollPadding: EdgeInsets.only(
        bottom: PraniFormTokens.scrollBottomInset(context),
      ),
    );
  }
}

/// Dropdown aligned with app [InputDecorationTheme].
class PraniDropdownField<T> extends StatelessWidget {
  const PraniDropdownField({
    super.key,
    required this.items,
    // ignore: deprecated_member_use
    required this.value,
    required this.onChanged,
    this.decoration = const InputDecoration(),
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: decoration,
      validator: validator,
      isExpanded: isExpanded,
      style: PraniTextStyles.input(scheme, textTheme),
      borderRadius: BorderRadius.circular(PraniRadius.md),
    );
  }
}

/// Aliases for semantic naming in forms — same widgets as [PraniTextField] / …
typedef PraniFormTextField = PraniTextField;
typedef PraniFormTextArea = PraniTextArea;
typedef PraniFormDropdown<T> = PraniDropdownField<T>;

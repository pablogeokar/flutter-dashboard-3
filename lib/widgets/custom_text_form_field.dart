import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Widget para campos de texto customizados
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool isRequired;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isUpperCase;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.isUpperCase = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    List<TextInputFormatter> formatters = inputFormatters ?? [];

    if (isUpperCase) {
      formatters.add(
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(text: newValue.text.toUpperCase());
        }),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: formatters,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: const Color(0xFF00BCD4),
      textCapitalization: isUpperCase
          ? TextCapitalization.characters
          : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: readOnly
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : (isDark
                  ? const Color(0xFF2A2A2A)
                  : colorScheme.surfaceContainerHighest),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator:
          validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label é obrigatório';
                  }
                  return null;
                }
              : null),
    );
  }
}

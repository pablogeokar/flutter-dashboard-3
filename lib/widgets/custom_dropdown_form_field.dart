import 'package:flutter/material.dart';

// Widget para Dropdown customizado
class CustomDropdownFormField extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final IconData? prefixIcon;
  final bool isRequired;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(color: colorScheme.onSurface),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : colorScheme.surface,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
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
        fillColor: isDark
            ? const Color(0xFF2A2A2A)
            : colorScheme.surfaceContainerHighest,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.toUpperCase(),
            style: TextStyle(color: colorScheme.onSurface),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator:
          validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label é obrigatório';
                  }
                  return null;
                }
              : null),
    );
  }
}

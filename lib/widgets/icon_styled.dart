import 'package:flutter/material.dart';

class IconStyled extends StatelessWidget {
  final Color? cor;
  final IconData icone;
  final bool? isLarge;
  final bool? isBordered;

  const IconStyled({
    super.key,
    this.cor = const Color(0xFF00BCD4),
    required this.icone,
    this.isLarge = false,
    this.isBordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = isLarge == true ? 32.0 : 20.0;
    final double borderRadius = isLarge == true ? 12.0 : 8.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor!.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: isBordered == true
            ? Border.all(color: cor!.withValues(alpha: 0.3))
            : null,
      ),
      child: Icon(icone, color: cor, size: iconSize),
    );
  }
}

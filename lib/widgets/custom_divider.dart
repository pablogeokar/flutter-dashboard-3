import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 2,
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.divider.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
        color: isDark ? AppTheme.dividerDark.withValues(alpha: 0.3) : null,
      ),
    );
  }
}

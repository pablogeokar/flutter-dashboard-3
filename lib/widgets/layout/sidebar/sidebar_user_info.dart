import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

class SidebarUserInfo extends StatelessWidget {
  const SidebarUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : AppTheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withValues(alpha: 0.2)
              : AppTheme.navBorder.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isDark ? null : AppTheme.primaryGradient,
              color: isDark ? Colors.grey[700] : null,
              borderRadius: BorderRadius.circular(22),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: isDark ? Colors.grey[400] : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antonio Neto',
                  style: TextStyle(
                    color: isDark ? AppTheme.textOnDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Tesoureiro',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[500] : AppTheme.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}

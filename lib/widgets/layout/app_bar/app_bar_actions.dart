import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

class AppBarActions extends StatelessWidget {
  final bool isMobile;

  const AppBarActions({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isMobile
          ? [_buildNotificationButton(context)]
          : [
              _buildActionButton(context, Icons.search, () {}),
              const SizedBox(width: 8),
              _buildNotificationButton(context),
              const SizedBox(width: 8),
              _buildActionButton(context, Icons.fullscreen, () {}),
            ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.transparent
              : AppTheme.navBorder.withValues(alpha: 0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
        iconSize: 20,
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.transparent : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : AppTheme.navBorder.withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
            iconSize: 20,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

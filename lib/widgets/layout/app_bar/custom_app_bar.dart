import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/navigation_item_model.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/widgets/layout/app_bar/app_bar_actions.dart';

class CustomAppBar extends StatelessWidget {
  final NavigationItem currentItem;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.currentItem,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : AppTheme.navBorder.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8),
      child: Row(
        children: [
          if (showMenuButton) ...[
            SizedBox(width: isMobile ? 2 : 4),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? AppTheme.textOnDark : AppTheme.primary,
                size: isMobile ? 20 : 24,
              ),
              onPressed: onMenuPressed,
              padding: const EdgeInsets.all(4),
              constraints: BoxConstraints(
                minWidth: isMobile ? 32 : 40,
                minHeight: isMobile ? 32 : 40,
              ),
            ),
          ],
          SizedBox(width: isMobile ? 4 : 8),
          Expanded(child: _buildAppBarTitle(context, isMobile)),
          AppBarActions(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? currentItem.color.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            currentItem.icon,
            color: isDark ? currentItem.color : AppTheme.primary,
            size: isMobile ? 16 : 20,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            currentItem.title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textOnDark : AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

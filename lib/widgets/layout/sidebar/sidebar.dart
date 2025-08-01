import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/navigation_item_model.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/widgets/custom_divider.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar_header.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar_navigation.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar_user_info.dart';

class Sidebar extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDrawer;

  const Sidebar({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SidebarHeader(),
        const CustomDivider(),
        const SizedBox(height: 24),
        SidebarNavigation(
          navigationItems: navigationItems,
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
        ),
        const SidebarUserInfo(),
      ],
    );

    if (isDrawer) {
      return content;
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.sidebarBackground,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : AppTheme.navBorder,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AppTheme.sidebarShadow.withValues(alpha: 0.12),
            blurRadius: isDark ? 12 : 20,
            offset: const Offset(3, 0),
            spreadRadius: isDark ? 0 : 2,
          ),
        ],
      ),
      child: content,
    );
  }
}

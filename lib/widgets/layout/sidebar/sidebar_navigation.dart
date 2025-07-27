import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/navigation_item_model.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/responsive_layout.dart';

class SidebarNavigation extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarNavigation({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: navigationItems.length,
        itemBuilder: (context, index) => _buildNavItem(context, index),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = navigationItems[index];
    final isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onItemSelected(index);
            if (ResponsiveLayout.isMobile(context)) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                        ? item.color.withValues(alpha: 0.15)
                        : AppTheme.primary.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: isDark
                          ? item.color.withValues(alpha: 0.3)
                          : AppTheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
              boxShadow: isSelected && !isDark
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? item.color.withValues(alpha: 0.2)
                              : AppTheme.primary.withValues(alpha: 0.12))
                        : (isDark
                              ? Colors.transparent
                              : AppTheme.surface.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? (isDark ? item.color : AppTheme.primary)
                        : (isDark ? Colors.grey[500] : AppTheme.textSecondary),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppTheme.textOnDark : AppTheme.primary)
                        : (isDark ? Colors.grey[500] : AppTheme.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? item.color : AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? item.color : AppTheme.primary)
                              .withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

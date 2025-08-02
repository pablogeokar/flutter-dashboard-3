import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

enum CardVariant { default_, elevated, outlined, filled }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CardVariant.default_,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
        child: cardContent,
      );
    }

    switch (variant) {
      case CardVariant.default_:
        return Card(
          elevation: elevation ?? AppTheme.elevationM,
          margin: margin ?? const EdgeInsets.all(AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
          ),
          color: backgroundColor,
          child: cardContent,
        );

      case CardVariant.elevated:
        return Card(
          elevation: elevation ?? AppTheme.elevationL,
          margin: margin ?? const EdgeInsets.all(AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
          ),
          color: backgroundColor,
          child: cardContent,
        );

      case CardVariant.outlined:
        return Container(
          margin: margin ?? const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: isDark
                  ? Colors.grey.withValues(alpha: 0.3)
                  : AppTheme.divider,
              width: 1,
            ),
          ),
          child: cardContent,
        );

      case CardVariant.filled:
        return Container(
          margin: margin ?? const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (isDark ? const Color(0xFF2A2A2A) : AppTheme.surface),
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
          ),
          child: cardContent,
        );
    }
  }
}

class CustomCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const CustomCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppTheme.spacingM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    titleStyle ??
                    AppTheme.headline4.copyWith(
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  subtitle!,
                  style:
                      subtitleStyle ??
                      AppTheme.body2.copyWith(
                        color: isDark ? Colors.grey : AppTheme.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppTheme.spacingM),
          trailing!,
        ],
      ],
    );
  }
}

class CustomCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CustomCardContent({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: AppTheme.spacingM),
      child: child,
    );
  }
}

class CustomCardActions extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const CustomCardActions({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingM),
      child: Row(mainAxisAlignment: mainAxisAlignment, children: children),
    );
  }
}

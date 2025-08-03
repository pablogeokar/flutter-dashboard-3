import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = _buildButtonChild();

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _getElevatedButtonStyle(context),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _getSecondaryButtonStyle(context),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outline:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: _getOutlinedButtonStyle(context),
            child: buttonChild,
          ),
        );

      case ButtonVariant.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: _getTextButtonStyle(context),
            child: buttonChild,
          ),
        );

      case ButtonVariant.danger:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _getDangerButtonStyle(context),
            child: buttonChild,
          ),
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize(), color: _getTextColor()));
      children.add(SizedBox(width: _getSpacing()));
    }

    children.add(
      Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w500,
          color: _getTextColor(),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getElevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      elevation: AppTheme.elevationS,
    );
  }

  ButtonStyle _getSecondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.secondaryColor,
      foregroundColor: Colors.white,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      elevation: AppTheme.elevationS,
    );
  }

  ButtonStyle _getOutlinedButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryColor,
      side: BorderSide(color: AppTheme.primaryColor),
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
    );
  }

  ButtonStyle _getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.primaryColor,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
    );
  }

  ButtonStyle _getDangerButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.error,
      foregroundColor: Colors.white,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      elevation: AppTheme.elevationS,
    );
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return AppTheme.primaryColor;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXL,
          vertical: AppTheme.spacingL,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getSpacing() {
    switch (size) {
      case ButtonSize.small:
        return AppTheme.spacingXS;
      case ButtonSize.medium:
        return AppTheme.spacingS;
      case ButtonSize.large:
        return AppTheme.spacingM;
    }
  }
}

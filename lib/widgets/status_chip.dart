import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

enum StatusType { success, warning, error, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool isSmall;
  final VoidCallback? onTap;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.isSmall = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = _getColors(type, isDark);

    Widget chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppTheme.spacingS : AppTheme.spacingM,
        vertical: isSmall ? AppTheme.spacingXS : AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(
          isSmall ? AppTheme.radiusS : AppTheme.radiusM,
        ),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: colors.text, size: isSmall ? 12 : 14),
            SizedBox(width: isSmall ? AppTheme.spacingXS : AppTheme.spacingS),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors.text,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      chip = GestureDetector(onTap: onTap, child: chip);
    }

    return chip;
  }

  _StatusColors _getColors(StatusType type, bool isDark) {
    switch (type) {
      case StatusType.success:
        return _StatusColors(
          background: isDark
              ? AppTheme.success.withValues(alpha: 0.2)
              : AppTheme.success.withValues(alpha: 0.1),
          text: AppTheme.success,
          border: AppTheme.success.withValues(alpha: 0.3),
        );

      case StatusType.warning:
        return _StatusColors(
          background: isDark
              ? AppTheme.warning.withValues(alpha: 0.2)
              : AppTheme.warning.withValues(alpha: 0.1),
          text: AppTheme.warning,
          border: AppTheme.warning.withValues(alpha: 0.3),
        );

      case StatusType.error:
        return _StatusColors(
          background: isDark
              ? AppTheme.error.withValues(alpha: 0.2)
              : AppTheme.error.withValues(alpha: 0.1),
          text: AppTheme.error,
          border: AppTheme.error.withValues(alpha: 0.3),
        );

      case StatusType.info:
        return _StatusColors(
          background: isDark
              ? AppTheme.info.withValues(alpha: 0.2)
              : AppTheme.info.withValues(alpha: 0.1),
          text: AppTheme.info,
          border: AppTheme.info.withValues(alpha: 0.3),
        );

      case StatusType.neutral:
        return _StatusColors(
          background: isDark
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          text: isDark ? Colors.grey : AppTheme.textSecondary,
          border: isDark
              ? Colors.grey.withValues(alpha: 0.3)
              : AppTheme.divider,
        );
    }
  }
}

class _StatusColors {
  final Color background;
  final Color text;
  final Color border;

  const _StatusColors({
    required this.background,
    required this.text,
    required this.border,
  });
}

// Helper para criar status chips comuns
class StatusChipHelper {
  static StatusChip membroStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return const StatusChip(
          label: 'Ativo',
          type: StatusType.success,
          icon: Icons.check_circle,
        );
      case 'inativo':
        return const StatusChip(
          label: 'Inativo',
          type: StatusType.error,
          icon: Icons.cancel,
        );
      case 'pausado':
        return const StatusChip(
          label: 'Pausado',
          type: StatusType.warning,
          icon: Icons.pause_circle,
        );
      default:
        return StatusChip(label: status, type: StatusType.neutral);
    }
  }

  static StatusChip contribuicaoStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pago':
        return const StatusChip(
          label: 'Pago',
          type: StatusType.success,
          icon: Icons.check_circle,
        );
      case 'pendente':
        return const StatusChip(
          label: 'Pendente',
          type: StatusType.warning,
          icon: Icons.schedule,
        );
      case 'cancelado':
        return const StatusChip(
          label: 'Cancelado',
          type: StatusType.error,
          icon: Icons.cancel,
        );
      default:
        return StatusChip(label: status, type: StatusType.neutral);
    }
  }
}

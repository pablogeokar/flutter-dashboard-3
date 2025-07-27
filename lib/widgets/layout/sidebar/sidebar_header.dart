import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo principal no topo da sidebar
        Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Image.asset(
              isDark ? 'assets/images/logo-dark.png' : 'assets/images/logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Container com informações da empresa
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo da loja centralizada e com melhor proporção
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo-loja.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              _buildCompanyInfo(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Harmonia, Luz e Sigilo nº 46',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CNPJ: 12.345.678/0001-90',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

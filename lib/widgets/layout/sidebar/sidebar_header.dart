import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';

class SidebarHeader extends StatefulWidget {
  const SidebarHeader({super.key});

  @override
  State<SidebarHeader> createState() => _SidebarHeaderState();
}

// GlobalKey para acessar o state do SidebarHeader
final GlobalKey<_SidebarHeaderState> sidebarHeaderKey =
    GlobalKey<_SidebarHeaderState>();

class _SidebarHeaderState extends State<SidebarHeader> {
  String _nomeLoja = 'Harmonia, Luz e Sigilo nº 46';
  String _cnpj = 'CNPJ: 12.345.678/0001-90';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarInformacoesLoja();
  }

  Future<void> _carregarInformacoesLoja() async {
    try {
      final db = DatabaseService();

      final nomeLoja = await db.getValorConfiguracao('nome_loja');
      final cnpj = await db.getValorConfiguracao('cnpj');

      if (mounted) {
        setState(() {
          _nomeLoja = nomeLoja ?? 'Harmonia, Luz e Sigilo nº 46';
          _cnpj = 'CNPJ: ${cnpj ?? '12.345.678/0001-90'}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método público para atualizar as informações quando necessário
  void atualizarInformacoes() {
    _carregarInformacoesLoja();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo principal no topo da sidebar
        Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 16),
          ),
          child: Center(
            child: Image.asset(
              isDark ? 'assets/images/logo-dark.png' : 'assets/images/logo.png',
              height: ResponsiveUtils.getResponsiveHeight(context, 80),
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Container com informações da empresa
        Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 12),
          ),
          margin: EdgeInsets.fromLTRB(
            ResponsiveUtils.getResponsiveSpacing(context, 16),
            0,
            ResponsiveUtils.getResponsiveSpacing(context, 16),
            ResponsiveUtils.getResponsiveSpacing(context, 16),
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveRadius(context, 16),
            ),
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
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveRadius(context, 12),
                ),
                child: Image.asset(
                  'assets/images/logo-loja.png',
                  height: ResponsiveUtils.getResponsiveHeight(context, 80),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              _buildCompanyInfo(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(bool isDark) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, 20),
            height: ResponsiveUtils.getResponsiveSpacing(context, 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.grey[400]! : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _nomeLoja,
          textAlign: TextAlign.center,
          style: AppTheme.getResponsiveBody2(context).copyWith(
            color: isDark ? Colors.grey[300] : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
        Text(
          _cnpj,
          textAlign: TextAlign.center,
          style: AppTheme.getResponsiveCaption(context).copyWith(
            color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

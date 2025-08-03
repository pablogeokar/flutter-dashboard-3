// widgets/layout/sidebar/sidebar_header.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/services/logo_manager.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';

// GlobalKey para acesso externo (manter para compatibilidade)
final GlobalKey<SidebarHeaderState> sidebarHeaderKey =
    GlobalKey<SidebarHeaderState>();

class SidebarHeader extends StatefulWidget {
  const SidebarHeader({super.key});

  // Factory para usar com a GlobalKey automaticamente
  factory SidebarHeader.withGlobalKey() {
    return SidebarHeader(key: sidebarHeaderKey);
  }

  @override
  State<SidebarHeader> createState() => SidebarHeaderState();
}

class SidebarHeaderState extends State<SidebarHeader> {
  final LogoManager _logoManager = LogoManager();
  String _nomeLoja = 'Loja Maçônica';
  String _cnpj = 'CNPJ: 12.345.678/0001-90';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarInformacoes();
  }

  Future<void> _carregarInformacoes() async {
    try {
      final db = DatabaseService();

      // Carregar nome da loja
      final nomeLoja = await db.getValorConfiguracao('nome_loja');
      final cnpj = await db.getValorConfiguracao('cnpj');

      // Carregar caminho da logo
      final logoPath = await db.getValorConfiguracao('logo_path');

      if (mounted) {
        setState(() {
          _nomeLoja = nomeLoja ?? 'Loja Maçônica';
          _cnpj = 'CNPJ: ${cnpj ?? '12.345.678/0001-90'}';
          _isLoading = false;
        });

        // Atualizar o LogoManager com o caminho atual
        _logoManager.updateLogoPath(logoPath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar informações do header: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método público para atualizar as informações (manter para compatibilidade)
  Future<void> atualizarInformacoes() async {
    await _carregarInformacoes();
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
              // Logo da loja usando o LogoManager
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveRadius(context, 12),
                ),
                child: _logoManager.buildLogoWidget(
                  width: ResponsiveUtils.getResponsiveHeight(context, 80),
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

// screens/configuracoes_screen.dart - Com serviço de upload
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/services/logo_manager.dart';
import 'package:flutter_dashboard_3/services/logo_upload_service.dart';
import 'package:flutter_dashboard_3/models/configuracao.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/custom_card.dart';
import 'package:flutter_dashboard_3/widgets/custom_loading.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar_header.dart';
import 'dart:io';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorContribuicaoController = TextEditingController();
  final _nomeLojController = TextEditingController();
  final _cnpjController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Serviços
  final LogoManager _logoManager = LogoManager();
  final LogoUploadService _logoUploadService = LogoUploadService();

  // Opções de upload
  String _selectedUploadOption = 'app_directory'; // Padrão

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  @override
  void dispose() {
    _valorContribuicaoController.dispose();
    _nomeLojController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  Future<void> _carregarConfiguracoes() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseService();

      final valorContribuicao = await db.getValorConfiguracao(
        'valor_contribuicao_mensal',
      );
      final nomeLoja = await db.getValorConfiguracao('nome_loja');
      final cnpj = await db.getValorConfiguracao('cnpj');
      final logoPath = await db.getValorConfiguracao('logo_path');

      _valorContribuicaoController.text =
          double.tryParse(valorContribuicao ?? '100.00')?.toStringAsFixed(2) ??
          '100.00';
      _nomeLojController.text = nomeLoja ?? 'Loja Maçônica';
      _cnpjController.text = cnpj ?? '01.234.567/0001-89';

      // Verificar se o logo existe
      String? validLogoPath;
      if (logoPath != null && logoPath.isNotEmpty) {
        if (await _logoUploadService.logoExists(logoPath)) {
          validLogoPath = logoPath;
          if (kDebugMode) {
            print('Logo carregado: $logoPath');
          }
        } else {
          if (kDebugMode) {
            print('Arquivo de logo não encontrado: $logoPath');
          }
          await db.deleteConfiguracao('logo_path');
        }
      }

      _logoManager.updateLogoPath(validLogoPath);
    } catch (e) {
      _mostrarMensagem('Erro ao carregar configurações: $e', Colors.red);
      if (kDebugMode) {
        print('Erro detalhado ao carregar configurações: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarConfiguracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService();

      await _salvarOuAtualizarConfiguracao(
        db,
        'valor_contribuicao_mensal',
        _valorContribuicaoController.text.replaceAll(',', '.'),
        'Valor da contribuição mensal dos membros da loja',
      );

      await _salvarOuAtualizarConfiguracao(
        db,
        'nome_loja',
        _nomeLojController.text.trim(),
        'Nome da loja maçônica',
      );

      await _salvarOuAtualizarConfiguracao(
        db,
        'cnpj',
        _cnpjController.text.trim(),
        'CNPJ da loja',
      );

      final currentLogoPath = _logoManager.currentLogoPath;
      if (currentLogoPath != null) {
        await _salvarOuAtualizarConfiguracao(
          db,
          'logo_path',
          currentLogoPath,
          'Caminho do logo da loja',
        );
      }

      _mostrarMensagem('Configurações salvas com sucesso!', Colors.green);
      _atualizarSidebarHeader();
    } catch (e) {
      _mostrarMensagem('Erro ao salvar configurações: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _salvarOuAtualizarConfiguracao(
    DatabaseService db,
    String chave,
    String valor,
    String descricao,
  ) async {
    try {
      final result = await db.updateConfiguracao(
        chave,
        valor,
        descricao: descricao,
      );

      if (result == 0) {
        final novaConfiguracao = Configuracao(
          chave: chave,
          valor: valor,
          descricao: descricao,
          dataAtualizacao: DateTime.now(),
        );
        await db.insertConfiguracao(novaConfiguracao);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar configuração $chave: $e');
      }
      rethrow;
    }
  }

  Future<void> _selecionarLogo() async {
    try {
      String? logoPath;

      // Fazer upload baseado na opção selecionada
      switch (_selectedUploadOption) {
        case 'app_directory':
          logoPath = await _logoUploadService.uploadLogoToAppDirectory();
          break;

        case 'system_directory':
          logoPath = await _logoUploadService.uploadLogoToSystemDirectory();
          break;

        case 'assets':
          logoPath = await _logoUploadService.uploadLogoToAssets();
          break;

        case 'custom':
          // Permitir que o usuário escolha uma pasta
          logoPath = await _selecionarPastaCustomizada();
          break;

        default:
          logoPath = await _logoUploadService.uploadLogoToAppDirectory();
      }

      if (logoPath != null) {
        // Atualizar o LogoManager
        _logoManager.updateLogoPath(logoPath);

        // Salvar no banco de dados
        final db = DatabaseService();
        await _salvarOuAtualizarConfiguracao(
          db,
          'logo_path',
          logoPath,
          'Caminho do logo da loja',
        );

        _mostrarMensagem(
          'Logo enviado e salvo com sucesso!\nSalvo em: $logoPath',
          Colors.green,
        );

        _atualizarSidebarHeader();
      }
    } catch (e) {
      _mostrarMensagem('Erro ao enviar logo: $e', Colors.red);
      if (kDebugMode) {
        print('Erro detalhado ao enviar logo: $e');
      }
    }
  }

  Future<String?> _selecionarPastaCustomizada() async {
    // Aqui você pode implementar um seletor de pasta
    // Por simplicidade, vou usar uma pasta padrão customizada
    final customPath = Platform.isWindows
        ? 'C:\\LojaApp\\logos'
        : '/opt/loja-app';

    return await _logoUploadService.uploadLogoToCustomDirectory(customPath);
  }

  Future<void> _removerLogo() async {
    try {
      final currentLogoPath = _logoManager.currentLogoPath;

      if (currentLogoPath != null) {
        await _logoUploadService.removeLogo(currentLogoPath);
      }

      _logoManager.updateLogoPath(null);

      final db = DatabaseService();
      await db.deleteConfiguracao('logo_path');

      _mostrarMensagem('Logo removido com sucesso!', Colors.green);
      _atualizarSidebarHeader();
    } catch (e) {
      _mostrarMensagem('Erro ao remover logo: $e', Colors.red);
    }
  }

  void _atualizarSidebarHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sidebarHeaderState = sidebarHeaderKey.currentState;
      if (sidebarHeaderState != null) {
        sidebarHeaderState.atualizarInformacoes();
      }
    });
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: cor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildUploadOptionsCard() {
    return _buildSectionCard(
      title: 'Opções de Upload',
      icon: Icons.settings,
      children: [
        Text(
          'Escolha onde salvar o logo:',
          style: AppTheme.getResponsiveBody1(
            context,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            AppTheme.spacingM,
          ),
        ),

        // Pasta da aplicação
        RadioListTile<String>(
          value: 'app_directory',
          groupValue: _selectedUploadOption,
          onChanged: (value) => setState(() => _selectedUploadOption = value!),
          title: const Text('Pasta da Aplicação'),
          subtitle: const Text('Salva na pasta onde está o executável'),
        ),

        // Pasta do sistema
        RadioListTile<String>(
          value: 'system_directory',
          groupValue: _selectedUploadOption,
          onChanged: (value) => setState(() => _selectedUploadOption = value!),
          title: const Text('Pasta do Sistema'),
          subtitle: Text(
            Platform.isWindows
                ? 'C:\\ProgramData\\LojaApp\\logos'
                : Platform.isLinux
                ? '/opt/loja-app/logos'
                : '/Applications/LojaApp/logos',
          ),
        ),

        // Assets (para build)
        RadioListTile<String>(
          value: 'assets',
          groupValue: _selectedUploadOption,
          onChanged: (value) => setState(() => _selectedUploadOption = value!),
          title: const Text('Pasta Assets'),
          subtitle: const Text(
            'Inclui no build da aplicação (assets/images/custom)',
          ),
        ),

        // Customizada
        RadioListTile<String>(
          value: 'custom',
          groupValue: _selectedUploadOption,
          onChanged: (value) => setState(() => _selectedUploadOption = value!),
          title: const Text('Pasta Customizada'),
          subtitle: const Text('Permite escolher uma pasta específica'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Carregando configurações...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            if (!_isLoading)
              IconButton(
                onPressed: _isSaving ? null : _salvarConfiguracoes,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save),
                tooltip: 'Salvar configurações',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de Logo da Loja
                _buildSectionCard(
                  title: 'Logo da Loja',
                  icon: Icons.image,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview do logo
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingM,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveRadius(
                                context,
                                AppTheme.radiusM,
                              ),
                            ),
                          ),
                          child: _logoManager.buildLogoWidget(
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            AppTheme.spacingL,
                          ),
                        ),

                        // Informações e botões
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logo Atual',
                                style: AppTheme.getResponsiveHeadline4(
                                  context,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  AppTheme.spacingS,
                                ),
                              ),

                              // Status e path do logo
                              ValueListenableBuilder<String?>(
                                valueListenable: _logoManager.logoPathNotifier,
                                builder: (context, logoPath, child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        logoPath != null
                                            ? 'Logo personalizado carregado'
                                            : 'Usando logo padrão',
                                        style: AppTheme.getResponsiveBody2(
                                          context,
                                        ).copyWith(color: Colors.grey[600]),
                                      ),
                                      if (logoPath != null) ...[
                                        SizedBox(
                                          height:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                AppTheme.spacingXS,
                                              ),
                                        ),
                                        Text(
                                          'Caminho: $logoPath',
                                          style: AppTheme.getResponsiveCaption(
                                            context,
                                          ).copyWith(color: Colors.grey[500]),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),

                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  AppTheme.spacingM,
                                ),
                              ),

                              // Botões
                              CustomButton(
                                text: 'Enviar Logo',
                                variant: ButtonVariant.primary,
                                icon: Icons.upload,
                                onPressed: _isSaving ? null : _selecionarLogo,
                              ),

                              ValueListenableBuilder<String?>(
                                valueListenable: _logoManager.logoPathNotifier,
                                builder: (context, logoPath, child) {
                                  if (logoPath != null) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                AppTheme.spacingS,
                                              ),
                                        ),
                                        CustomButton(
                                          text: 'Remover Logo',
                                          variant: ButtonVariant.outline,
                                          icon: Icons.delete_outline,
                                          onPressed: _isSaving
                                              ? null
                                              : _removerLogo,
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),

                // Cards de configurações gerais e financeiras...
                _buildSectionCard(
                  title: 'Configurações Gerais',
                  icon: Icons.settings,
                  children: [
                    CustomTextFormField(
                      controller: _nomeLojController,
                      label: 'Nome da Loja',
                      prefixIcon: Icons.business,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome da loja é obrigatório';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingM,
                      ),
                    ),
                    CustomTextFormField(
                      controller: _cnpjController,
                      label: 'CNPJ',
                      prefixIcon: Icons.business,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'CNPJ da loja é obrigatório';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),

                _buildSectionCard(
                  title: 'Configurações Financeiras',
                  icon: Icons.monetization_on,
                  children: [
                    CustomTextFormField(
                      controller: _valorContribuicaoController,
                      label: 'Valor da Contribuição Mensal (R\$)',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Valor da contribuição é obrigatório';
                        }
                        final valor = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (valor == null || valor <= 0) {
                          return 'Valor deve ser um número válido maior que zero';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),

                // Card de opções de upload
                _buildUploadOptionsCard(),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),

                // Botões de ação
                ResponsiveUtils.isSmallScreen(context)
                    ? Column(
                        children: [
                          CustomButton(
                            text: 'Recarregar',
                            variant: ButtonVariant.outline,
                            icon: Icons.refresh,
                            onPressed: _isSaving
                                ? null
                                : _carregarConfiguracoes,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingM,
                            ),
                          ),
                          CustomButton(
                            text: _isSaving ? 'Salvando...' : 'Salvar',
                            variant: ButtonVariant.primary,
                            icon: Icons.save,
                            isLoading: _isSaving,
                            onPressed: _isSaving ? null : _salvarConfiguracoes,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Recarregar',
                              variant: ButtonVariant.outline,
                              icon: Icons.refresh,
                              onPressed: _isSaving
                                  ? null
                                  : _carregarConfiguracoes,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingM,
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              text: _isSaving ? 'Salvando...' : 'Salvar',
                              variant: ButtonVariant.primary,
                              icon: Icons.save,
                              isLoading: _isSaving,
                              onPressed: _isSaving
                                  ? null
                                  : _salvarConfiguracoes,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return CustomCard(
      variant: CardVariant.default_,
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          AppTheme.spacingS,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, AppTheme.spacingM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 28),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),
                Text(
                  title,
                  style: AppTheme.getResponsiveHeadline3(
                    context,
                  ).copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                AppTheme.spacingL,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

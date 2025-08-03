// screens/configuracoes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/custom_card.dart';
import 'package:flutter_dashboard_3/widgets/custom_loading.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar_header.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  String? _logoPath;
  final ImagePicker _picker = ImagePicker();

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
      _logoPath = logoPath;
    } catch (e) {
      _mostrarMensagem('Erro ao carregar configurações: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarConfiguracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService();

      // Salvar valor da contribuição
      await db.updateConfiguracao(
        'valor_contribuicao_mensal',
        _valorContribuicaoController.text.replaceAll(',', '.'),
        descricao: 'Valor da contribuição mensal dos membros da loja',
      );

      // Salvar nome da loja
      await db.updateConfiguracao(
        'nome_loja',
        _nomeLojController.text.trim(),
        descricao: 'Nome da loja maçônica',
      );

      // Salvar CNPJ
      await db.updateConfiguracao(
        'cnpj',
        _cnpjController.text.trim(),
        descricao: 'CNPJ',
      );

      // Salvar caminho do logo se houver
      if (_logoPath != null) {
        await db.updateConfiguracao(
          'logo_path',
          _logoPath!,
          descricao: 'Caminho do logo da loja',
        );
      }

      _mostrarMensagem('Configurações salvas com sucesso!', Colors.green);

      // Atualizar o header da sidebar se estiver disponível
      _atualizarSidebarHeader();
    } catch (e) {
      _mostrarMensagem('Erro ao salvar configurações: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selecionarLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Obter diretório de documentos da aplicação
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;

        // Criar diretório para logos se não existir
        final Directory logoDir = Directory('$appDocPath/logos');
        if (!await logoDir.exists()) {
          await logoDir.create(recursive: true);
        }

        // Definir nome do arquivo
        final String fileName = 'logo-loja.png';
        final String newPath = '${logoDir.path}/$fileName';

        // Copiar arquivo selecionado para o diretório da aplicação
        final File newFile = await File(image.path).copy(newPath);

        setState(() {
          _logoPath = newFile.path;
        });

        _mostrarMensagem('Logo selecionado com sucesso!', Colors.green);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao selecionar logo: $e', Colors.red);
    }
  }

  Future<void> _removerLogo() async {
    try {
      if (_logoPath != null) {
        final File logoFile = File(_logoPath!);
        if (await logoFile.exists()) {
          await logoFile.delete();
        }
      }

      setState(() {
        _logoPath = null;
      });

      // Remover da configuração no banco
      final db = DatabaseService();
      await db.deleteConfiguracao('logo_path');

      _mostrarMensagem('Logo removido com sucesso!', Colors.green);
    } catch (e) {
      _mostrarMensagem('Erro ao remover logo: $e', Colors.red);
    }
  }

  Widget _getCurrentLogo() {
    // Primeiro, verificar se há um logo personalizado
    if (_logoPath != null && File(_logoPath!).existsSync()) {
      return Image.file(
        File(_logoPath!),
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      );
    }

    // Caso contrário, usar o logo padrão dos assets
    return Image.asset(
      'assets/images/logo-loja.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, size: 60, color: Colors.grey),
        );
      },
    );
  }

  void _atualizarSidebarHeader() {
    // Atualizar o header da sidebar usando a GlobalKey
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
                        // Preview do logo atual
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingM,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveRadius(
                                context,
                                AppTheme.radiusM,
                              ),
                            ),
                          ),
                          child: _getCurrentLogo(),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            AppTheme.spacingL,
                          ),
                        ),
                        // Botões de ação
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
                              Text(
                                _logoPath != null
                                    ? 'Logo personalizado carregado'
                                    : 'Usando logo padrão',
                                style: AppTheme.getResponsiveBody2(
                                  context,
                                ).copyWith(color: Colors.grey[600]),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  AppTheme.spacingM,
                                ),
                              ),
                              CustomButton(
                                text: 'Alterar Logo',
                                variant: ButtonVariant.primary,
                                icon: Icons.upload,
                                onPressed: _isSaving ? null : _selecionarLogo,
                              ),
                              if (_logoPath != null) ...[
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    AppTheme.spacingS,
                                  ),
                                ),
                                CustomButton(
                                  text: 'Remover Logo',
                                  variant: ButtonVariant.outline,
                                  icon: Icons.delete_outline,
                                  onPressed: _isSaving ? null : _removerLogo,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingM,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(
                          context,
                          AppTheme.spacingM,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveRadius(
                            context,
                            AppTheme.radiusM,
                          ),
                        ),
                        border: Border.all(
                          color: AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.info),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingS,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'O logo será exibido no cabeçalho da aplicação e nos relatórios. Recomenda-se usar imagens em formato PNG com fundo transparente.',
                              style: AppTheme.getResponsiveBody2(
                                context,
                              ).copyWith(color: AppTheme.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingS,
                  ),
                ),

                // Card de Configurações Gerais
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

                // Card de Configurações Financeiras
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
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingM,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(
                          context,
                          AppTheme.spacingM,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveRadius(
                            context,
                            AppTheme.radiusM,
                          ),
                        ),
                        border: Border.all(
                          color: AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.info),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              AppTheme.spacingS,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Este valor será usado como padrão ao gerar as contribuições mensais para todos os membros ativos.',
                              style: AppTheme.getResponsiveBody2(
                                context,
                              ).copyWith(color: AppTheme.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    AppTheme.spacingXL,
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
          AppTheme.spacingL,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, AppTheme.spacingL),
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

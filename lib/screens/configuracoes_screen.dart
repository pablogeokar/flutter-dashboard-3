// screens/configuracoes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';

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

      _valorContribuicaoController.text =
          double.tryParse(valorContribuicao ?? '100.00')?.toStringAsFixed(2) ??
          '100.00';
      _nomeLojController.text = nomeLoja ?? 'Loja Maçônica';
      _cnpjController.text = cnpj ?? '01.234.567/0001-89';
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

      _mostrarMensagem('Configurações salvas com sucesso!', Colors.green);
    } catch (e) {
      _mostrarMensagem('Erro ao salvar configurações: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
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
    return Scaffold(
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Salvar configurações',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white70 /*Colors.blue[700]*/,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Este valor será usado como padrão ao gerar as contribuições mensais para todos os membros ativos.',
                                  style: TextStyle(
                                    //color: Colors.blue[700],
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSaving
                                ? null
                                : _carregarConfiguracoes,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recarregar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _salvarConfiguracoes,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white54, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

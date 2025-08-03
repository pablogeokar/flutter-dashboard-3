import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard_3/services/contabilidade_service.dart';
import 'package:flutter_dashboard_3/utils/get_nome_sobrenome.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/custom_loading.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/models/contribuicao.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';

class ContribuicaoFormModal extends StatefulWidget {
  final Contribuicao? contribuicao;

  const ContribuicaoFormModal({super.key, this.contribuicao});

  @override
  State<ContribuicaoFormModal> createState() => _ContribuicaoFormModalState();
}

class _ContribuicaoFormModalState extends State<ContribuicaoFormModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _valorController;
  late TextEditingController _observacoesController;

  String _statusSelecionado = 'pendente';
  DateTime? _dataPagamento;

  final List<String> _statusList = ['pendente', 'pago', 'cancelado'];
  final Map<String, String> _statusLabels = {
    'pendente': 'Pendente',
    'pago': 'Pago',
    'cancelado': 'Cancelado',
  };

  bool _isLoading = false;
  bool get _isEditing => widget.contribuicao != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _preencherCampos();
  }

  void _initializeControllers() {
    _valorController = TextEditingController();
    _observacoesController = TextEditingController();
  }

  void _preencherCampos() {
    if (_isEditing && widget.contribuicao != null) {
      _valorController.text = widget.contribuicao!.valor.toStringAsFixed(2);
      _observacoesController.text = widget.contribuicao!.observacoes ?? '';
      _statusSelecionado = widget.contribuicao!.status;
      _dataPagamento = widget.contribuicao!.dataPagamento;
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataPagamento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataPagamento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() => _dataPagamento = data);
    }
  }

  Future<void> _salvarContribuicao() async {
    if (_formKey.currentState!.validate()) {
      // Validações específicas
      if (_statusSelecionado == 'pago' && _dataPagamento == null) {
        _mostrarMensagem(
          'Data de pagamento é obrigatória quando status é "pago"',
          Colors.red,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final db = DatabaseService();

        if (_isEditing) {
          final contribuicaoAtualizada = widget.contribuicao!.copyWith(
            valor: double.parse(_valorController.text.replaceAll(',', '.')),
            status: _statusSelecionado,
            dataPagamento: _statusSelecionado == 'pago' ? _dataPagamento : null,
            observacoes: _observacoesController.text.trim().isEmpty
                ? null
                : _observacoesController.text.trim(),
          );

          await db.updateContribuicao(contribuicaoAtualizada);

          if (_statusSelecionado == 'pago') {
            // Registrar a contribuição no serviço de contabilidade
            final contabilidadeService = ContabilidadeService();
            await contabilidadeService.receberContribuicaoMensal(
              nomeMembro: getNomeSobrenome(
                widget.contribuicao!.membroNome ?? 'Membro não encontrado',
              ),
              valor: contribuicaoAtualizada.valor,
              emDinheiro: true, // ou false para banco
            );
          }

          if (mounted) {
            _mostrarMensagem(
              'Contribuição atualizada com sucesso!',
              Colors.green,
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          _mostrarMensagem('Erro ao salvar contribuição: $e', Colors.red);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header do Modal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editar Contribuição',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isEditing && widget.contribuicao != null)
                          Text(
                            '${widget.contribuicao!.membroNome} - ${widget.contribuicao!.periodoReferencia}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
            ),

            // Corpo do Modal
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações do membro (somente leitura)
                        if (_isEditing && widget.contribuicao != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informações da Contribuição',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Membro: ${widget.contribuicao!.membroNome}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      'Período: ${widget.contribuicao!.periodoReferencia}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gerada em: ${_formatarData(widget.contribuicao!.dataGeracao)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_isEditing) const SizedBox(height: 24),

                        // Valor da contribuição
                        CustomTextFormField(
                          controller: _valorController,
                          label: 'Valor da Contribuição (R\$)',
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
                              return 'Valor é obrigatório';
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

                        // Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status *',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _statusSelecionado,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.info),
                                border: const OutlineInputBorder(),
                                filled: true,
                              ),
                              items: _statusList.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(_statusLabels[status]!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _statusSelecionado = value!;

                                  // Limpar data de pagamento se não for status "pago"
                                  if (_statusSelecionado != 'pago') {
                                    _dataPagamento = null;
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Status é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Data de pagamento (apenas se status for "pago")
                        if (_statusSelecionado == 'pago')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data de Pagamento *',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selecionarDataPagamento,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _dataPagamento != null
                                            ? _formatarData(_dataPagamento!)
                                            : 'Selecionar data de pagamento',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _dataPagamento != null
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Observações
                        CustomTextFormField(
                          controller: _observacoesController,
                          label: 'Observações',
                          prefixIcon: Icons.note,
                          maxLines: 3,
                          hintText: _statusSelecionado == 'cancelado'
                              ? 'Informe o motivo do cancelamento...'
                              : 'Adicione observações sobre esta contribuição...',
                        ),

                        // Aviso para cancelamento
                        if (_statusSelecionado == 'cancelado')
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_outlined,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ao cancelar uma contribuição, é recomendado informar o motivo nas observações.',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer com botões
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusL),
                  bottomRight: Radius.circular(AppTheme.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Cancelar',
                    variant: ButtonVariant.text,
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  CustomButton(
                    text: 'Salvar',
                    variant: ButtonVariant.primary,
                    icon: Icons.save,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _salvarContribuicao,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

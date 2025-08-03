import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/screens/pdf_preview_screen.dart';
import 'package:flutter_dashboard_3/services/contabilidade_service.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/models/contribuicao.dart';
import 'package:flutter_dashboard_3/services/pdf_service.dart';
import 'package:flutter_dashboard_3/utils/currency_format.dart';
import 'package:flutter_dashboard_3/utils/get_nome_sobrenome.dart';
import 'package:flutter_dashboard_3/widgets/custom_dropdown_form_field.dart';
import 'package:flutter_dashboard_3/widgets/filter_widget.dart';
import 'package:flutter_dashboard_3/widgets/modals/contribuicao_form_modal.dart';
import 'package:flutter_dashboard_3/widgets/card_financeiro.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/custom_card.dart';
import 'package:flutter_dashboard_3/widgets/custom_loading.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';

class ContribuicoesScreen extends StatefulWidget {
  const ContribuicoesScreen({super.key});

  @override
  State<ContribuicoesScreen> createState() => _ContribuicoesScreenState();
}

class _ContribuicoesScreenState extends State<ContribuicoesScreen> {
  List<Contribuicao> _contribuicoes = [];
  List<Contribuicao> _contribuicoesFiltradas = [];
  Map<String, dynamic> _estatisticas = {};
  bool _isLoading = true;
  bool _temFiltroAtivo = false;

  int _mesReferencia = DateTime.now().month;
  int _anoReferencia = DateTime.now().year;

  final List<String> _meses = [
    '',
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseService();

      final contribuicoes = await db.getContribuicoes(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      final estatisticas = await db.getEstatisticasContribuicoes(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      setState(() {
        _contribuicoes = contribuicoes;
        _estatisticas = estatisticas;
        _contribuicoesFiltradas =
            contribuicoes; // Inicializar com todas as contribuições
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar dados: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros(FilterValues filterValues) {
    setState(() {
      final filtroMembro = filterValues['membro'] ?? '';
      _temFiltroAtivo = filtroMembro.isNotEmpty;

      _contribuicoesFiltradas = _contribuicoes.where((contribuicao) {
        final matchMembro =
            filtroMembro.isEmpty ||
            (contribuicao.membroNome ?? '').toLowerCase().contains(
              filtroMembro.toLowerCase(),
            );
        return matchMembro;
      }).toList();
    });
  }

  Future<void> _gerarContribuicoes() async {
    // Verificar se já existem contribuições para o período
    final db = DatabaseService();
    final existem = await db.existemContribuicoesPeriodo(
      _mesReferencia,
      _anoReferencia,
    );

    if (existem) {
      final confirmacao = await _mostrarDialogoConfirmacao(
        'Contribuições Existentes',
        'Já existem contribuições geradas para ${_meses[_mesReferencia]}/$_anoReferencia. '
            'Deseja gerar apenas para os membros que ainda não possuem contribuição neste período?',
      );

      if (!confirmacao) return;
    }

    try {
      _mostrarDialogoCarregamento('Gerando contribuições...');

      final resultado = await db.gerarContribuicoesMensais(
        mesReferencia: _mesReferencia,
        anoReferencia: _anoReferencia,
      );

      if (mounted) Navigator.pop(context); // Fechar diálogo de carregamento

      if (resultado['sucesso']) {
        _mostrarMensagem(
          'Contribuições geradas: ${resultado['geradas']}\n'
          'Já existentes: ${resultado['existentes']}\n'
          'Total de membros: ${resultado['total_membros']}',
          Colors.green,
        );

        await _carregarDados();
      } else {
        _mostrarMensagem(resultado['mensagem'], Colors.orange);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Fechar diálogo de carregamento
      _mostrarMensagem('Erro ao gerar contribuições: $e', Colors.red);
    }
  }

  Future<void> _marcarComoPago(Contribuicao contribuicao) async {
    final observacoes = await _mostrarDialogoObservacoes(
      'Marcar como Pago',
      'Adicione observações sobre o pagamento (opcional):',
    );

    if (observacoes == null) return; // Usuário cancelou

    try {
      final db = DatabaseService();
      final sucesso = await db.marcarContribuicaoPaga(
        contribuicao.id!,
        observacoes: observacoes.isEmpty ? null : observacoes,
      );

      if (sucesso) {
        // Registrar a contribuição no serviço de contabilidade
        final contabilidadeService = ContabilidadeService();
        await contabilidadeService.receberContribuicaoMensal(
          nomeMembro: getNomeSobrenome(
            contribuicao.membroNome ?? 'Membro não encontrado',
          ),
          valor: contribuicao.valor,
          emDinheiro: true, // ou false para banco
        );

        // Atualizar a lista de contribuições e exibe a mensagem de sucesso
        _mostrarMensagem('Contribuição marcada como paga!', Colors.green);
        await _carregarDados();
      } else {
        _mostrarMensagem('Erro ao marcar contribuição como paga', Colors.red);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao marcar contribuição como paga: $e', Colors.red);
    }
  }

  Future<void> _editarContribuicao(Contribuicao contribuicao) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => ContribuicaoFormModal(contribuicao: contribuicao),
    );

    if (resultado == true) {
      await _carregarDados();
    }
  }

  Future<void> _cancelarContribuicao(Contribuicao contribuicao) async {
    final motivo = await _mostrarDialogoObservacoes(
      'Cancelar Contribuição',
      'Informe o motivo do cancelamento:',
      obrigatorio: true,
    );

    if (motivo == null || motivo.isEmpty) return;

    try {
      final db = DatabaseService();
      final sucesso = await db.cancelarContribuicao(
        contribuicao.id!,
        motivoCancelamento: motivo,
      );

      if (sucesso) {
        _mostrarMensagem('Contribuição cancelada!', Colors.green);
        await _carregarDados();
      } else {
        _mostrarMensagem('Erro ao cancelar contribuição', Colors.red);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao cancelar contribuição: $e', Colors.red);
    }
  }

  Future<bool> _mostrarDialogoConfirmacao(
    String titulo,
    String mensagem,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  Future<String?> _mostrarDialogoObservacoes(
    String titulo,
    String mensagem, {
    bool obrigatorio = false,
  }) async {
    final controller = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagem),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite aqui...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (obrigatorio && texto.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campo obrigatório')),
                );
                return;
              }
              Navigator.pop(context, texto);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return resultado;
  }

  void _mostrarDialogoCarregamento(String mensagem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(mensagem)),
          ],
        ),
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pago':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Carregando contribuições...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contribuições Mensais'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _carregarDados,
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filtros e estatísticas
            _buildHeaderSection(),

            // Lista de contribuições
            Expanded(
              child: _contribuicoes.isEmpty
                  ? _buildEmptyState()
                  : _buildContribuicoesList(),
            ),
          ],
        ),
        floatingActionButton: CustomButton(
          text: 'Gerar Contribuições',
          variant: ButtonVariant.primary,
          icon: Icons.add,
          onPressed: _isLoading ? null : _gerarContribuicoes,
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isSmall = ResponsiveUtils.isSmallScreen(context);

    return CustomCard(
      variant: CardVariant.outlined,
      margin: ResponsiveUtils.getResponsiveMargin(
        context,
        all: AppTheme.spacingL,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, AppTheme.spacingXS),
        ),
        child: Column(
          children: [
            // Seletor de período
            isSmall
                ? Column(
                    children: [
                      CustomDropdownFormField(
                        value: _meses[_mesReferencia],
                        label: 'Mês',
                        items: _meses.sublist(
                          1,
                        ), // Remove o item vazio do início
                        onChanged: (valor) {
                          if (valor != null) {
                            final novoMes = _meses.indexOf(valor);
                            if (novoMes != _mesReferencia) {
                              setState(() => _mesReferencia = novoMes);
                              _carregarDados();
                            }
                          }
                        },
                        prefixIcon: Icons.calendar_today,
                      ),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          AppTheme.spacingM,
                        ),
                      ),
                      CustomDropdownFormField(
                        value: _anoReferencia.toString(),
                        label: 'Ano',
                        items: List.generate(10, (index) {
                          final ano = DateTime.now().year - 5 + index;
                          return ano.toString();
                        }),
                        onChanged: (valor) {
                          if (valor != null) {
                            final novoAno = int.parse(valor);
                            if (novoAno != _anoReferencia) {
                              setState(() => _anoReferencia = novoAno);
                              _carregarDados();
                            }
                          }
                        },
                        prefixIcon: Icons.calendar_view_month,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: CustomDropdownFormField(
                          value: _meses[_mesReferencia],
                          label: 'Mês',
                          items: _meses.sublist(
                            1,
                          ), // Remove o item vazio do início
                          onChanged: (valor) {
                            if (valor != null) {
                              final novoMes = _meses.indexOf(valor);
                              if (novoMes != _mesReferencia) {
                                setState(() => _mesReferencia = novoMes);
                                _carregarDados();
                              }
                            }
                          },
                          prefixIcon: Icons.calendar_today,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          AppTheme.spacingM,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdownFormField(
                          value: _anoReferencia.toString(),
                          label: 'Ano',
                          items: List.generate(10, (index) {
                            final ano = DateTime.now().year - 5 + index;
                            return ano.toString();
                          }),
                          onChanged: (valor) {
                            if (valor != null) {
                              final novoAno = int.parse(valor);
                              if (novoAno != _anoReferencia) {
                                setState(() => _anoReferencia = novoAno);
                                _carregarDados();
                              }
                            }
                          },
                          prefixIcon: Icons.calendar_view_month,
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

            // Campo de busca por membro
            FilterWidget(
              filters: [
                CommonFilters.textSearch(
                  key: 'membro',
                  label: 'Buscar por membro',
                  hintText: 'Digite o nome do membro...',
                ),
              ],
              onFiltersChanged: _aplicarFiltros,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                AppTheme.spacingM,
              ),
            ),

            // Estatísticas
            if (_estatisticas.isNotEmpty) _buildEstatisticasCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatisticasCards() {
    final totalGeral = _estatisticas['total_geral'] ?? {};
    final porStatus = _estatisticas['por_status'] ?? {};
    final isSmall = ResponsiveUtils.isSmallScreen(context);

    return isSmall
        ? Column(
            children: [
              CardFinanceiro(
                titulo: 'Total',
                valor:
                    '${totalGeral['quantidade'] ?? 0}\nR\$ ${(totalGeral['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                icone: Icons.monetization_on,
                cor: Colors.blue,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              CardFinanceiro(
                titulo: 'Pagas',
                valor:
                    '${porStatus['pago']?['quantidade'] ?? 0}\nR\$ ${(porStatus['pago']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                icone: Icons.check_circle,
                cor: Colors.green,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              CardFinanceiro(
                titulo: 'Pendentes',
                valor:
                    '${porStatus['pendente']?['quantidade'] ?? 0}\nR\$ ${(porStatus['pendente']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                icone: Icons.schedule,
                cor: Colors.orange,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: CardFinanceiro(
                  titulo: 'Total',
                  valor:
                      '${totalGeral['quantidade'] ?? 0}\nR\$ ${(totalGeral['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                  icone: Icons.monetization_on,
                  cor: Colors.blue,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Expanded(
                child: CardFinanceiro(
                  titulo: 'Pagas',
                  valor:
                      '${porStatus['pago']?['quantidade'] ?? 0}\nR\$ ${(porStatus['pago']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                  icone: Icons.check_circle,
                  cor: Colors.green,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Expanded(
                child: CardFinanceiro(
                  titulo: 'Pendentes',
                  valor:
                      '${porStatus['pendente']?['quantidade'] ?? 0}\nR\$ ${(porStatus['pendente']?['valor_total'] ?? 0.0).toStringAsFixed(2)}',
                  icone: Icons.schedule,
                  cor: Colors.orange,
                ),
              ),
            ],
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: ResponsiveUtils.getResponsiveIconSize(context, 64),
            color: Colors.grey[400],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              AppTheme.spacingM,
            ),
          ),
          Text(
            'Nenhuma contribuição encontrada',
            style: AppTheme.getResponsiveHeadline4(
              context,
            ).copyWith(color: Colors.grey[600]),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              AppTheme.spacingS,
            ),
          ),
          Text(
            'para ${_meses[_mesReferencia]}/$_anoReferencia',
            style: AppTheme.getResponsiveBody2(
              context,
            ).copyWith(color: Colors.grey[500]),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              AppTheme.spacingL,
            ),
          ),
          CustomButton(
            text: 'Gerar Contribuições',
            variant: ButtonVariant.primary,
            icon: Icons.add,
            onPressed: _gerarContribuicoes,
          ),
        ],
      ),
    );
  }

  Widget _buildContribuicoesList() {
    final contribuicoesParaExibir =
        _contribuicoesFiltradas.isNotEmpty || _temFiltroAtivo
        ? _contribuicoesFiltradas
        : _contribuicoes;

    if (contribuicoesParaExibir.isEmpty && _temFiltroAtivo) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Nenhum membro encontrado',
              style: AppTheme.headline4.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Tente ajustar o filtro de busca',
              style: AppTheme.body2.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: ResponsiveUtils.getResponsivePadding(
        context,
        horizontal: 16,
        vertical: 16,
      ),
      itemCount: contribuicoesParaExibir.length,
      itemBuilder: (context, index) {
        final contribuicao = contribuicoesParaExibir[index];
        return _buildContribuicaoCard(contribuicao);
      },
    );
  }

  Widget _buildContribuicaoCard(Contribuicao contribuicao) {
    return CustomCard(
      variant: CardVariant.default_,
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          AppTheme.spacingS,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(contribuicao.status),
          radius: ResponsiveUtils.getResponsiveRadius(context, 20),
          child: Icon(
            contribuicao.isPago
                ? Icons.check
                : contribuicao.isCancelado
                ? Icons.close
                : Icons.schedule,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
          ),
        ),
        title: Text(
          contribuicao.membroNome ?? 'Membro não encontrado',
          style: AppTheme.getResponsiveHeadline4(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currencyFormat.format(contribuicao.valor),
              style: AppTheme.getResponsiveBody1(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                AppTheme.spacingXS,
              ),
            ),
            if (contribuicao.dataPagamento != null) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  AppTheme.spacingXS,
                ),
              ),
              Text(
                'Pago em: ${contribuicao.dataPagamento!.day.toString().padLeft(2, '0')}/'
                '${contribuicao.dataPagamento!.month.toString().padLeft(2, '0')}/'
                '${contribuicao.dataPagamento!.year}',
                style: AppTheme.getResponsiveCaption(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
            if (contribuicao.observacoes != null &&
                contribuicao.observacoes!.isNotEmpty) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  AppTheme.spacingXS,
                ),
              ),
              Text(
                'Obs: ${contribuicao.observacoes}',
                style: AppTheme.getResponsiveCaption(context).copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            switch (valor) {
              case 'editar':
                _editarContribuicao(contribuicao);
                break;
              case 'pagar':
                _marcarComoPago(contribuicao);
                break;
              case 'cancelar':
                _cancelarContribuicao(contribuicao);
                break;
              case 'visualizar':
                _visualizarRecibo(contribuicao);
                break;
              case 'imprimir':
                _imprimirRecibo(contribuicao);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      AppTheme.spacingS,
                    ),
                  ),
                  Text('Editar'),
                ],
              ),
            ),
            if (contribuicao.isPago) ...[
              PopupMenuItem(
                value: 'visualizar',
                child: Row(
                  children: [
                    Icon(Icons.preview, color: Colors.blue),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingS,
                      ),
                    ),
                    Text('Visualizar Recibo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'imprimir',
                child: Row(
                  children: [
                    Icon(Icons.print, color: Colors.blue),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingS,
                      ),
                    ),
                    Text('Imprimir Recibo'),
                  ],
                ),
              ),
            ],
            if (contribuicao.isPendente) ...[
              PopupMenuItem(
                value: 'pagar',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingS,
                      ),
                    ),
                    Text('Marcar como Pago'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancelar',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        AppTheme.spacingS,
                      ),
                    ),
                    Text('Cancelar'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _visualizarRecibo(Contribuicao contribuicao) async {
    try {
      _mostrarDialogoCarregamento('Gerando pré-visualização...');
      final pdfFile = await PdfService.generateContributionReceipt(
        contribuicao,
      );
      final pdfBytes = await pdfFile.readAsBytes();

      if (mounted) {
        Navigator.pop(context); // Fecha o diálogo de carregamento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(pdfBytes: pdfBytes),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fecha o diálogo de carregamento
        _mostrarMensagem('Erro ao gerar recibo: $e', Colors.red);
      }
    }
  }

  Future<void> _imprimirRecibo(Contribuicao contribuicao) async {
    try {
      _mostrarDialogoCarregamento('Preparando impressão...');
      await PdfService.printReceipt(contribuicao);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _mostrarMensagem('Erro ao imprimir: $e', Colors.red);
      }
    }
  }
}

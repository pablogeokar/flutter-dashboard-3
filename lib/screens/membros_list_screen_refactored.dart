import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/widgets/icon_styled.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/custom_card.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_3/widgets/custom_loading.dart';
import 'package:flutter_dashboard_3/widgets/status_chip.dart';
import 'package:flutter_dashboard_3/widgets/data_table_custom.dart';
import 'package:flutter_dashboard_3/theme.dart';
import '../widgets/modals/membros_form_modal.dart';
import '../widgets/modals/excel_import_modal.dart';

class MembrosListScreenRefactored extends StatefulWidget {
  const MembrosListScreenRefactored({super.key});

  @override
  State<MembrosListScreenRefactored> createState() =>
      _MembrosListScreenRefactoredState();
}

class _MembrosListScreenRefactoredState
    extends State<MembrosListScreenRefactored> {
  final DatabaseService _db = DatabaseService();
  List<Membro> _membros = [];
  List<Membro> _membrosFiltrados = [];
  bool _isLoading = true;
  String _filtroStatus = 'todos';
  String _filtroNome = '';

  final TextEditingController _nomeController = TextEditingController();

  final List<String> _statusFilterList = [
    'todos',
    'ativo',
    'inativo',
    'pausado',
  ];

  List<DataTableColumn> get _tableColumns => [
    const DataTableColumn(key: 'nome', label: 'Nome', width: 360),
    const DataTableColumn(key: 'email', label: 'E-mail', width: 200),
    const DataTableColumn(key: 'telefone', label: 'Telefone', width: 140),
    DataTableColumn(
      key: 'status',
      label: 'Status',
      width: 110,
      cellBuilder: (value) =>
          StatusChipHelper.membroStatus(value?.toString() ?? 'N/A'),
    ),
    DataTableColumn(
      key: 'acoes',
      label: 'Ações',
      width: 110,
      cellBuilder: (value) {
        if (value is Membro) {
          return _buildActionsButtons(value);
        }
        return const SizedBox();
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carregarMembros();
    _nomeController.addListener(() {
      _filtroNome = _nomeController.text;
      _aplicarFiltros();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarMembros() async {
    setState(() => _isLoading = true);
    try {
      final membros = await _db.getMembros();
      setState(() {
        _membros = membros;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensagem('Erro ao carregar membros: $e', Colors.red);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _membrosFiltrados = _membros.where((membro) {
        final matchStatus =
            _filtroStatus == 'todos' || membro.status == _filtroStatus;
        final matchNome =
            _filtroNome.isEmpty ||
            membro.nome.toLowerCase().contains(_filtroNome.toLowerCase());
        return matchStatus && matchNome;
      }).toList();
    });
  }

  Widget _buildActionsButtons(Membro membro) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: '',
          variant: ButtonVariant.text,
          size: ButtonSize.small,
          icon: Icons.edit,
          onPressed: () => _editarMembro(membro),
        ),
        CustomButton(
          text: '',
          variant: ButtonVariant.text,
          size: ButtonSize.small,
          icon: Icons.delete,
          onPressed: () => _excluirMembro(membro),
        ),
      ],
    );
  }

  Future<void> _editarMembro(Membro membro) async {
    final resultado = await showDialog<Membro>(
      context: context,
      builder: (context) => MembrosFormModal(membro: membro),
    );

    if (resultado != null) {
      await _carregarMembros();
      _mostrarMensagem('Membro atualizado com sucesso!', Colors.green);
    }
  }

  Future<void> _excluirMembro(Membro membro) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o membro "${membro.nome}"?'),
        actions: [
          CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CustomButton(
            text: 'Excluir',
            variant: ButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await _db.deleteMembro(membro.id!);
        await _carregarMembros();
        _mostrarMensagem('Membro excluído com sucesso!', Colors.green);
      } catch (e) {
        _mostrarMensagem('Erro ao excluir membro: $e', Colors.red);
      }
    }
  }

  Future<void> _adicionarMembro() async {
    final resultado = await showDialog<Membro>(
      context: context,
      builder: (context) => const MembrosFormModal(),
    );

    if (resultado != null) {
      await _carregarMembros();
      _mostrarMensagem('Membro adicionado com sucesso!', Colors.green);
    }
  }

  Future<void> _importarExcel() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => const ExcelImportModal(),
    );

    if (resultado == true) {
      await _carregarMembros();
      _mostrarMensagem('Membros importados com sucesso!', Colors.green);
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: cor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Carregando membros...',
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            CustomCard(
              variant: CardVariant.filled,
              margin: EdgeInsets.zero,
              child: CustomCardHeader(
                title: 'Gerenciamento de Membros',
                subtitle: '${_membrosFiltrados.length} membros encontrados',
                leading: const IconStyled(
                  icone: Icons.people,
                  cor: AppTheme.primaryColor,
                  isLarge: true,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Importar Excel',
                      variant: ButtonVariant.outline,
                      icon: Icons.upload_file,
                      onPressed: _importarExcel,
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    CustomButton(
                      text: 'Adicionar Membro',
                      variant: ButtonVariant.primary,
                      icon: Icons.add,
                      onPressed: _adicionarMembro,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Filtros
            CustomCard(
              variant: CardVariant.outlined,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _nomeController,
                        label: 'Buscar por nome',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    DropdownButtonFormField<String>(
                      value: _filtroStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _statusFilterList.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status == 'todos'
                                ? 'Todos'
                                : status[0].toUpperCase() + status.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _filtroStatus = value!;
                          _aplicarFiltros();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Tabela
            Expanded(
              child: CustomCard(
                variant: CardVariant.default_,
                margin: EdgeInsets.zero,
                child: DataTableCustom(
                  columns: _tableColumns,
                  data: _membrosFiltrados
                      .map(
                        (membro) => {
                          'nome': membro.nome,
                          'email': membro.email ?? 'N/A',
                          'telefone': membro.telefone ?? 'N/A',
                          'status': membro.status,
                          'acoes': membro,
                        },
                      )
                      .toList(),
                  emptyMessage: 'Nenhum membro encontrado',
                  totalLabel: 'Total de membros',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/widgets/custom_button.dart';
import 'package:flutter_dashboard_3/widgets/icon_styled.dart';
import 'package:flutter_dashboard_3/widgets/status_chip.dart';
import 'package:flutter_dashboard_3/theme.dart';
import '../widgets/modals/membros_form_modal.dart';
import '../widgets/modals/excel_import_modal.dart';
import '../widgets/data_table_custom.dart';
import '../widgets/filter_widget.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';

class MembrosListScreen extends StatefulWidget {
  const MembrosListScreen({super.key});

  @override
  State<MembrosListScreen> createState() => _MembrosListScreenState();
}

class _MembrosListScreenState extends State<MembrosListScreen> {
  final DatabaseService _db = DatabaseService();
  List<Membro> _membros = [];
  List<Membro> _membrosFiltrados = [];
  bool _isLoading = true;

  final List<String> _statusFilterList = [
    'todos',
    'ativo',
    'inativo',
    'pausado',
  ];

  // Definição das colunas para o novo DataTableCustom
  List<DataTableColumn> get _tableColumns {
    final isSmall = ResponsiveUtils.isSmallScreen(context);
    final isMedium = ResponsiveUtils.isMediumScreen(context);

    return [
      DataTableColumn(
        key: 'nome',
        label: 'Nome',
        width: isSmall
            ? 280
            : isMedium
            ? 320
            : 360,
      ),
      DataTableColumn(
        key: 'email',
        label: 'E-mail',
        width: isSmall
            ? 160
            : isMedium
            ? 180
            : 200,
      ),
      DataTableColumn(
        key: 'telefone',
        label: 'Telefone',
        width: isSmall
            ? 120
            : isMedium
            ? 130
            : 140,
      ),
      DataTableColumn(
        key: 'status',
        label: 'Status',
        width: isSmall
            ? 90
            : isMedium
            ? 100
            : 110,
        cellBuilder: (value) => _buildStatusChip(value?.toString() ?? 'N/A'),
      ),
      DataTableColumn(
        key: 'acoes',
        label: 'Ações',
        width: isSmall
            ? 90
            : isMedium
            ? 100
            : 110,
        cellBuilder: (value) {
          // O value aqui será o próprio objeto Membro
          if (value is Membro) {
            return _buildActionsButtons(value);
          }
          return const SizedBox();
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  Future<void> _carregarMembros() async {
    setState(() => _isLoading = true);
    try {
      final membros = await _db.getMembros();
      setState(() {
        _membros = membros;
        _membrosFiltrados = membros; // Inicializar com todos os membros
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensagem('Erro ao carregar membros: $e', Colors.red);
    }
  }

  void _aplicarFiltros(FilterValues filterValues) {
    setState(() {
      _membrosFiltrados = _membros.where((membro) {
        final filtroStatus = filterValues['status'] ?? 'todos';
        final filtroNome = filterValues['nome'] ?? '';

        final matchStatus =
            filtroStatus == 'todos' || membro.status == filtroStatus;
        final matchNome =
            filtroNome.isEmpty ||
            membro.nome.toLowerCase().contains(filtroNome.toLowerCase());
        return matchStatus && matchNome;
      }).toList();
    });
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
    }
  }

  Future<void> _abrirFormulario({Membro? membro}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MembrosFormModal(membro: membro),
    );

    if (resultado == true) {
      _carregarMembros();
    }
  }

  Future<void> _confirmarExclusao(Membro membro) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Text(
          'Confirmar Exclusão',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja realmente excluir o membro ${membro.nome}?',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFE53E3E).withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _db.deleteMembro(membro.id!);
        _mostrarMensagem(
          'Membro excluído com sucesso!',
          const Color(0xFF4CAF50),
        );
        _carregarMembros();
      } catch (e) {
        _mostrarMensagem('Erro ao excluir membro: $e', const Color(0xFFE53E3E));
      }
    }
  }

  Future<void> _abrirImportacaoExcel() async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExcelImportModal(),
    );

    if (resultado == true) {
      _carregarMembros();
      _mostrarMensagem('Lista de membros atualizada!', const Color(0xFF4CAF50));
    }
  }

  Widget _buildStatusChip(String status) {
    return StatusChipHelper.membroStatus(status);
  }

  Widget _buildActionsButtons(Membro membro) {
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);
    final buttonSize = ResponsiveUtils.isSmallScreen(context) ? 32.0 : 36.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _abrirFormulario(membro: membro),
          icon: Icon(Icons.edit, color: AppTheme.primaryColor),
          tooltip: 'Editar',
          iconSize: iconSize,
          constraints: BoxConstraints(
            minWidth: buttonSize,
            minHeight: buttonSize,
          ),
          padding: EdgeInsets.zero,
        ),
        SizedBox(
          width: ResponsiveUtils.getResponsiveSpacing(
            context,
            AppTheme.spacingXS,
          ),
        ),
        IconButton(
          onPressed: () => _confirmarExclusao(membro),
          icon: Icon(Icons.delete, color: AppTheme.error),
          tooltip: 'Excluir',
          iconSize: iconSize,
          constraints: BoxConstraints(
            minWidth: buttonSize,
            minHeight: buttonSize,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // Método para converter os membros em dados para a nova tabela
  List<Map<String, dynamic>> _prepararDadosTabela() {
    return _membrosFiltrados.map((membro) {
      return {
        'nome': membro.nome,
        'email': membro.email ?? 'N/A',
        'telefone': membro.telefone ?? 'N/A',
        'status': membro.status,
        'acoes': membro, // Passamos o objeto inteiro para usar no cellBuilder
      };
    }).toList();
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = ResponsiveUtils.isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 24.0),
      ),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveRadius(context, 16),
        ),
        border: Border.all(color: const Color(0xFF424242), width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSmall
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconStyled(icone: Icons.people),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Gerenciamento de Irmãos',
                            style: AppTheme.getResponsiveHeadline3(context)
                                .copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 16),
                    ),
                    Column(
                      children: [
                        CustomButton(
                          text: 'Importar Excel',
                          variant: ButtonVariant.outline,
                          icon: Icons.upload_file,
                          onPressed: _abrirImportacaoExcel,
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            AppTheme.spacingS,
                          ),
                        ),
                        CustomButton(
                          text: 'Adicionar Membro',
                          variant: ButtonVariant.primary,
                          icon: Icons.add,
                          onPressed: () => _abrirFormulario(),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconStyled(icone: Icons.people),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            16,
                          ),
                        ),
                        Text(
                          'Gerenciamento de Irmãos',
                          style: AppTheme.getResponsiveHeadline3(context)
                              .copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomButton(
                          text: 'Importar Excel',
                          variant: ButtonVariant.outline,
                          icon: Icons.upload_file,
                          onPressed: _abrirImportacaoExcel,
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            AppTheme.spacingM,
                          ),
                        ),
                        CustomButton(
                          text: 'Adicionar Membro',
                          variant: ButtonVariant.primary,
                          icon: Icons.add,
                          onPressed: () => _abrirFormulario(),
                        ),
                      ],
                    ),
                  ],
                ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          FilterWidget(
            filters: [
              CommonFilters.textSearch(
                key: 'nome',
                label: 'Buscar por nome',
                hintText: 'Buscar por nome...',
                flex: isSmall ? 1 : 2,
              ),
              CommonFilters.statusDropdown(
                key: 'status',
                statusList: _statusFilterList,
                label: 'Filtrar por Status',
                initialValue: 'todos',
              ),
            ],
            onFiltersChanged: _aplicarFiltros,
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Criar tema personalizado para a tabela baseado no tema atual
    final tableTheme = DataTableCustomTheme(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
      headerBackgroundColor: isDark
          ? const Color(0xFF2A2A2A)
          : colorScheme.surfaceContainerHighest,
      borderColor: isDark ? const Color(0xFF424242) : colorScheme.outline,
      hoverColor: isDark
          ? const Color(0xFF2A2A2A)
          : colorScheme.surfaceContainerHigh,
      headerTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        fontSize: 14,
      ),
      dataTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14),
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: ResponsiveUtils.getResponsivePadding(
          context,
          horizontal: 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF00BCD4),
                        strokeWidth: ResponsiveUtils.isSmallScreen(context)
                            ? 2
                            : 3,
                      ),
                    )
                  : DataTableCustom(
                      columns: _tableColumns,
                      data: _prepararDadosTabela(),
                      totalLabel: 'Total: ${_membrosFiltrados.length} membros',
                      leadingIcon: Icon(
                        Icons.view_list,
                        color: const Color(0xFF00BCD4),
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          24,
                        ),
                      ),
                      emptyMessage:
                          'Nenhum membro foi encontrado.\nTente ajustar os filtros ou adicionar novos membros.',
                      theme: tableTheme,
                      // Configurações de paginação
                      enablePagination: true,
                      itemsPerPage: ResponsiveUtils.isSmallScreen(context)
                          ? 8
                          : 10,
                      itemsPerPageOptions:
                          ResponsiveUtils.isSmallScreen(context)
                          ? const [5, 8, 15, 30]
                          : const [5, 10, 20, 50],
                      // Configurações de responsividade
                      enableHorizontalScroll: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

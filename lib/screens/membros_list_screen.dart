import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/widgets/icon_styled.dart';
import '../widgets/modals/membros_form_modal.dart';
import '../widgets/modals/excel_import_modal.dart';
import '../widgets/data_table_custom.dart';

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
  String _filtroStatus = 'todos';
  String _filtroNome = '';

  final List<String> _statusFilterList = [
    'todos',
    'ativo',
    'inativo',
    'pausado',
  ];

  // Definição das colunas para o novo DataTableCustom
  List<DataTableColumn> get _tableColumns => [
    const DataTableColumn(key: 'nome', label: 'Nome', width: 360),
    const DataTableColumn(key: 'email', label: 'E-mail', width: 200),
    const DataTableColumn(key: 'telefone', label: 'Telefone', width: 140),
    DataTableColumn(
      key: 'status',
      label: 'Status',
      width: 110,
      cellBuilder: (value) => _buildStatusChip(value?.toString() ?? 'N/A'),
    ),
    DataTableColumn(
      key: 'acoes',
      label: 'Ações',
      width: 110,
      cellBuilder: (value) {
        // O value aqui será o próprio objeto Membro
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF424242)),
        ),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Deseja realmente excluir o membro ${membro.nome}?',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
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
    Color color;
    Color backgroundColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ativo':
        color = const Color(0xFF4CAF50);
        backgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.15);
        icon = Icons.check_circle;
        break;
      case 'inativo':
        color = const Color(0xFFE53E3E);
        backgroundColor = const Color(0xFFE53E3E).withValues(alpha: 0.15);
        icon = Icons.cancel;
        break;
      case 'pausado':
        color = const Color(0xFFFF9800);
        backgroundColor = const Color(0xFFFF9800).withValues(alpha: 0.15);
        icon = Icons.pause_circle;
        break;
      default:
        color = const Color(0xFF9E9E9E);
        backgroundColor = const Color(0xFF9E9E9E).withValues(alpha: 0.15);
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsButtons(Membro membro) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _abrirFormulario(membro: membro),
            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
            tooltip: 'Editar',
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _confirmarExclusao(membro),
            icon: const Icon(Icons.delete, color: Color(0xFFE53E3E)),
            tooltip: 'Excluir',
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF424242), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconStyled(icone: Icons.people, isLarge: true),
                  const SizedBox(width: 16),
                  const Text(
                    'Gerenciamento de Irmãos',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _abrirImportacaoExcel,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importar Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _abrirFormulario(),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Novo Membro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(
                        0xFF00BCD4,
                      ).withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) {
                    _filtroNome = value;
                    _aplicarFiltros();
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF424242)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF424242)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00BCD4),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroStatus,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Status',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF424242)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF424242)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00BCD4),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                  items: _statusFilterList.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status == 'todos' ? 'Todos' : status.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroStatus = value!);
                    _aplicarFiltros();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF424242)),
                ),
                child: IconButton(
                  onPressed: _carregarMembros,
                  icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
                  tooltip: 'Atualizar',
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BCD4),
                        strokeWidth: 3,
                      ),
                    )
                  : DataTableCustom(
                      columns: _tableColumns,
                      data: _prepararDadosTabela(),
                      totalLabel: 'Total: ${_membrosFiltrados.length} membros',
                      leadingIcon: const Icon(
                        Icons.view_list,
                        color: Color(0xFF00BCD4),
                      ),
                      emptyMessage:
                          'Nenhum membro foi encontrado.\nTente ajustar os filtros ou adicionar novos membros.',
                      // Configurações de paginação
                      enablePagination: true,
                      itemsPerPage: 10,
                      itemsPerPageOptions: const [5, 10, 20, 50],
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

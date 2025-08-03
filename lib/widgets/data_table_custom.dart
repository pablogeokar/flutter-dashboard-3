import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

/// Configuração para uma coluna da tabela
class DataTableColumn {
  final String key;
  final String label;
  final double? width;
  final bool sortable;
  final Widget Function(dynamic value)? cellBuilder;

  const DataTableColumn({
    required this.key,
    required this.label,
    this.width,
    this.sortable = false,
    this.cellBuilder,
  });
}

/// Tema personalizado para a tabela
class DataTableCustomTheme {
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final TextStyle? headerTextStyle;
  final TextStyle? dataTextStyle;
  final List<BoxShadow>? boxShadow;

  const DataTableCustomTheme({
    this.backgroundColor,
    this.headerBackgroundColor,
    this.borderColor,
    this.hoverColor,
    this.headerTextStyle,
    this.dataTextStyle,
    this.boxShadow,
  });

  static const DataTableCustomTheme defaultDark = DataTableCustomTheme(
    backgroundColor: Color(0xFF1A1A1A),
    headerBackgroundColor: Color(0xFF2A2A2A),
    borderColor: Color(0xFF424242),
    hoverColor: Color(0xFF2A2A2A),
    headerTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 14,
    ),
    dataTextStyle: TextStyle(color: Colors.white, fontSize: 14),
  );

  static const DataTableCustomTheme defaultLight = DataTableCustomTheme(
    backgroundColor: Color(0xFFFFFFFF),
    headerBackgroundColor: Color(0xFFF8FAFC),
    borderColor: Color(0xFFE2E8F0),
    hoverColor: Color(0xFFF1F5F9),
    headerTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF1F2937),
      fontSize: 14,
    ),
    dataTextStyle: TextStyle(color: Color(0xFF1F2937), fontSize: 14),
  );
}

/// Widget de tabela personalizada e responsiva
class DataTableCustom extends StatefulWidget {
  final List<DataTableColumn> columns;
  final List<Map<String, dynamic>> data;
  final String? emptyMessage;
  final String? totalLabel;
  final Widget? leadingIcon;
  final DataTableCustomTheme theme;

  // Configurações da tabela
  final double? columnSpacing;
  final double? horizontalMargin;
  final double? headingRowHeight;
  final double? dataRowHeight;

  // Configurações de paginação
  final bool enablePagination;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  // Configurações de responsividade
  final bool enableHorizontalScroll;
  final double? maxWidth;

  const DataTableCustom({
    super.key,
    required this.columns,
    required this.data,
    this.emptyMessage,
    this.totalLabel,
    this.leadingIcon,
    DataTableCustomTheme? theme,
    this.columnSpacing = 16.0,
    this.horizontalMargin = 12.0,
    this.headingRowHeight = 56.0,
    this.dataRowHeight = 60.0,
    this.enablePagination = false,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 20, 50],
    this.enableHorizontalScroll = true,
    this.maxWidth,
  }) : theme = theme ?? DataTableCustomTheme.defaultDark;

  @override
  State<DataTableCustom> createState() => _DataTableCustomState();
}

class _DataTableCustomState extends State<DataTableCustom> {
  int _currentPage = 0;
  late int _itemsPerPage;

  @override
  void initState() {
    super.initState();
    _itemsPerPage = widget.itemsPerPage;
  }

  /// Dados paginados baseados na página atual
  List<Map<String, dynamic>> get _paginatedData {
    if (!widget.enablePagination || widget.data.isEmpty) {
      return widget.data;
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.data.length);
    return widget.data.sublist(startIndex, endIndex);
  }

  /// Total de páginas baseado nos dados
  int get _totalPages {
    if (!widget.enablePagination || widget.data.isEmpty) return 1;
    return (widget.data.length / _itemsPerPage).ceil();
  }

  /// Navega para uma página específica
  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() => _currentPage = page);
    }
  }

  /// Altera a quantidade de itens por página
  void _changeItemsPerPage(int newItemsPerPage) {
    setState(() {
      _itemsPerPage = newItemsPerPage;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = widget.maxWidth ?? MediaQuery.of(context).size.width;

    return Container(
      width: containerWidth,
      decoration: _buildContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (widget.data.isEmpty)
            _buildEmptyState()
          else
            Expanded(child: _buildDataTable()),
          if (widget.enablePagination && widget.data.isNotEmpty)
            _buildPagination(),
        ],
      ),
    );
  }

  /// Decoração do container principal
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: widget.theme.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: widget.theme.borderColor ?? Colors.grey),
      boxShadow:
          widget.theme.boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  /// Cabeçalho da tabela
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.theme.headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (widget.leadingIcon != null) ...[
            widget.leadingIcon!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              widget.totalLabel ?? 'Total: ${widget.data.length} itens',
              style:
                  widget.theme.headerTextStyle?.copyWith(fontSize: 16) ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vazio da tabela
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmptyStateIcon(),
              const SizedBox(height: 24),
              Text(
                'Nenhum dado encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.emptyMessage ??
                    'Não há informações para exibir no momento.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ícone do estado vazio
  Widget _buildEmptyStateIcon() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.theme.headerBackgroundColor,
        border: Border.all(
          color: widget.theme.borderColor ?? Colors.grey,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.table_chart_outlined,
        size: 40,
        color: isDark ? Colors.grey[500] : Colors.grey[600],
      ),
    );
  }

  /// Tabela de dados principal
  Widget _buildDataTable() {
    final dataTable = DataTable(
      columnSpacing: widget.columnSpacing!,
      horizontalMargin: widget.horizontalMargin!,
      headingRowHeight: widget.headingRowHeight!,
      dataRowMinHeight: widget.dataRowHeight!,
      dataRowMaxHeight: widget.dataRowHeight!,
      columns: _buildColumns(),
      rows: _buildRows(),
    );

    if (widget.enableHorizontalScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildThemedDataTable(dataTable),
        ),
      );
    }

    return SingleChildScrollView(child: _buildThemedDataTable(dataTable));
  }

  /// Aplica tema à DataTable
  Widget _buildThemedDataTable(DataTable dataTable) {
    return Theme(
      data: Theme.of(context).copyWith(
        dataTableTheme: DataTableThemeData(
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return widget.theme.hoverColor;
            }
            return widget.theme.backgroundColor;
          }),
          dividerThickness: 0.3,
          headingTextStyle: widget.theme.headerTextStyle,
          dataTextStyle: widget.theme.dataTextStyle,
        ),
      ),
      child: dataTable,
    );
  }

  /// Constrói as colunas da tabela
  List<DataColumn> _buildColumns() {
    return widget.columns.map((column) {
      return DataColumn(
        label: Expanded(
          child: Text(column.label, overflow: TextOverflow.ellipsis),
        ),
      );
    }).toList();
  }

  /// Constrói as linhas da tabela
  List<DataRow> _buildRows() {
    return _paginatedData.map((item) {
      return DataRow(
        cells: widget.columns.map((column) {
          return _buildCell(item, column);
        }).toList(),
      );
    }).toList();
  }

  /// Constrói uma célula individual
  DataCell _buildCell(Map<String, dynamic> item, DataTableColumn column) {
    final value = _extractValue(item, column.key);

    Widget cellContent;

    if (column.cellBuilder != null) {
      cellContent = column.cellBuilder!(value);
    } else if (value is Widget) {
      cellContent = value;
    } else {
      cellContent = Text(
        value?.toString() ?? 'N/A',
        style: widget.theme.dataTextStyle?.copyWith(
          color: value == null ? Colors.grey[500] : null,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return DataCell(SizedBox(width: column.width, child: cellContent));
  }

  /// Extrai o valor do item baseado na chave
  dynamic _extractValue(Map<String, dynamic> item, String key) {
    // Tenta diferentes variações da chave
    final possibleKeys = [
      key,
      key.toLowerCase(),
      key.toLowerCase().replaceAll(' ', '_'),
      key.toLowerCase().replaceAll(' ', '-'),
      key.replaceAll(' ', '_').toLowerCase(),
    ];

    for (final possibleKey in possibleKeys) {
      if (item.containsKey(possibleKey)) {
        return item[possibleKey];
      }
    }

    return null;
  }

  /// Controles de paginação
  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.theme.headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: widget.theme.borderColor ?? Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildCompactPagination();
          }
          return _buildFullPagination();
        },
      ),
    );
  }

  /// Paginação completa para telas maiores
  Widget _buildFullPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildItemsPerPageSelector(), _buildPaginationControls()],
    );
  }

  /// Paginação compacta para telas menores
  Widget _buildCompactPagination() {
    return Column(
      children: [
        _buildItemsPerPageSelector(),
        const SizedBox(height: 16),
        _buildPaginationControls(),
      ],
    );
  }

  /// Seletor de itens por página
  Widget _buildItemsPerPageSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Itens por página:',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: widget.theme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.theme.borderColor ?? Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _itemsPerPage,
              style: widget.theme.dataTextStyle,
              dropdownColor: widget.theme.headerBackgroundColor,
              icon: Icon(
                Icons.expand_more,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
              items: widget.itemsPerPageOptions.map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _changeItemsPerPage(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Controles de navegação da paginação
  Widget _buildPaginationControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaginationButton(
          icon: Icons.first_page,
          tooltip: 'Primeira página',
          onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
        ),
        const SizedBox(width: 4),
        _buildPaginationButton(
          icon: Icons.chevron_left,
          tooltip: 'Página anterior',
          onPressed: _currentPage > 0
              ? () => _goToPage(_currentPage - 1)
              : null,
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            //color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              //color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
              color: AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${_currentPage + 1} de $_totalPages',
            style: const TextStyle(
              //color: AppTheme.primary,
              //fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildPaginationButton(
          icon: Icons.chevron_right,
          tooltip: 'Próxima página',
          onPressed: _currentPage < _totalPages - 1
              ? () => _goToPage(_currentPage + 1)
              : null,
        ),
        const SizedBox(width: 4),
        _buildPaginationButton(
          icon: Icons.last_page,
          tooltip: 'Última página',
          onPressed: _currentPage < _totalPages - 1
              ? () => _goToPage(_totalPages - 1)
              : null,
        ),
      ],
    );
  }

  /// Botão individual da paginação
  Widget _buildPaginationButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled
              ? widget.theme.backgroundColor
              : widget.theme.backgroundColor?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? (widget.theme.borderColor ?? Colors.grey)
                : (widget.theme.borderColor ?? Colors.grey).withValues(
                    alpha: 0.5,
                  ),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700])
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey[400]),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

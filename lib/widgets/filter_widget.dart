import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';
import 'custom_dropdown_form_field.dart';
import 'custom_button.dart';
import '../theme.dart';

/// Enum para definir os tipos de filtros disponíveis
enum FilterType { text, dropdown, dateRange, multiSelect }

/// Classe para configurar um filtro individual
class FilterConfig {
  final String key;
  final String label;
  final FilterType type;
  final IconData? icon;
  final String? hintText;
  final List<String>? dropdownItems;
  final String? initialValue;
  final bool isRequired;
  final int flex;

  const FilterConfig({
    required this.key,
    required this.label,
    required this.type,
    this.icon,
    this.hintText,
    this.dropdownItems,
    this.initialValue,
    this.isRequired = false,
    this.flex = 1,
  });
}

/// Classe para armazenar os valores dos filtros
class FilterValues {
  final Map<String, dynamic> _values = {};

  dynamic operator [](String key) => _values[key];
  void operator []=(String key, dynamic value) => _values[key] = value;

  Map<String, dynamic> get values => Map.unmodifiable(_values);

  bool containsKey(String key) => _values.containsKey(key);

  void clear() => _values.clear();

  void remove(String key) => _values.remove(key);

  @override
  String toString() => _values.toString();
}

/// Widget genérico para filtragem de dados
class FilterWidget extends StatefulWidget {
  /// Lista de configurações dos filtros
  final List<FilterConfig> filters;

  /// Callback chamado quando os filtros são alterados
  final Function(FilterValues filterValues) onFiltersChanged;

  /// Valores iniciais dos filtros
  final FilterValues? initialValues;

  /// Se deve aplicar os filtros automaticamente ao alterar
  final bool autoApply;

  /// Espaçamento entre os filtros
  final double spacing;

  /// Se deve mostrar botão de limpar filtros
  final bool showClearButton;

  /// Se deve mostrar botão de aplicar filtros (quando autoApply = false)
  final bool showApplyButton;

  /// Padding interno do widget
  final EdgeInsets? padding;

  /// Decoração do container
  final BoxDecoration? decoration;

  const FilterWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.initialValues,
    this.autoApply = true,
    this.spacing = 16.0,
    this.showClearButton = true,
    this.showApplyButton = false,
    this.padding,
    this.decoration,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late FilterValues _filterValues;
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  @override
  void dispose() {
    // Dispose de todos os controladores de texto
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeFilters() {
    _filterValues = FilterValues();

    // Inicializar valores dos filtros
    for (final filter in widget.filters) {
      dynamic initialValue;

      // Verificar se há valor inicial fornecido
      if (widget.initialValues?.containsKey(filter.key) == true) {
        initialValue = widget.initialValues![filter.key];
      } else if (filter.initialValue != null) {
        initialValue = filter.initialValue;
      } else {
        // Valores padrão baseados no tipo
        switch (filter.type) {
          case FilterType.text:
            initialValue = '';
            break;
          case FilterType.dropdown:
            initialValue = filter.dropdownItems?.first ?? '';
            break;
          case FilterType.dateRange:
            initialValue = null;
            break;
          case FilterType.multiSelect:
            initialValue = <String>[];
            break;
        }
      }

      _filterValues[filter.key] = initialValue;

      // Criar controladores para campos de texto
      if (filter.type == FilterType.text) {
        final controller = TextEditingController(
          text: initialValue?.toString() ?? '',
        );
        _textControllers[filter.key] = controller;

        // Adicionar listener para auto-aplicar filtros
        if (widget.autoApply) {
          controller.addListener(() {
            _filterValues[filter.key] = controller.text;
            widget.onFiltersChanged(_filterValues);
          });
        }
      }
    }

    // Aplicar filtros iniciais se autoApply estiver ativo
    if (widget.autoApply) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFiltersChanged(_filterValues);
      });
    }
  }

  void _onFilterChanged(String key, dynamic value) {
    setState(() {
      _filterValues[key] = value;
    });

    if (widget.autoApply) {
      widget.onFiltersChanged(_filterValues);
    }
  }

  void _clearFilters() {
    setState(() {
      for (final filter in widget.filters) {
        switch (filter.type) {
          case FilterType.text:
            _filterValues[filter.key] = '';
            _textControllers[filter.key]?.clear();
            break;
          case FilterType.dropdown:
            _filterValues[filter.key] = filter.dropdownItems?.first ?? '';
            break;
          case FilterType.dateRange:
            _filterValues[filter.key] = null;
            break;
          case FilterType.multiSelect:
            _filterValues[filter.key] = <String>[];
            break;
        }
      }
    });

    widget.onFiltersChanged(_filterValues);
  }

  void _applyFilters() {
    // Atualizar valores dos campos de texto que não são auto-aplicados
    for (final filter in widget.filters) {
      if (filter.type == FilterType.text && !widget.autoApply) {
        _filterValues[filter.key] = _textControllers[filter.key]?.text ?? '';
      }
    }

    widget.onFiltersChanged(_filterValues);
  }

  Widget _buildFilterField(FilterConfig filter) {
    switch (filter.type) {
      case FilterType.text:
        return CustomTextFormField(
          controller: _textControllers[filter.key]!,
          label: filter.label,
          hintText:
              filter.hintText ?? 'Digite ${filter.label.toLowerCase()}...',
          prefixIcon: filter.icon ?? Icons.search,
        );

      case FilterType.dropdown:
        return CustomDropdownFormField(
          value:
              _filterValues[filter.key]?.toString() ??
              filter.dropdownItems?.first ??
              '',
          label: filter.label,
          items: filter.dropdownItems ?? [],
          onChanged: (value) => _onFilterChanged(filter.key, value),
          prefixIcon: filter.icon,
        );

      case FilterType.dateRange:
        // TODO: Implementar seletor de data
        return Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text('${filter.label} (Em desenvolvimento)')),
        );

      case FilterType.multiSelect:
        // TODO: Implementar seleção múltipla
        return Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text('${filter.label} (Em desenvolvimento)')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(24.0),
      decoration:
          widget.decoration ??
          BoxDecoration(
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
            borderRadius: BorderRadius.circular(16),
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
          // Campos de filtro
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Construir campos de filtro dinamicamente
              ...widget.filters
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final filter = entry.value;

                    return [
                      Expanded(
                        flex: filter.flex,
                        child: _buildFilterField(filter),
                      ),
                      if (index < widget.filters.length - 1)
                        SizedBox(width: widget.spacing),
                    ];
                  })
                  .expand((widgets) => widgets),
            ],
          ),

          // Botões de ação (se necessário)
          if (widget.showClearButton || widget.showApplyButton) ...[
            SizedBox(height: widget.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.showClearButton)
                  CustomButton(
                    text: 'Limpar',
                    variant: ButtonVariant.outline,
                    icon: Icons.clear,
                    onPressed: _clearFilters,
                  ),
                if (widget.showClearButton && widget.showApplyButton)
                  const SizedBox(width: AppTheme.spacingM),
                if (widget.showApplyButton)
                  CustomButton(
                    text: 'Aplicar',
                    variant: ButtonVariant.primary,
                    icon: Icons.filter_list,
                    onPressed: _applyFilters,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Classe utilitária para criar filtros comuns
class CommonFilters {
  /// Filtro de busca por texto
  static FilterConfig textSearch({
    required String key,
    required String label,
    String? hintText,
    IconData? icon,
    int flex = 2,
  }) {
    return FilterConfig(
      key: key,
      label: label,
      type: FilterType.text,
      hintText: hintText,
      icon: icon ?? Icons.search,
      flex: flex,
    );
  }

  /// Filtro dropdown para status
  static FilterConfig statusDropdown({
    required String key,
    required List<String> statusList,
    String label = 'Status',
    String? initialValue,
    IconData? icon,
    int flex = 1,
  }) {
    return FilterConfig(
      key: key,
      label: label,
      type: FilterType.dropdown,
      dropdownItems: statusList,
      initialValue: initialValue ?? statusList.first,
      icon: icon ?? Icons.filter_list,
      flex: flex,
    );
  }

  /// Filtro dropdown genérico
  static FilterConfig dropdown({
    required String key,
    required String label,
    required List<String> items,
    String? initialValue,
    IconData? icon,
    int flex = 1,
  }) {
    return FilterConfig(
      key: key,
      label: label,
      type: FilterType.dropdown,
      dropdownItems: items,
      initialValue: initialValue ?? items.first,
      icon: icon,
      flex: flex,
    );
  }
}

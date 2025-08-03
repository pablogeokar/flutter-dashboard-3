# FilterWidget - Widget de Filtragem Genérico

O `FilterWidget` é um widget reutilizável criado para padronizar a filtragem de dados em todas as telas da aplicação. Ele oferece uma interface consistente e flexível para implementar diferentes tipos de filtros.

## Características Principais

- **Genérico e Reutilizável**: Pode ser usado em qualquer tela que precise de filtragem
- **Múltiplos Tipos de Filtro**: Suporte para texto, dropdown, data e seleção múltipla
- **Auto-aplicação**: Opção de aplicar filtros automaticamente ou manualmente
- **Customizável**: Aparência e comportamento configuráveis
- **Responsivo**: Adapta-se a diferentes tamanhos de tela

## Tipos de Filtros Suportados

### 1. Filtro de Texto (`FilterType.text`)

Para busca por texto livre, como nomes, descrições, etc.

### 2. Filtro Dropdown (`FilterType.dropdown`)

Para seleção de valores predefinidos, como status, categorias, etc.

### 3. Filtro de Data (`FilterType.dateRange`)

Para seleção de períodos de data (em desenvolvimento).

### 4. Filtro de Seleção Múltipla (`FilterType.multiSelect`)

Para seleção de múltiplos valores (em desenvolvimento).

## Como Usar

### Exemplo Básico

```dart
FilterWidget(
  filters: [
    CommonFilters.textSearch(
      key: 'nome',
      label: 'Buscar por nome',
      hintText: 'Digite o nome...',
    ),
    CommonFilters.statusDropdown(
      key: 'status',
      statusList: ['todos', 'ativo', 'inativo'],
      label: 'Status',
    ),
  ],
  onFiltersChanged: (filterValues) {
    // Aplicar filtros aos dados
    _aplicarFiltros(filterValues);
  },
)
```

### Exemplo Avançado

```dart
FilterWidget(
  filters: [
    FilterConfig(
      key: 'busca',
      label: 'Buscar',
      type: FilterType.text,
      icon: Icons.search,
      hintText: 'Digite sua busca...',
      flex: 2, // Ocupa mais espaço
    ),
    FilterConfig(
      key: 'categoria',
      label: 'Categoria',
      type: FilterType.dropdown,
      dropdownItems: ['Todas', 'Categoria A', 'Categoria B'],
      initialValue: 'Todas',
      icon: Icons.category,
    ),
  ],
  onFiltersChanged: _handleFilters,
  autoApply: true, // Aplica automaticamente
  showClearButton: true, // Mostra botão limpar
  spacing: 20.0, // Espaçamento entre filtros
)
```

## Parâmetros do FilterWidget

### Obrigatórios

- `filters`: Lista de configurações dos filtros
- `onFiltersChanged`: Callback chamado quando filtros mudam

### Opcionais

- `initialValues`: Valores iniciais dos filtros
- `autoApply`: Se deve aplicar automaticamente (padrão: true)
- `spacing`: Espaçamento entre filtros (padrão: 16.0)
- `showClearButton`: Se deve mostrar botão limpar (padrão: true)
- `showApplyButton`: Se deve mostrar botão aplicar (padrão: false)
- `padding`: Padding interno do widget
- `decoration`: Decoração personalizada do container

## Classe FilterConfig

Define a configuração de um filtro individual:

```dart
FilterConfig(
  key: 'identificador_unico',        // Chave única do filtro
  label: 'Rótulo do Campo',          // Texto do label
  type: FilterType.text,             // Tipo do filtro
  icon: Icons.search,                // Ícone (opcional)
  hintText: 'Texto de ajuda...',     // Placeholder (opcional)
  dropdownItems: ['Item1', 'Item2'], // Itens do dropdown (se aplicável)
  initialValue: 'valor_inicial',     // Valor inicial (opcional)
  isRequired: false,                 // Se é obrigatório (opcional)
  flex: 1,                          // Proporção do espaço ocupado
)
```

## Classe FilterValues

Armazena os valores dos filtros de forma tipada:

```dart
void _aplicarFiltros(FilterValues filterValues) {
  final nome = filterValues['nome'] ?? '';
  final status = filterValues['status'] ?? 'todos';

  // Aplicar filtros aos dados
  final dadosFiltrados = dados.where((item) {
    final matchNome = nome.isEmpty ||
        item.nome.toLowerCase().contains(nome.toLowerCase());
    final matchStatus = status == 'todos' || item.status == status;
    return matchNome && matchStatus;
  }).toList();

  setState(() {
    this.dadosFiltrados = dadosFiltrados;
  });
}
```

## Classe CommonFilters

Fornece métodos utilitários para criar filtros comuns:

### textSearch()

```dart
CommonFilters.textSearch(
  key: 'busca',
  label: 'Buscar',
  hintText: 'Digite sua busca...',
  icon: Icons.search,
  flex: 2,
)
```

### statusDropdown()

```dart
CommonFilters.statusDropdown(
  key: 'status',
  statusList: ['todos', 'ativo', 'inativo', 'pausado'],
  label: 'Status',
  initialValue: 'todos',
)
```

### dropdown()

```dart
CommonFilters.dropdown(
  key: 'categoria',
  label: 'Categoria',
  items: ['Todas', 'Categoria A', 'Categoria B'],
  initialValue: 'Todas',
  icon: Icons.category,
)
```

## Exemplos de Implementação

### Tela de Membros

```dart
FilterWidget(
  filters: [
    CommonFilters.textSearch(
      key: 'nome',
      label: 'Buscar por nome',
      flex: 2,
    ),
    CommonFilters.statusDropdown(
      key: 'status',
      statusList: ['todos', 'ativo', 'inativo', 'pausado'],
      label: 'Status',
    ),
  ],
  onFiltersChanged: (filterValues) {
    setState(() {
      membrosFiltrados = membros.where((membro) {
        final nome = filterValues['nome'] ?? '';
        final status = filterValues['status'] ?? 'todos';

        final matchNome = nome.isEmpty ||
            membro.nome.toLowerCase().contains(nome.toLowerCase());
        final matchStatus = status == 'todos' || membro.status == status;

        return matchNome && matchStatus;
      }).toList();
    });
  },
)
```

### Tela de Contribuições

```dart
FilterWidget(
  filters: [
    CommonFilters.textSearch(
      key: 'membro',
      label: 'Buscar por membro',
      hintText: 'Digite o nome do membro...',
    ),
  ],
  onFiltersChanged: (filterValues) {
    setState(() {
      final filtroMembro = filterValues['membro'] ?? '';
      contribuicoesFiltradas = contribuicoes.where((contribuicao) {
        return filtroMembro.isEmpty ||
            (contribuicao.membroNome ?? '').toLowerCase()
                .contains(filtroMembro.toLowerCase());
      }).toList();
    });
  },
)
```

## Vantagens do FilterWidget

1. **Consistência**: Interface padronizada em toda a aplicação
2. **Reutilização**: Mesmo código para diferentes telas
3. **Manutenibilidade**: Mudanças centralizadas no widget
4. **Flexibilidade**: Configurável para diferentes necessidades
5. **Performance**: Auto-aplicação otimizada de filtros
6. **UX**: Interface intuitiva e responsiva

## Futuras Melhorias

- Implementação completa de filtros de data
- Suporte a filtros de seleção múltipla
- Persistência de filtros entre sessões
- Filtros avançados com operadores (contém, igual, maior que, etc.)
- Suporte a filtros customizados definidos pelo usuário

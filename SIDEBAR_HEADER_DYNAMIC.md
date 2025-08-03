# Header da Sidebar Dinâmico

## Visão Geral

O `SidebarHeader` agora carrega dinamicamente o nome da loja e CNPJ do banco de dados, permitindo que essas informações sejam atualizadas automaticamente quando as configurações forem alteradas.

## Funcionalidades Implementadas

### 1. Carregamento Dinâmico

- **Nome da Loja**: Carregado de `getValorConfiguracao('nome_loja')`
- **CNPJ**: Carregado de `getValorConfiguracao('cnpj')`
- **Fallback**: Valores padrão caso não existam no banco

### 2. Estado Responsivo

- **Loading State**: Mostra um indicador de carregamento enquanto busca os dados
- **Error Handling**: Tratamento de erros com valores padrão
- **Responsividade**: Todos os elementos se adaptam ao tamanho da tela

### 3. Atualização Automática

- **GlobalKey**: Permite atualizar o header de qualquer lugar da aplicação
- **Método Público**: `atualizarInformacoes()` para forçar atualização
- **Integração**: Atualização automática ao salvar configurações

## Como Funciona

### 1. Carregamento Inicial

```dart
@override
void initState() {
  super.initState();
  _carregarInformacoesLoja();
}
```

### 2. Busca no Banco de Dados

```dart
Future<void> _carregarInformacoesLoja() async {
  try {
    final db = DatabaseService();

    final nomeLoja = await db.getValorConfiguracao('nome_loja');
    final cnpj = await db.getValorConfiguracao('cnpj');

    if (mounted) {
      setState(() {
        _nomeLoja = nomeLoja ?? 'Harmonia, Luz e Sigilo nº 46';
        _cnpj = 'CNPJ: ${cnpj ?? '12.345.678/0001-90'}';
        _isLoading = false;
      });
    }
  } catch (e) {
    // Tratamento de erro
  }
}
```

### 3. Atualização Manual

```dart
// Em qualquer lugar da aplicação
final sidebarHeaderState = sidebarHeaderKey.currentState;
if (sidebarHeaderState != null) {
  sidebarHeaderState.atualizarInformacoes();
}
```

## Integração com Configurações

### 1. Atualização Automática

Quando as configurações são salvas na tela de configurações, o header é atualizado automaticamente:

```dart
Future<void> _salvarConfiguracoes() async {
  // ... salvar configurações ...

  // Atualizar o header da sidebar
  _atualizarSidebarHeader();
}

void _atualizarSidebarHeader() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final sidebarHeaderState = sidebarHeaderKey.currentState;
    if (sidebarHeaderState != null) {
      sidebarHeaderState.atualizarInformacoes();
    }
  });
}
```

## Responsividade

### 1. Espaçamentos Adaptativos

- Padding e margens responsivos
- Altura das imagens adaptativa
- Border radius proporcional

### 2. Tipografia Responsiva

- Tamanhos de fonte que se ajustam
- Estilos consistentes com o tema

### 3. Estados Visuais

- **Loading**: Indicador de carregamento responsivo
- **Loaded**: Informações com tipografia responsiva
- **Error**: Fallback com valores padrão

## Benefícios

1. **Dinâmico**: Informações sempre atualizadas
2. **Responsivo**: Adapta-se a diferentes tamanhos de tela
3. **Consistente**: Mantém a identidade visual
4. **Robusto**: Tratamento de erros e fallbacks
5. **Integrado**: Atualização automática com configurações

## Estrutura de Arquivos

```
lib/widgets/layout/sidebar/
├── sidebar_header.dart          # Header dinâmico
├── sidebar.dart                 # Usa GlobalKey
└── ...

lib/screens/
├── configuracoes_screen.dart    # Atualiza header
└── ...

lib/utils/
└── responsive_utils.dart        # Responsividade
```

## Testes Recomendados

1. **Carregamento Inicial**: Verificar se as informações aparecem corretamente
2. **Atualização**: Alterar configurações e verificar se o header atualiza
3. **Responsividade**: Testar em diferentes tamanhos de tela
4. **Erros**: Simular falhas no banco de dados
5. **Performance**: Verificar se não há vazamentos de memória

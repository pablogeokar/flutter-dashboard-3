# Documentação da Splash Screen

## Visão Geral

A splash screen foi implementada para fornecer uma experiência de carregamento suave e profissional enquanto o sistema inicializa todos os componentes necessários.

## Arquivos Criados/Modificados

### 1. `lib/screens/splash_screen.dart`

- **Função**: Tela de splash com animações e barra de progresso
- **Características**:
  - Logo animado com fade-in e scale
  - Barra de progresso com gradiente
  - Texto de status dinâmico
  - Transição suave para a tela principal
  - Suporte a tema claro e escuro

### 2. `lib/services/initialization_service.dart`

- **Função**: Serviço responsável pela inicialização do sistema
- **Etapas de Inicialização**:
  1. **Banco de Dados** (10%): Inicializa o SQLite e verifica conectividade
  2. **Configurações** (30%): Carrega configurações do sistema e cria padrões se necessário
  3. **Dados Essenciais** (50%): Verifica integridade dos dados de membros e contribuições
  4. **Serviços** (70%): Inicializa serviços auxiliares como LogoManager
  5. **Interface** (90%): Prepara elementos da UI
  6. **Finalização** (100%): Sistema pronto para uso

### 3. `lib/main.dart`

- **Modificação**: Alterado para usar `SplashScreen` como tela inicial ao invés de `MainLayout`

## Funcionalidades da Splash Screen

### Animações

- **Logo**: Animação de escala e opacidade (1.5s)
- **Progresso**: Animação suave da barra de progresso
- **Transição**: Fade transition para a tela principal (800ms)

### Estados de Carregamento

1. "Inicializando sistema..." (0-10%)
2. "Inicializando banco de dados..." (10-30%)
3. "Carregando configurações..." (30-50%)
4. "Verificando dados do sistema..." (50-70%)
5. "Inicializando serviços..." (70-90%)
6. "Preparando interface..." (90-100%)
7. "Sistema pronto!" (100%)

### Tratamento de Erros

- Captura erros durante a inicialização
- Exibe mensagem de erro na tela
- Permite retry ou diagnóstico

## Design Responsivo

### Tema Claro

- Fundo: Gradiente de branco para cinza claro
- Texto: Preto/cinza escuro
- Barra de progresso: Gradiente verde-azul

### Tema Escuro

- Fundo: Gradiente de preto para cinza escuro
- Texto: Branco/cinza claro
- Barra de progresso: Gradiente verde-azul

## Configurações Padrão Criadas

O sistema cria automaticamente as seguintes configurações se não existirem:

- `valor_contribuicao_mensal`: R$ 50,00
- `nome_organizacao`: "Minha Organização"
- `endereco_organizacao`: (vazio)
- `telefone_organizacao`: (vazio)
- `email_organizacao`: (vazio)
- `cnpj_organizacao`: (vazio)

## Tempo de Carregamento

- **Mínimo**: ~2.5 segundos (com delays para UX)
- **Máximo**: Depende da complexidade dos dados
- **Otimizado**: Operações paralelas onde possível

## Benefícios

1. **Experiência do Usuário**: Carregamento visual e informativo
2. **Inicialização Robusta**: Verificação completa do sistema
3. **Tratamento de Erros**: Captura problemas na inicialização
4. **Performance**: Pré-carregamento de recursos essenciais
5. **Profissionalismo**: Interface polida e moderna

## Personalização

### Logo

- Localização: `assets/images/logo-loja.png`
- Fallback: Ícone de negócio padrão
- Tamanho: 120x120px com bordas arredondadas

### Cores

- Personalizáveis através do `AppTheme`
- Suporte automático a tema claro/escuro
- Gradientes configuráveis

### Textos

- Facilmente modificáveis no `InitializationService`
- Suporte a internacionalização (preparado)
- Mensagens de erro personalizáveis

## Manutenção

### Adicionar Nova Etapa de Inicialização

1. Criar método no `InitializationService`
2. Adicionar chamada no método `initialize()`
3. Definir porcentagem e mensagem apropriadas

### Modificar Animações

1. Ajustar duração nos `AnimationController`
2. Modificar curvas de animação
3. Personalizar transições

### Alterar Design

1. Modificar gradientes e cores
2. Ajustar tamanhos e espaçamentos
3. Personalizar tipografia

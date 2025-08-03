import 'package:flutter_dashboard_3/services/database_service.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';
import 'package:flutter_dashboard_3/services/logo_manager.dart';

class InitializationService {
  static final InitializationService _instance =
      InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  Future<void> initialize({
    required Function(double progress, String message) onProgress,
  }) async {
    try {
      // Etapa 1: Inicializar banco de dados
      onProgress(0.1, 'Inicializando banco de dados...');
      await _initializeDatabase();
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 2: Carregar configurações
      onProgress(0.3, 'Carregando configurações...');
      await _loadConfigurations();
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 3: Verificar dados essenciais
      onProgress(0.5, 'Verificando dados do sistema...');
      await _checkEssentialData();
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 4: Inicializar serviços
      onProgress(0.7, 'Inicializando serviços...');
      await _initializeServices();
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 5: Preparar interface
      onProgress(0.9, 'Preparando interface...');
      await _prepareUI();
      await Future.delayed(const Duration(milliseconds: 500));

      // Finalização
      onProgress(1.0, 'Sistema pronto!');
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      onProgress(0.0, 'Erro na inicialização: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final databaseHelper = DatabaseHelper();
      await databaseHelper.database;
    } catch (e) {
      throw Exception('Falha ao inicializar banco de dados: $e');
    }
  }

  Future<void> _loadConfigurations() async {
    try {
      final databaseService = DatabaseService();

      // Verificar se existem configurações básicas
      final configuracoes = await databaseService.getConfiguracoes();

      // Se não existir configurações, criar as padrões
      if (configuracoes.isEmpty) {
        await _createDefaultConfigurations();
      }

      // Carregar valor da contribuição mensal
      await databaseService.getValorContribuicaoMensal();
    } catch (e) {
      throw Exception('Falha ao carregar configurações: $e');
    }
  }

  Future<void> _createDefaultConfigurations() async {
    try {
      final databaseService = DatabaseService();

      // Configurações padrão do sistema
      final defaultConfigs = [
        {
          'chave': 'valor_contribuicao_mensal',
          'valor': '100.00',
          'descricao': 'Valor padrão da contribuição mensal',
        },
        {
          'chave': 'nome_organizacao',
          'valor': 'Minha Organização',
          'descricao': 'Nome da organização',
        },
        {
          'chave': 'endereco_organizacao',
          'valor': '',
          'descricao': 'Endereço da organização',
        },
        {
          'chave': 'telefone_organizacao',
          'valor': '',
          'descricao': 'Telefone da organização',
        },
        {
          'chave': 'email_organizacao',
          'valor': '',
          'descricao': 'Email da organização',
        },
        {
          'chave': 'cnpj_organizacao',
          'valor': '',
          'descricao': 'CNPJ da organização',
        },
      ];

      for (final config in defaultConfigs) {
        await databaseService.updateConfiguracao(
          config['chave']!,
          config['valor']!,
          descricao: config['descricao'],
        );
      }
    } catch (e) {
      throw Exception('Falha ao criar configurações padrão: $e');
    }
  }

  Future<void> _checkEssentialData() async {
    try {
      final databaseService = DatabaseService();

      // Verificar se existem membros
      final totalMembros = await databaseService.contarMembros();

      // Verificar estatísticas de contribuições
      final estatisticas = await databaseService.getEstatisticasContribuicoes();

      // Log das informações (opcional)
      print('Total de membros: $totalMembros');
      print('Estatísticas de contribuições carregadas');
    } catch (e) {
      throw Exception('Falha ao verificar dados essenciais: $e');
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Inicializar gerenciador de logos
      final logoManager = LogoManager();
      // O LogoManager já está pronto para uso, não precisa de inicialização especial

      // Outros serviços podem ser inicializados aqui
      // Por exemplo: serviços de notificação, cache, etc.
    } catch (e) {
      throw Exception('Falha ao inicializar serviços: $e');
    }
  }

  Future<void> _prepareUI() async {
    try {
      // Preparar elementos da interface
      // Por exemplo: pré-carregar imagens, fontes, etc.

      // Simular preparação da UI
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      throw Exception('Falha ao preparar interface: $e');
    }
  }

  // Método para verificar se o sistema está pronto
  Future<bool> isSystemReady() async {
    try {
      final databaseService = DatabaseService();

      // Verificar se o banco está acessível
      await databaseService.getConfiguracoes();

      // Verificar se as configurações essenciais existem
      final valorContribuicao = await databaseService
          .getValorContribuicaoMensal();

      return valorContribuicao > 0;
    } catch (e) {
      return false;
    }
  }

  // Método para obter informações do sistema
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final databaseService = DatabaseService();

      final totalMembros = await databaseService.contarMembros();
      final membrosPorStatus = await databaseService.contarMembrosPorStatus();
      final estatisticasContribuicoes = await databaseService
          .getEstatisticasContribuicoes();

      return {
        'totalMembros': totalMembros,
        'membrosPorStatus': membrosPorStatus,
        'estatisticasContribuicoes': estatisticasContribuicoes,
        'sistemaInicializado': true,
        'dataInicializacao': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'erro': e.toString(), 'sistemaInicializado': false};
    }
  }
}

// database/repositories/configuracao_repository.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dashboard_3/models/configuracao.dart';
import '../database_helper.dart';

class ConfiguracaoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Configuracao configuracao) async {
    final db = await _databaseHelper.database;
    return await db.insert('configuracoes', configuracao.toMap());
  }

  Future<List<Configuracao>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'configuracoes',
      orderBy: 'chave ASC',
    );

    return List.generate(maps.length, (i) => Configuracao.fromMap(maps[i]));
  }

  Future<Configuracao?> getByChave(String chave) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );

    if (maps.isNotEmpty) {
      return Configuracao.fromMap(maps.first);
    }
    return null;
  }

  Future<String?> getValor(String chave) async {
    final configuracao = await getByChave(chave);
    return configuracao?.valor;
  }

  Future<double> getValorContribuicaoMensal() async {
    final valor = await getValor('valor_contribuicao_mensal');
    return double.tryParse(valor ?? '100.00') ?? 100.00;
  }

  /// Atualiza uma configuração existente ou cria uma nova se não existir (upsert)
  Future<int> updateByChave(
    String chave,
    String novoValor, {
    String? descricao,
  }) async {
    final db = await _databaseHelper.database;

    // Verificar se a configuração já existe
    final configuracaoExistente = await getByChave(chave);

    final dadosAtualizacao = {
      'chave': chave,
      'valor': novoValor,
      'descricao': descricao ?? configuracaoExistente?.descricao,
      'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
    };

    if (configuracaoExistente != null) {
      // Atualizar configuração existente
      return await db.update(
        'configuracoes',
        dadosAtualizacao,
        where: 'chave = ?',
        whereArgs: [chave],
      );
    } else {
      // Criar nova configuração (remover data_criacao se não existe na tabela)
      return await db.insert('configuracoes', dadosAtualizacao);
    }
  }

  Future<int> deleteByChave(String chave) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );
  }

  /// Método para inicializar configurações padrão se não existirem
  Future<void> inicializarConfiguracoesDefault() async {
    try {
      // Verificar e criar configurações padrão
      final configuracoesDefault = {
        'valor_contribuicao_mensal': '100.00',
        'nome_loja': 'Loja Maçônica',
        'cnpj': '01.234.567/0001-89',
      };

      for (final entrada in configuracoesDefault.entries) {
        final configuracaoExistente = await getByChave(entrada.key);
        if (configuracaoExistente == null) {
          // Usar dados simples compatíveis com a estrutura da tabela
          final db = await _databaseHelper.database;
          await db.insert('configuracoes', {
            'chave': entrada.key,
            'valor': entrada.value,
            'descricao': _getDescricaoDefault(entrada.key),
            'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar configurações padrão: $e');
      }
    }
  }

  String _getDescricaoDefault(String chave) {
    switch (chave) {
      case 'valor_contribuicao_mensal':
        return 'Valor da contribuição mensal dos membros da loja';
      case 'nome_loja':
        return 'Nome da loja maçônica';
      case 'cnpj':
        return 'CNPJ da loja';
      case 'logo_path':
        return 'Caminho do logo da loja';
      default:
        return 'Configuração do sistema';
    }
  }
}

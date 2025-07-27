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

  Future<int> updateByChave(
    String chave,
    String novoValor, {
    String? descricao,
  }) async {
    final db = await _databaseHelper.database;

    final dadosAtualizacao = {
      'chave': chave,
      'valor': novoValor,
      'descricao': descricao,
      'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
    };

    return await db.update(
      'configuracoes',
      dadosAtualizacao,
      where: 'chave = ?',
      whereArgs: [chave],
    );
  }

  Future<int> deleteByChave(String chave) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
    );
  }
}

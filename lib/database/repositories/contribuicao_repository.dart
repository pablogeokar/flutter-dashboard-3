import 'package:flutter_dashboard_3/models/contribuicao.dart';
import '../database_helper.dart';

class ContribuicaoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Contribuicao contribuicao) async {
    final db = await _databaseHelper.database;
    return await db.insert('contribuicoes', contribuicao.toMap());
  }

  Future<List<Contribuicao>> get({
    int? membroId,
    int? mesReferencia,
    int? anoReferencia,
    String? status,
  }) async {
    final db = await _databaseHelper.database;

    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (membroId != null) {
      where += ' AND c.membro_id = ?';
      whereArgs.add(membroId);
    }

    if (mesReferencia != null) {
      where += ' AND c.mes_referencia = ?';
      whereArgs.add(mesReferencia);
    }

    if (anoReferencia != null) {
      where += ' AND c.ano_referencia = ?';
      whereArgs.add(anoReferencia);
    }

    if (status != null) {
      where += ' AND c.status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.*,
        m.nome as membro_nome,
        m.status as membro_status
      FROM contribuicoes c
      INNER JOIN membros m ON c.membro_id = m.id
      WHERE $where
      ORDER BY c.ano_referencia DESC, c.mes_referencia DESC, m.nome ASC
    ''', whereArgs);

    return List.generate(maps.length, (i) => Contribuicao.fromMap(maps[i]));
  }

  Future<Contribuicao?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        c.*,
        m.nome as membro_nome,
        m.status as membro_status
      FROM contribuicoes c
      INNER JOIN membros m ON c.membro_id = m.id
      WHERE c.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Contribuicao.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Contribuicao contribuicao) async {
    final db = await _databaseHelper.database;

    if (contribuicao.id == null) {
      throw Exception('ID da contribuição não pode ser nulo para atualização');
    }

    return await db.update(
      'contribuicoes',
      contribuicao.toMap(),
      where: 'id = ?',
      whereArgs: [contribuicao.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('contribuicoes', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> existsForPeriod(int mes, int ano) async {
    final contribuicoes = await get(mesReferencia: mes, anoReferencia: ano);
    return contribuicoes.isNotEmpty;
  }

  Future<Map<String, dynamic>> getEstatisticas({
    int? mesReferencia,
    int? anoReferencia,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (mesReferencia != null) {
      whereClause += ' AND mes_referencia = ?';
      whereArgs.add(mesReferencia);
    }

    if (anoReferencia != null) {
      whereClause += ' AND ano_referencia = ?';
      whereArgs.add(anoReferencia);
    }

    final result = await db.rawQuery('''
      SELECT 
        status,
        COUNT(*) as quantidade,
        SUM(valor) as valor_total
      FROM contribuicoes 
      WHERE $whereClause
      GROUP BY status
    ''', whereArgs);

    Map<String, Map<String, dynamic>> estatisticas = {};
    double valorTotal = 0;
    int quantidadeTotal = 0;

    for (var row in result) {
      final status = row['status'] as String;
      final quantidade = row['quantidade'] as int;
      final valor = (row['valor_total'] as num?)?.toDouble() ?? 0;

      estatisticas[status] = {'quantidade': quantidade, 'valor_total': valor};

      quantidadeTotal += quantidade;
      valorTotal += valor;
    }

    return {
      'por_status': estatisticas,
      'total_geral': {'quantidade': quantidadeTotal, 'valor_total': valorTotal},
    };
  }
}

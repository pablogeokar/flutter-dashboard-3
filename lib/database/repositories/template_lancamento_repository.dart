// repositories/template_lancamento_repository.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:flutter_dashboard_3/models/template_lancamento.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TemplateLancamentoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _db async => await _databaseHelper.database;

  Future<List<TemplateLancamento>> findAll({bool somenteAtivos = true}) async {
    final query =
        '''
      SELECT t.*, 
             cd.codigo as codigo_debito, cd.nome as nome_debito, cd.tipo as tipo_debito,
             cc.codigo as codigo_credito, cc.nome as nome_credito, cc.tipo as tipo_credito
      FROM templates_lancamento t
      LEFT JOIN contas_contabeis cd ON t.conta_debito_id = cd.id
      LEFT JOIN contas_contabeis cc ON t.conta_credito_id = cc.id
      ${somenteAtivos ? 'WHERE t.ativo = 1' : ''}
      ORDER BY t.nome
    ''';

    final db = await _db;
    final maps = await db.rawQuery(query);
    return maps.map((map) => _templateFromMapWithContas(map)).toList();
  }

  Future<TemplateLancamento?> findById(int id) async {
    const query = '''
      SELECT t.*, 
             cd.codigo as codigo_debito, cd.nome as nome_debito, cd.tipo as tipo_debito,
             cc.codigo as codigo_credito, cc.nome as nome_credito, cc.tipo as tipo_credito
      FROM templates_lancamento t
      LEFT JOIN contas_contabeis cd ON t.conta_debito_id = cd.id
      LEFT JOIN contas_contabeis cc ON t.conta_credito_id = cc.id
      WHERE t.id = ?
    ''';

    final db = await _db;
    final maps = await db.rawQuery(query, [id]);
    if (maps.isNotEmpty) {
      return _templateFromMapWithContas(maps.first);
    }
    return null;
  }

  Future<int> insert(TemplateLancamento template) async {
    final db = await _db;
    return await db.insert('templates_lancamento', template.toMap());
  }

  Future<int> update(TemplateLancamento template) async {
    final db = await _db;
    return await db.update(
      'templates_lancamento',
      template.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'templates_lancamento',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  TemplateLancamento _templateFromMapWithContas(Map<String, dynamic> map) {
    ContaContabil? contaDebito;
    ContaContabil? contaCredito;

    if (map['codigo_debito'] != null) {
      contaDebito = ContaContabil(
        id: map['conta_debito_id'],
        codigo: map['codigo_debito'],
        nome: map['nome_debito'],
        tipo: TipoConta.fromString(map['tipo_debito']),
        nivel: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    if (map['codigo_credito'] != null) {
      contaCredito = ContaContabil(
        id: map['conta_credito_id'],
        codigo: map['codigo_credito'],
        nome: map['nome_credito'],
        tipo: TipoConta.fromString(map['tipo_credito']),
        nivel: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return TemplateLancamento.fromMap(
      map,
      contaDebito: contaDebito,
      contaCredito: contaCredito,
    );
  }
}

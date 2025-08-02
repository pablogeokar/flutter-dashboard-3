// repositories/conta_contabil_repository.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ContaContabilRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _db async => await _databaseHelper.database;

  Future<List<ContaContabil>> findAll({bool somenteAtivas = true}) async {
    final db = await _db;
    final query =
        '''
      SELECT * FROM contas_contabeis
      ${somenteAtivas ? 'WHERE ativa = 1' : ''}
      ORDER BY codigo
    ''';

    final maps = await db.rawQuery(query);
    return maps.map((map) => ContaContabil.fromMap(map)).toList();
  }

  Future<List<ContaContabil>> findByTipo(
    TipoConta tipo, {
    bool somenteAtivas = true,
  }) async {
    final db = await _db;
    final query =
        '''
      SELECT * FROM contas_contabeis
      WHERE tipo = ? ${somenteAtivas ? 'AND ativa = 1' : ''}
      ORDER BY codigo
    ''';

    final maps = await db.rawQuery(query, [tipo.value]);
    return maps.map((map) => ContaContabil.fromMap(map)).toList();
  }

  Future<List<ContaContabil>> findAnaliticas({
    bool somenteAtivas = true,
  }) async {
    final db = await _db;
    final query =
        '''
      SELECT * FROM contas_contabeis
      WHERE nivel >= 3 ${somenteAtivas ? 'AND ativa = 1' : ''}
      ORDER BY codigo
    ''';

    final maps = await db.rawQuery(query);
    return maps.map((map) => ContaContabil.fromMap(map)).toList();
  }

  Future<ContaContabil?> findById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'contas_contabeis',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ContaContabil.fromMap(maps.first);
    }
    return null;
  }

  Future<ContaContabil?> findByCodigo(String codigo) async {
    final db = await _db;
    final maps = await db.query(
      'contas_contabeis',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );

    if (maps.isNotEmpty) {
      return ContaContabil.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(ContaContabil conta) async {
    final db = await _db;
    return await db.insert('contas_contabeis', conta.toMap());
  }

  Future<int> update(ContaContabil conta) async {
    final db = await _db;
    return await db.update(
      'contas_contabeis',
      conta.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [conta.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'contas_contabeis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> possuiLancamentos(int contaId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM partidas_contabeis WHERE conta_id = ?',
      [contaId],
    );
    return (result.first['count'] as int) > 0;
  }
}

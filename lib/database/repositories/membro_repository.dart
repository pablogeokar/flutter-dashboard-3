import 'package:flutter_dashboard_3/models/membro.dart';
import '../database_helper.dart';

class MembroRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Membro membro) async {
    final db = await _databaseHelper.database;
    return await db.insert('membros', membro.toMap());
  }

  Future<List<Membro>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) => Membro.fromMap(maps[i]));
  }

  Future<Membro?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Membro.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Membro>> getByStatus(String status) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) => Membro.fromMap(maps[i]));
  }

  Future<List<Membro>> getByNome(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) => Membro.fromMap(maps[i]));
  }

  Future<int> update(Membro membro) async {
    final db = await _databaseHelper.database;

    if (membro.id == null) {
      throw Exception('ID do membro não pode ser nulo para atualização');
    }

    return await db.update(
      'membros',
      membro.toMap(),
      where: 'id = ?',
      whereArgs: [membro.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('membros', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _databaseHelper.database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM membros');
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, int>> countByStatus() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM membros 
      GROUP BY status
    ''');

    Map<String, int> contador = {};
    for (var row in result) {
      contador[row['status']] = row['count'];
    }
    return contador;
  }

  Future<bool> existsEmail(String email, {int? excludeId}) async {
    final db = await _databaseHelper.database;

    String where = 'email = ?';
    List<dynamic> whereArgs = [email];

    if (excludeId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }
}

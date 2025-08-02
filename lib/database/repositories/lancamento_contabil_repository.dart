// repositories/lancamento_contabil_repository.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:flutter_dashboard_3/models/lancamento_contabil.dart';
import 'package:flutter_dashboard_3/models/partida_contabil.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LancamentoContabilRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _db async => await _databaseHelper.database;

  Future<List<LancamentoContabil>> findAll({
    DateTime? dataInicio,
    DateTime? dataFim,
    int? limit,
    int? offset,
  }) async {
    String query = '''
      SELECT l.*, 
             pd.id as partida_debito_id, pd.conta_id as conta_debito_id, pd.valor as valor_debito,
             pc.id as partida_credito_id, pc.conta_id as conta_credito_id, pc.valor as valor_credito,
             cd.codigo as codigo_debito, cd.nome as nome_debito,
             cc.codigo as codigo_credito, cc.nome as nome_credito
      FROM lancamentos_contabeis l
      LEFT JOIN partidas_contabeis pd ON l.id = pd.lancamento_id AND pd.tipo_movimento = 'DEBITO'
      LEFT JOIN partidas_contabeis pc ON l.id = pc.lancamento_id AND pc.tipo_movimento = 'CREDITO'
      LEFT JOIN contas_contabeis cd ON pd.conta_id = cd.id
      LEFT JOIN contas_contabeis cc ON pc.conta_id = cc.id
    ''';

    List<dynamic> whereArgs = [];
    List<String> whereConditions = [];

    if (dataInicio != null) {
      whereConditions.add('l.data_lancamento >= ?');
      whereArgs.add(dataInicio.toIso8601String());
    }

    if (dataFim != null) {
      whereConditions.add('l.data_lancamento <= ?');
      whereArgs.add(dataFim.toIso8601String());
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    query += ' ORDER BY l.data_lancamento DESC, l.numero_lancamento DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final db = await _db;
    final maps = await db.rawQuery(query, whereArgs);
    return _processLancamentosWithPartidas(maps);
  }

  Future<LancamentoContabil?> findById(int id) async {
    const query = '''
      SELECT l.*, 
             pd.id as partida_debito_id, pd.conta_id as conta_debito_id, pd.valor as valor_debito,
             pc.id as partida_credito_id, pc.conta_id as conta_credito_id, pc.valor as valor_credito,
             cd.codigo as codigo_debito, cd.nome as nome_debito, cd.tipo as tipo_debito,
             cc.codigo as codigo_credito, cc.nome as nome_credito, cc.tipo as tipo_credito
      FROM lancamentos_contabeis l
      LEFT JOIN partidas_contabeis pd ON l.id = pd.lancamento_id AND pd.tipo_movimento = 'DEBITO'
      LEFT JOIN partidas_contabeis pc ON l.id = pc.lancamento_id AND pc.tipo_movimento = 'CREDITO'
      LEFT JOIN contas_contabeis cd ON pd.conta_id = cd.id
      LEFT JOIN contas_contabeis cc ON pc.conta_id = cc.id
      WHERE l.id = ?
    ''';

    final db = await _db;
    final maps = await db.rawQuery(query, [id]);
    if (maps.isNotEmpty) {
      final lancamentos = _processLancamentosWithPartidas(maps);
      return lancamentos.isNotEmpty ? lancamentos.first : null;
    }
    return null;
  }

  Future<int> insert(LancamentoContabil lancamento) async {
    // Validar partida dobrada antes de inserir
    if (!_validarPartidaDobrada(lancamento)) {
      throw Exception(
        'Lançamento deve ter exatamente uma partida de débito e uma de crédito com valores iguais',
      );
    }

    final db = await _db;
    return await db.transaction((txn) async {
      // Inserir o lançamento
      final lancamentoId = await txn.insert(
        'lancamentos_contabeis',
        lancamento.toMap(),
      );

      // Inserir as partidas
      if (lancamento.partidas != null) {
        for (final partida in lancamento.partidas!) {
          await txn.insert(
            'partidas_contabeis',
            partida.copyWith(lancamentoId: lancamentoId).toMap(),
          );
        }
      }

      return lancamentoId;
    });
  }

  Future<int> update(LancamentoContabil lancamento) async {
    if (!_validarPartidaDobrada(lancamento)) {
      throw Exception(
        'Lançamento deve ter exatamente uma partida de débito e uma de crédito com valores iguais',
      );
    }

    final db = await _db;
    return await db.transaction((txn) async {
      // Atualizar o lançamento
      final result = await txn.update(
        'lancamentos_contabeis',
        lancamento.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [lancamento.id],
      );

      // Atualizar as partidas (deletar e recriar)
      await txn.delete(
        'partidas_contabeis',
        where: 'lancamento_id = ?',
        whereArgs: [lancamento.id],
      );

      if (lancamento.partidas != null) {
        for (final partida in lancamento.partidas!) {
          await txn.insert(
            'partidas_contabeis',
            partida.copyWith(lancamentoId: lancamento.id!).toMap(),
          );
        }
      }

      return result;
    });
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.transaction((txn) async {
      // As partidas serão deletadas automaticamente pelo CASCADE
      return await txn.delete(
        'lancamentos_contabeis',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<String> gerarProximoNumero() async {
    final hoje = DateTime.now();
    final prefixo =
        'LC${hoje.year}${hoje.month.toString().padLeft(2, '0')}${hoje.day.toString().padLeft(2, '0')}';

    final db = await _db;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM lancamentos_contabeis WHERE numero_lancamento LIKE ?",
      ['$prefixo%'],
    );

    final count = (result.first['count'] as int) + 1;
    return '$prefixo-${count.toString().padLeft(3, '0')}';
  }

  Future<Map<String, double>> obterSaldosPorConta({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    String query = '''
      SELECT c.codigo, c.nome, c.tipo,
             COALESCE(SUM(CASE WHEN p.tipo_movimento = 'DEBITO' THEN p.valor ELSE 0 END), 0) as total_debito,
             COALESCE(SUM(CASE WHEN p.tipo_movimento = 'CREDITO' THEN p.valor ELSE 0 END), 0) as total_credito
      FROM contas_contabeis c
      LEFT JOIN partidas_contabeis p ON c.id = p.conta_id
      LEFT JOIN lancamentos_contabeis l ON p.lancamento_id = l.id
    ''';

    List<dynamic> whereArgs = [];
    List<String> whereConditions = [];

    if (dataInicio != null) {
      whereConditions.add('l.data_lancamento >= ?');
      whereArgs.add(dataInicio.toIso8601String());
    }

    if (dataFim != null) {
      whereConditions.add('l.data_lancamento <= ?');
      whereArgs.add(dataFim.toIso8601String());
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    query += ' GROUP BY c.id, c.codigo, c.nome, c.tipo ORDER BY c.codigo';

    final db = await _db;
    final maps = await db.rawQuery(query, whereArgs);

    Map<String, double> saldos = {};

    for (final map in maps) {
      final codigo = map['codigo'] as String;
      final tipo = map['tipo'] as String;
      final debito = (map['total_debito'] as num).toDouble();
      final credito = (map['total_credito'] as num).toDouble();

      // Calcular saldo conforme natureza da conta
      double saldo;
      switch (tipo) {
        case 'ATIVO':
        case 'DESPESA':
          saldo = debito - credito; // Natureza devedora
          break;
        case 'PASSIVO':
        case 'PATRIMONIO_SOCIAL':
        case 'RECEITA':
          saldo = credito - debito; // Natureza credora
          break;
        default:
          saldo = debito - credito;
      }

      saldos[codigo] = saldo;
    }

    return saldos;
  }

  List<LancamentoContabil> _processLancamentosWithPartidas(
    List<Map<String, dynamic>> maps,
  ) {
    Map<int, LancamentoContabil> lancamentosMap = {};

    for (final map in maps) {
      final lancamentoId = map['id'] as int;

      if (!lancamentosMap.containsKey(lancamentoId)) {
        lancamentosMap[lancamentoId] = LancamentoContabil.fromMap(
          map,
          partidas: [],
        );
      }

      final lancamento = lancamentosMap[lancamentoId]!;

      // Adicionar partida de débito
      if (map['partida_debito_id'] != null) {
        final contaDebito = ContaContabil(
          id: map['conta_debito_id'],
          codigo: map['codigo_debito'] ?? '',
          nome: map['nome_debito'] ?? '',
          tipo: TipoConta.fromString(map['tipo_debito'] ?? 'ATIVO'),
          nivel: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final partidaDebito = PartidaContabil(
          id: map['partida_debito_id'],
          lancamentoId: lancamentoId,
          contaId: map['conta_debito_id'],
          tipoMovimento: TipoMovimento.debito,
          valor: (map['valor_debito'] as num).toDouble(),
          createdAt: DateTime.now(),
          conta: contaDebito,
        );

        if (!lancamento.partidas!.any(
          (p) => p.tipoMovimento == TipoMovimento.debito,
        )) {
          lancamento.partidas!.add(partidaDebito);
        }
      }

      // Adicionar partida de crédito
      if (map['partida_credito_id'] != null) {
        final contaCredito = ContaContabil(
          id: map['conta_credito_id'],
          codigo: map['codigo_credito'] ?? '',
          nome: map['nome_credito'] ?? '',
          tipo: TipoConta.fromString(map['tipo_credito'] ?? 'ATIVO'),
          nivel: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final partidaCredito = PartidaContabil(
          id: map['partida_credito_id'],
          lancamentoId: lancamentoId,
          contaId: map['conta_credito_id'],
          tipoMovimento: TipoMovimento.credito,
          valor: (map['valor_credito'] as num).toDouble(),
          createdAt: DateTime.now(),
          conta: contaCredito,
        );

        if (!lancamento.partidas!.any(
          (p) => p.tipoMovimento == TipoMovimento.credito,
        )) {
          lancamento.partidas!.add(partidaCredito);
        }
      }
    }

    return lancamentosMap.values.toList();
  }

  bool _validarPartidaDobrada(LancamentoContabil lancamento) {
    if (lancamento.partidas == null || lancamento.partidas!.length != 2) {
      return false;
    }

    final partidas = lancamento.partidas!;
    final partidaDebito = partidas.firstWhere(
      (p) => p.tipoMovimento == TipoMovimento.debito,
      orElse: () => throw Exception('Partida de débito não encontrada'),
    );
    final partidaCredito = partidas.firstWhere(
      (p) => p.tipoMovimento == TipoMovimento.credito,
      orElse: () => throw Exception('Partida de crédito não encontrada'),
    );

    return partidaDebito.valor == partidaCredito.valor &&
        partidaDebito.valor == lancamento.valorTotal;
  }
}

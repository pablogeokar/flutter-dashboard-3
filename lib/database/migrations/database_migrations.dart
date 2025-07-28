// lib/database/migrations/database_migrations.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseMigrations {
  static Future<void> onCreate(Database db, int version) async {
    await _createMembrosTable(db);
    await _createConfiguracoesTable(db);
    await _createContribuicoesTable(db);
    await inserirConfiguracoesDefault(db);
  }

  static Future<void> _createMembrosTable(Database db) async {
    await db.execute('''
      CREATE TABLE membros(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        status TEXT NOT NULL DEFAULT 'ativo',
        observacoes TEXT
      )
    ''');
  }

  static Future<void> _createConfiguracoesTable(Database db) async {
    await db.execute('''
      CREATE TABLE configuracoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chave TEXT NOT NULL UNIQUE,
        valor TEXT NOT NULL,
        descricao TEXT,
        data_atualizacao INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createContribuicoesTable(Database db) async {
    await db.execute('''
      CREATE TABLE contribuicoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        membro_id INTEGER NOT NULL,
        valor REAL NOT NULL,
        mes_referencia INTEGER NOT NULL,
        ano_referencia INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pendente',
        data_geracao INTEGER NOT NULL,
        data_pagamento INTEGER,
        observacoes TEXT,
        FOREIGN KEY (membro_id) REFERENCES membros (id) ON DELETE CASCADE,
        UNIQUE(membro_id, mes_referencia, ano_referencia)
      )
    ''');
  }

  static Future<void> inserirConfiguracoesDefault(Database db) async {
    final configuracoesPadrao = [
      {
        'chave': 'valor_contribuicao_mensal',
        'valor': '100.00',
        'descricao': 'Valor da contribuição mensal dos membros da loja',
        'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'chave': 'nome_loja',
        'valor': 'Harmonia, Luz e Sigilo',
        'descricao': 'Nome da loja',
        'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'chave': 'cnpj',
        'valor': '13.613.963/0001-02',
        'descricao': 'CNPJ',
        'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (var config in configuracoesPadrao) {
      await db.insert('configuracoes', config);
    }
  }
}

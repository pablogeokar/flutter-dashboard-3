// lib/database/migrations/database_migrations.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseMigrations {
  static Future<void> onCreate(Database db, int version) async {
    await _createMembrosTable(db);
    await _createConfiguracoesTable(db);
    await _createContribuicoesTable(db);
    await _createContasContabeisTable(db);
    await _createLancamentosContabeisTable(db);
    await _createPartidasContabeisTable(db);
    await _createTemplatesLancamentosTable(db);
    await inserirPlanoDeContas(db);
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

  static Future<void> _createContasContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE contas_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('ATIVO', 'PASSIVO', 'PATRIMONIO', 'RECEITA', 'DESPESA')),
        ativa BOOLEAN NOT NULL DEFAULT 1,
        data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        data_alteracao TEXT
      );
    ''');
  }

  static Future<void> _createLancamentosContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE lancamentos_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL DEFAULT (date('now', 'localtime')),
        valor REAL NOT NULL CHECK(valor > 0),
        historico TEXT NOT NULL,
        usuario_id INTEGER,
        template_id INTEGER,
        data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        data_alteracao TEXT,
        FOREIGN KEY (usuario_id) REFERENCES membros(id)
      );
    ''');
  }

  static Future<void> _createPartidasContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE partidas_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lancamento_id INTEGER NOT NULL,
        conta_id INTEGER NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('DEBITO', 'CREDITO')),
        valor REAL NOT NULL CHECK(valor > 0),
        data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (lancamento_id) REFERENCES lancamentos_contabeis(id) ON DELETE CASCADE,
        FOREIGN KEY (conta_id) REFERENCES contas_contabeis(id)
      );
    ''');
  }

  static Future<void> _createTemplatesLancamentosTable(Database db) async {
    await db.execute('''
      CREATE TABLE templates_lancamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        conta_debito_id INTEGER NOT NULL,
        conta_credito_id INTEGER NOT NULL,
        historico_padrao TEXT,
        ativo BOOLEAN NOT NULL DEFAULT 1,
        data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        data_alteracao TEXT,
        FOREIGN KEY (conta_debito_id) REFERENCES contas_contabeis(id),
        FOREIGN KEY (conta_credito_id) REFERENCES contas_contabeis(id)
      );
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

  static Future<void> inserirPlanoDeContas(Database db) async {
    final contas = [
      // ATIVO
      ContaContabil(codigo: '1.1.1', nome: 'Caixa', tipo: 'ATIVO'),
      ContaContabil(
        codigo: '1.1.2',
        nome: 'Bancos Conta Movimento',
        tipo: 'ATIVO',
      ),
      ContaContabil(
        codigo: '1.1.4',
        nome: 'Contribuições a Receber',
        tipo: 'ATIVO',
      ),
      ContaContabil(codigo: '1.2.1.1', nome: 'Edifícios/Sede', tipo: 'ATIVO'),

      // PASSIVO
      ContaContabil(
        codigo: '2.1.1',
        nome: 'Obrigações Sociais e Trabalhistas',
        tipo: 'PASSIVO',
      ),
      ContaContabil(
        codigo: '2.1.2',
        nome: 'Obrigações Fiscais',
        tipo: 'PASSIVO',
      ),

      // PATRIMONIO
      ContaContabil(
        codigo: '2.2.1',
        nome: 'Patrimônio Social',
        tipo: 'PATRIMONIO',
      ),
      ContaContabil(
        codigo: '2.2.2',
        nome: 'Superávit ou Déficit',
        tipo: 'PATRIMONIO',
      ),

      // RECEITAS
      ContaContabil(
        codigo: '3.1.1',
        nome: 'Contribuições Mensais',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.2',
        nome: 'Troncos de Solidariede/Doações',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.3',
        nome: 'Taxas de Iniciação',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.4',
        nome: 'Taxas de Elevação',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.5',
        nome: 'Taxas de Exaltação',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.6',
        nome: 'Receitas de Alugueis',
        tipo: 'RECEITA',
      ),
      ContaContabil(
        codigo: '3.1.7',
        nome: 'Receitas de Campanhas',
        tipo: 'RECEITA',
      ),

      // DESPESAS
      ContaContabil(
        codigo: '4.1.1',
        nome: 'Manutenção da Sede',
        tipo: 'DESPESA',
      ),
      ContaContabil(
        codigo: '4.1.2',
        nome: 'Despesas com Eventos',
        tipo: 'DESPESA',
      ),
      ContaContabil(
        codigo: '4.1.3',
        nome: 'Material de Escritório',
        tipo: 'DESPESA',
      ),
      ContaContabil(
        codigo: '4.1.4',
        nome: 'Serviços de Terceiros',
        tipo: 'DESPESA',
      ),
    ];

    for (var conta in contas) {
      await db.insert('contas_contabeis', conta.toMap());
    }
  }
}

// // lib/database/migrations/database_migrations.dart
// import 'package:flutter_dashboard_3/models/conta_contabil.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class DatabaseMigrations {
//   static Future<void> onCreate(Database db, int version) async {
//     await _createMembrosTable(db);
//     await _createConfiguracoesTable(db);
//     await _createContribuicoesTable(db);
//     await _createContasContabeisTable(db);
//     await _createLancamentosContabeisTable(db);
//     await _createPartidasContabeisTable(db);
//     await _createTemplatesLancamentosTable(db);
//     await inserirPlanoDeContas(db);
//     await inserirConfiguracoesDefault(db);
//   }

//   static Future<void> _createMembrosTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE membros(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nome TEXT NOT NULL,
//         email TEXT,
//         telefone TEXT,
//         status TEXT NOT NULL DEFAULT 'ativo',
//         observacoes TEXT
//       )
//     ''');
//   }

//   static Future<void> _createConfiguracoesTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE configuracoes(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         chave TEXT NOT NULL UNIQUE,
//         valor TEXT NOT NULL,
//         descricao TEXT,
//         data_atualizacao INTEGER NOT NULL
//       )
//     ''');
//   }

//   static Future<void> _createContribuicoesTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE contribuicoes(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         membro_id INTEGER NOT NULL,
//         valor REAL NOT NULL,
//         mes_referencia INTEGER NOT NULL,
//         ano_referencia INTEGER NOT NULL,
//         status TEXT NOT NULL DEFAULT 'pendente',
//         data_geracao INTEGER NOT NULL,
//         data_pagamento INTEGER,
//         observacoes TEXT,
//         FOREIGN KEY (membro_id) REFERENCES membros (id) ON DELETE CASCADE,
//         UNIQUE(membro_id, mes_referencia, ano_referencia)
//       )
//     ''');
//   }

//   static Future<void> _createContasContabeisTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE contas_contabeis (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         codigo TEXT NOT NULL UNIQUE,
//         nome TEXT NOT NULL,
//         tipo TEXT NOT NULL CHECK(tipo IN ('ATIVO', 'PASSIVO', 'PATRIMONIO', 'RECEITA', 'DESPESA')),
//         ativa BOOLEAN NOT NULL DEFAULT 1,
//         data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
//         data_alteracao TEXT
//       );
//     ''');
//   }

//   static Future<void> _createLancamentosContabeisTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE lancamentos_contabeis (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         data TEXT NOT NULL DEFAULT (date('now', 'localtime')),
//         valor REAL NOT NULL CHECK(valor > 0),
//         historico TEXT NOT NULL,
//         usuario_id INTEGER,
//         template_id INTEGER,
//         data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
//         data_alteracao TEXT,
//         FOREIGN KEY (usuario_id) REFERENCES membros(id)
//       );
//     ''');
//   }

//   static Future<void> _createPartidasContabeisTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE partidas_contabeis (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         lancamento_id INTEGER NOT NULL,
//         conta_id INTEGER NOT NULL,
//         tipo TEXT NOT NULL CHECK(tipo IN ('DEBITO', 'CREDITO')),
//         valor REAL NOT NULL CHECK(valor > 0),
//         data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
//         FOREIGN KEY (lancamento_id) REFERENCES lancamentos_contabeis(id) ON DELETE CASCADE,
//         FOREIGN KEY (conta_id) REFERENCES contas_contabeis(id)
//       );
//     ''');
//   }

//   static Future<void> _createTemplatesLancamentosTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE templates_lancamentos (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nome TEXT NOT NULL,
//         descricao TEXT,
//         conta_debito_id INTEGER NOT NULL,
//         conta_credito_id INTEGER NOT NULL,
//         historico_padrao TEXT,
//         ativo BOOLEAN NOT NULL DEFAULT 1,
//         data_criacao TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
//         data_alteracao TEXT,
//         FOREIGN KEY (conta_debito_id) REFERENCES contas_contabeis(id),
//         FOREIGN KEY (conta_credito_id) REFERENCES contas_contabeis(id)
//       );
//     ''');
//   }

//   static Future<void> inserirConfiguracoesDefault(Database db) async {
//     final configuracoesPadrao = [
//       {
//         'chave': 'valor_contribuicao_mensal',
//         'valor': '100.00',
//         'descricao': 'Valor da contribuição mensal dos membros da loja',
//         'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
//       },
//       {
//         'chave': 'nome_loja',
//         'valor': 'Harmonia, Luz e Sigilo',
//         'descricao': 'Nome da loja',
//         'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
//       },
//       {
//         'chave': 'cnpj',
//         'valor': '13.613.963/0001-02',
//         'descricao': 'CNPJ',
//         'data_atualizacao': DateTime.now().millisecondsSinceEpoch,
//       },
//     ];

//     for (var config in configuracoesPadrao) {
//       await db.insert('configuracoes', config);
//     }
//   }

//   static Future<void> inserirPlanoDeContas(Database db) async {
//     final contas = [
//       // ATIVO
//       ContaContabil(codigo: '1.1.1', nome: 'Caixa', tipo: 'ATIVO'),
//       ContaContabil(
//         codigo: '1.1.2',
//         nome: 'Bancos Conta Movimento',
//         tipo: 'ATIVO',
//       ),
//       ContaContabil(
//         codigo: '1.1.4',
//         nome: 'Contribuições a Receber',
//         tipo: 'ATIVO',
//       ),
//       ContaContabil(codigo: '1.2.1.1', nome: 'Edifícios/Sede', tipo: 'ATIVO'),

//       // PASSIVO
//       ContaContabil(
//         codigo: '2.1.1',
//         nome: 'Obrigações Sociais e Trabalhistas',
//         tipo: 'PASSIVO',
//       ),
//       ContaContabil(
//         codigo: '2.1.2',
//         nome: 'Obrigações Fiscais',
//         tipo: 'PASSIVO',
//       ),

//       // PATRIMONIO
//       ContaContabil(
//         codigo: '2.2.1',
//         nome: 'Patrimônio Social',
//         tipo: 'PATRIMONIO',
//       ),
//       ContaContabil(
//         codigo: '2.2.2',
//         nome: 'Superávit ou Déficit',
//         tipo: 'PATRIMONIO',
//       ),

//       // RECEITAS
//       ContaContabil(
//         codigo: '3.1.1',
//         nome: 'Contribuições Mensais',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.2',
//         nome: 'Troncos de Solidariede/Doações',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.3',
//         nome: 'Taxas de Iniciação',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.4',
//         nome: 'Taxas de Elevação',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.5',
//         nome: 'Taxas de Exaltação',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.6',
//         nome: 'Receitas de Alugueis',
//         tipo: 'RECEITA',
//       ),
//       ContaContabil(
//         codigo: '3.1.7',
//         nome: 'Receitas de Campanhas',
//         tipo: 'RECEITA',
//       ),

//       // DESPESAS
//       ContaContabil(
//         codigo: '4.1.1',
//         nome: 'Manutenção da Sede',
//         tipo: 'DESPESA',
//       ),
//       ContaContabil(
//         codigo: '4.1.2',
//         nome: 'Despesas com Eventos',
//         tipo: 'DESPESA',
//       ),
//       ContaContabil(
//         codigo: '4.1.3',
//         nome: 'Material de Escritório',
//         tipo: 'DESPESA',
//       ),
//       ContaContabil(
//         codigo: '4.1.4',
//         nome: 'Serviços de Terceiros',
//         tipo: 'DESPESA',
//       ),
//     ];

//     for (var conta in contas) {
//       await db.insert('contas_contabeis', conta.toMap());
//     }
//   }
// }

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseMigrations {
  static Future<void> onCreate(Database db, int version) async {
    await _createMembrosTable(db);
    await _createConfiguracoesTable(db);
    await _createContribuicoesTable(db);
    await insertConfiguracoesDefault(db);

    // Módulo contábil
    await _createContasContabeisTable(db);
    await _insertContasContabeis(db);
    await _createTemplatesLancamentoTable(db);
    await _createLancamentosContabeisTable(db);
    await _createPartidasContabeisTable(db);
    await _insertTemplatesLancamento(db);
    await _createContabilidadeIndexes(db);
    await _createTriggerPartidaDobrada(db);
  }

  // Módulo principal
  static Future<void> _createMembrosTable(Database db) async {
    await db.execute('''
      CREATE TABLE membros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        status TEXT NOT NULL DEFAULT 'ativo',
        observacoes TEXT
      );
    ''');
  }

  static Future<void> _createConfiguracoesTable(Database db) async {
    await db.execute('''
      CREATE TABLE configuracoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chave TEXT NOT NULL UNIQUE,
        valor TEXT NOT NULL,
        descricao TEXT,
        data_atualizacao INTEGER NOT NULL
      );
    ''');
  }

  static Future<void> _createContribuicoesTable(Database db) async {
    await db.execute('''
      CREATE TABLE contribuicoes (
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
      );
    ''');
  }

  static Future<void> insertConfiguracoesDefault(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final configuracoes = [
      {
        'chave': 'valor_contribuicao_mensal',
        'valor': '100.00',
        'descricao': 'Valor da contribuição mensal dos membros da loja',
        'data_atualizacao': now,
      },
      {
        'chave': 'nome_loja',
        'valor': 'Harmonia, Luz e Sigilo',
        'descricao': 'Nome da loja',
        'data_atualizacao': now,
      },
      {
        'chave': 'cnpj',
        'valor': '13.613.963/0001-02',
        'descricao': 'CNPJ',
        'data_atualizacao': now,
      },
    ];

    for (var config in configuracoes) {
      await db.insert('configuracoes', config);
    }
  }

  // Módulo contábil
  static Future<void> _createContasContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE contas_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK (tipo IN ('ATIVO', 'PASSIVO', 'PATRIMONIO_SOCIAL', 'RECEITA', 'DESPESA')),
        nivel INTEGER NOT NULL,
        conta_pai_id INTEGER,
        ativa INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (conta_pai_id) REFERENCES contas_contabeis (id)
      );
    ''');
  }

  static Future<void> _insertContasContabeis(Database db) async {
    await db.execute('''
      INSERT INTO contas_contabeis (codigo, nome, tipo, nivel, conta_pai_id) VALUES
      ('1', 'ATIVO', 'ATIVO', 1, NULL),
      ('1.1', 'ATIVO CIRCULANTE', 'ATIVO', 2, 1),
      ('1.1.1', 'Caixa', 'ATIVO', 3, 2),
      ('1.1.2', 'Bancos Conta Movimento', 'ATIVO', 3, 2),
      ('1.1.4', 'Contribuições a Receber', 'ATIVO', 3, 2),
      ('1.2', 'ATIVO NÃO CIRCULANTE', 'ATIVO', 2, 1),
      ('1.2.1', 'IMOBILIZADO', 'ATIVO', 3, 6),
      ('1.2.1.1', 'Edifícios/Sede', 'ATIVO', 4, 7),
      ('2', 'PASSIVO', 'PASSIVO', 1, NULL),
      ('2.1', 'PASSIVO CIRCULANTE', 'PASSIVO', 2, 9),
      ('2.1.1', 'Obrigações Sociais e Trabalhistas', 'PASSIVO', 3, 10),
      ('2.1.2', 'Obrigações Fiscais', 'PASSIVO', 3, 10),
      ('2.2', 'PATRIMÔNIO SOCIAL', 'PATRIMONIO_SOCIAL', 2, 9),
      ('2.2.1', 'Patrimônio Social', 'PATRIMONIO_SOCIAL', 3, 13),
      ('2.2.2', 'Superávit ou Déficit', 'PATRIMONIO_SOCIAL', 3, 13),
      ('3', 'RECEITAS', 'RECEITA', 1, NULL),
      ('3.1', 'RECEITAS OPERACIONAIS', 'RECEITA', 2, 16),
      ('3.1.1', 'Contribuições Mensais', 'RECEITA', 3, 17),
      ('3.1.2', 'Taxas de Iniciação', 'RECEITA', 3, 17),
      ('3.1.3', 'Receitas de Eventos', 'RECEITA', 3, 17),
      ('3.1.4', 'Doações', 'RECEITA', 3, 17),
      ('4', 'DESPESAS', 'DESPESA', 1, NULL),
      ('4.1', 'DESPESAS OPERACIONAIS', 'DESPESA', 2, 22),
      ('4.1.1', 'Manutenção da Sede', 'DESPESA', 3, 23),
      ('4.1.2', 'Despesas com Eventos', 'DESPESA', 3, 23),
      ('4.1.3', 'Material de Escritório', 'DESPESA', 3, 23),
      ('4.1.4', 'Serviços de Terceiros', 'DESPESA', 3, 23);
    ''');
  }

  static Future<void> _createTemplatesLancamentoTable(Database db) async {
    await db.execute('''
      CREATE TABLE templates_lancamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        historico_padrao TEXT NOT NULL,
        conta_debito_id INTEGER NOT NULL,
        conta_credito_id INTEGER NOT NULL,
        ativo INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (conta_debito_id) REFERENCES contas_contabeis (id),
        FOREIGN KEY (conta_credito_id) REFERENCES contas_contabeis (id)
      );
    ''');
  }

  static Future<void> _insertTemplatesLancamento(Database db) async {
    await db.execute('''
      INSERT INTO templates_lancamento (nome, descricao, historico_padrao, conta_debito_id, conta_credito_id) VALUES
      ('Recebimento Contribuição - Caixa', 'Recebimento de contribuição mensal em dinheiro', 'Recebimento contribuição mensal - {membro}', 3, 18),
      ('Recebimento Contribuição - Banco', 'Recebimento de contribuição mensal via transferência/depósito', 'Recebimento contribuição mensal - {membro}', 4, 18),
      ('Recebimento Taxa Iniciação', 'Recebimento de taxa de iniciação', 'Taxa de iniciação - {membro}', 3, 19),
      ('Pagamento Material Escritório', 'Compra de material de escritório', 'Compra material escritório - {fornecedor}', 26, 3),
      ('Pagamento Manutenção Sede', 'Pagamento de despesas com manutenção', 'Manutenção da sede - {servico}', 24, 3),
      ('Recebimento Doação', 'Recebimento de doação', 'Doação recebida - {doador}', 3, 21),
      ('Despesa com Eventos', 'Pagamento de despesas com eventos', 'Despesa evento - {evento}', 25, 3),
      ('Pagamento Serviços Terceiros', 'Pagamento de serviços de terceiros', 'Serviços terceiros - {prestador}', 27, 4);
    ''');
  }

  static Future<void> _createLancamentosContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE lancamentos_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_lancamento TEXT NOT NULL UNIQUE,
        data_lancamento TEXT NOT NULL,
        valor_total REAL NOT NULL CHECK (valor_total > 0),
        historico TEXT NOT NULL,
        tipo_documento TEXT,
        numero_documento TEXT,
        observacoes TEXT,
        usuario_id INTEGER,
        template_id INTEGER,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (template_id) REFERENCES templates_lancamento (id)
      );
    ''');
  }

  static Future<void> _createPartidasContabeisTable(Database db) async {
    await db.execute('''
      CREATE TABLE partidas_contabeis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lancamento_id INTEGER NOT NULL,
        conta_id INTEGER NOT NULL,
        tipo_movimento TEXT NOT NULL CHECK (tipo_movimento IN ('DEBITO', 'CREDITO')),
        valor REAL NOT NULL CHECK (valor > 0),
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (lancamento_id) REFERENCES lancamentos_contabeis (id) ON DELETE CASCADE,
        FOREIGN KEY (conta_id) REFERENCES contas_contabeis (id)
      );
    ''');
  }

  static Future<void> _createContabilidadeIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_contas_codigo ON contas_contabeis(codigo);',
    );
    await db.execute('CREATE INDEX idx_contas_tipo ON contas_contabeis(tipo);');
    await db.execute(
      'CREATE INDEX idx_lancamentos_data ON lancamentos_contabeis(data_lancamento);',
    );
    await db.execute(
      'CREATE INDEX idx_lancamentos_numero ON lancamentos_contabeis(numero_lancamento);',
    );
    await db.execute(
      'CREATE INDEX idx_partidas_lancamento ON partidas_contabeis(lancamento_id);',
    );
    await db.execute(
      'CREATE INDEX idx_partidas_conta ON partidas_contabeis(conta_id);',
    );
    await db.execute(
      'CREATE INDEX idx_partidas_tipo ON partidas_contabeis(tipo_movimento);',
    );
  }

  static Future<void> _createTriggerPartidaDobrada(Database db) async {
    await db.execute('''
      CREATE TRIGGER check_partida_dobrada
      AFTER INSERT ON partidas_contabeis
      BEGIN
        SELECT CASE 
          WHEN (SELECT COUNT(*) FROM partidas_contabeis WHERE lancamento_id = NEW.lancamento_id) = 2
          THEN
            CASE 
              WHEN (
                SELECT COUNT(DISTINCT tipo_movimento) FROM partidas_contabeis 
                WHERE lancamento_id = NEW.lancamento_id
              ) != 2
              OR (
                SELECT SUM(CASE WHEN tipo_movimento = 'DEBITO' THEN valor ELSE -valor END)
                FROM partidas_contabeis 
                WHERE lancamento_id = NEW.lancamento_id
              ) != 0
              THEN RAISE(ABORT, 'Partida dobrada violada: débito e crédito devem ter valores iguais')
            END
        END;
      END;
    ''');
  }
}

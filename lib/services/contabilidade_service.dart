// services/contabilidade_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';
import 'package:flutter_dashboard_3/database/repositories/conta_contabil_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/lancamento_contabil_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/template_lancamento_repository.dart';
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:flutter_dashboard_3/models/lancamento_contabil.dart';
import 'package:flutter_dashboard_3/models/partida_contabil.dart';
import 'package:flutter_dashboard_3/models/template_lancamento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ContabilidadeService {
  static final ContabilidadeService _instance =
      ContabilidadeService._internal();
  factory ContabilidadeService() => _instance;
  ContabilidadeService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ContaContabilRepository _contaRepository = ContaContabilRepository();
  final LancamentoContabilRepository _lancamentoRepository =
      LancamentoContabilRepository();
  final TemplateLancamentoRepository _templateRepository =
      TemplateLancamentoRepository();

  Future<Database> get _db async => await _databaseHelper.database;

  // Getters para acesso direto aos repositórios
  ContaContabilRepository get contas => _contaRepository;
  LancamentoContabilRepository get lancamentos => _lancamentoRepository;
  TemplateLancamentoRepository get templates => _templateRepository;

  /// Criar um lançamento contábil simples (débito/crédito)
  Future<int> criarLancamento({
    required int contaDebitoId,
    required int contaCreditoId,
    required double valor,
    required String historico,
    DateTime? data,
    String? tipoDocumento,
    String? numeroDocumento,
    String? observacoes,
    int? usuarioId,
  }) async {
    final dataLancamento = data ?? DateTime.now();
    final numeroLancamento = await _lancamentoRepository.gerarProximoNumero();
    final now = DateTime.now();

    final lancamento = LancamentoContabil(
      numeroLancamento: numeroLancamento,
      dataLancamento: dataLancamento,
      valorTotal: valor,
      historico: historico,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      observacoes: observacoes,
      usuarioId: usuarioId,
      createdAt: now,
      updatedAt: now,
      partidas: [
        PartidaContabil(
          lancamentoId: 0, // Será definido após salvar
          contaId: contaDebitoId,
          tipoMovimento: TipoMovimento.debito,
          valor: valor,
          createdAt: now,
        ),
        PartidaContabil(
          lancamentoId: 0, // Será definido após salvar
          contaId: contaCreditoId,
          tipoMovimento: TipoMovimento.credito,
          valor: valor,
          createdAt: now,
        ),
      ],
    );

    return await _lancamentoRepository.insert(lancamento);
  }

  /// Criar lançamento a partir de um template
  Future<int> criarLancamentoDeTemplate({
    required int templateId,
    required double valor,
    required Map<String, String> variaveis,
    DateTime? data,
    String? tipoDocumento,
    String? numeroDocumento,
    String? observacoes,
    int? usuarioId,
  }) async {
    final template = await _templateRepository.findById(templateId);
    if (template == null) {
      throw Exception('Template de lançamento não encontrado');
    }

    final lancamento = template.criarLancamento(
      valor: valor,
      data: data ?? DateTime.now(),
      variaveis: variaveis,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      observacoes: observacoes,
      usuarioId: usuarioId,
    );

    // Gerar número sequencial
    final numeroLancamento = await _lancamentoRepository.gerarProximoNumero();
    final lancamentoComNumero = lancamento.copyWith(
      numeroLancamento: numeroLancamento,
    );

    return await _lancamentoRepository.insert(lancamentoComNumero);
  }

  /// Lançamentos rápidos para operações comuns da loja maçônica
  Future<int> receberContribuicaoMensal({
    required String nomeMembro,
    required double valor,
    required bool emDinheiro, // true = caixa, false = banco
    DateTime? data,
    String? numeroDocumento,
    int? usuarioId,
  }) async {
    final contaDebito = emDinheiro
        ? await _contaRepository.findByCodigo('1.1.1') // Caixa
        : await _contaRepository.findByCodigo('1.1.2'); // Banco

    final contaCredito = await _contaRepository.findByCodigo(
      '3.1.1',
    ); // Contribuições Mensais

    if (contaDebito == null || contaCredito == null) {
      throw Exception('Contas contábeis não encontradas');
    }

    return await criarLancamento(
      contaDebitoId: contaDebito.id!,
      contaCreditoId: contaCredito.id!,
      valor: valor,
      historico: 'Recebimento contribuição mensal - $nomeMembro',
      data: data,
      tipoDocumento: emDinheiro ? 'RECIBO' : 'TRANSFERENCIA',
      numeroDocumento: numeroDocumento,
      usuarioId: usuarioId,
    );
  }

  Future<int> receberTaxaIniciacao({
    required String nomeMembro,
    required double valor,
    DateTime? data,
    String? numeroDocumento,
    int? usuarioId,
  }) async {
    final contaDebito = await _contaRepository.findByCodigo('1.1.1'); // Caixa
    final contaCredito = await _contaRepository.findByCodigo(
      '3.1.2',
    ); // Taxas de Iniciação

    if (contaDebito == null || contaCredito == null) {
      throw Exception('Contas contábeis não encontradas');
    }

    return await criarLancamento(
      contaDebitoId: contaDebito.id!,
      contaCreditoId: contaCredito.id!,
      valor: valor,
      historico: 'Taxa de iniciação - $nomeMembro',
      data: data,
      tipoDocumento: 'RECIBO',
      numeroDocumento: numeroDocumento,
      usuarioId: usuarioId,
    );
  }

  Future<int> receberDoacao({
    required String nomeDoador,
    required double valor,
    required bool emDinheiro,
    DateTime? data,
    String? observacoes,
    int? usuarioId,
  }) async {
    final contaDebito = emDinheiro
        ? await _contaRepository.findByCodigo('1.1.1') // Caixa
        : await _contaRepository.findByCodigo('1.1.2'); // Banco

    final contaCredito = await _contaRepository.findByCodigo(
      '3.1.4',
    ); // Doações

    if (contaDebito == null || contaCredito == null) {
      throw Exception('Contas contábeis não encontradas');
    }

    return await criarLancamento(
      contaDebitoId: contaDebito.id!,
      contaCreditoId: contaCredito.id!,
      valor: valor,
      historico: 'Doação recebida - $nomeDoador',
      data: data,
      tipoDocumento: 'DOACAO',
      observacoes: observacoes,
      usuarioId: usuarioId,
    );
  }

  Future<int> pagarDespesa({
    required String codigoContaDespesa,
    required double valor,
    required String descricao,
    required bool pagoEmDinheiro,
    DateTime? data,
    String? numeroDocumento,
    String? fornecedor,
    int? usuarioId,
  }) async {
    final contaDespesa = await _contaRepository.findByCodigo(
      codigoContaDespesa,
    );
    final contaPagamento = pagoEmDinheiro
        ? await _contaRepository.findByCodigo('1.1.1') // Caixa
        : await _contaRepository.findByCodigo('1.1.2'); // Banco

    if (contaDespesa == null || contaPagamento == null) {
      throw Exception('Contas contábeis não encontradas');
    }

    final historico = fornecedor != null
        ? '$descricao - $fornecedor'
        : descricao;

    return await criarLancamento(
      contaDebitoId: contaDespesa.id!,
      contaCreditoId: contaPagamento.id!,
      valor: valor,
      historico: historico,
      data: data,
      tipoDocumento: pagoEmDinheiro ? 'RECIBO' : 'TRANSFERENCIA',
      numeroDocumento: numeroDocumento,
      usuarioId: usuarioId,
    );
  }

  /// Obter balancete de verificação
  Future<Map<String, dynamic>> gerarBalancete({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final saldos = await _lancamentoRepository.obterSaldosPorConta(
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    final contas = await _contaRepository.findAll(somenteAtivas: true);

    double totalDebitos = 0;
    double totalCreditos = 0;
    List<Map<String, dynamic>> linhasBalancete = [];

    for (final conta in contas) {
      final saldo = saldos[conta.codigo] ?? 0.0;

      if (saldo != 0 || conta.isAnalitica) {
        double debito = 0;
        double credito = 0;

        // Determinar se o saldo vai para débito ou crédito
        switch (conta.tipo) {
          case TipoConta.ativo:
          case TipoConta.despesa:
            if (saldo > 0) debito = saldo;
            if (saldo < 0) credito = saldo.abs();
            break;
          case TipoConta.passivo:
          case TipoConta.patrimonioSocial:
          case TipoConta.receita:
            if (saldo > 0) credito = saldo;
            if (saldo < 0) debito = saldo.abs();
            break;
        }

        totalDebitos += debito;
        totalCreditos += credito;

        linhasBalancete.add({
          'conta': conta,
          'saldo': saldo,
          'debito': debito,
          'credito': credito,
        });
      }
    }

    return {
      'linhas': linhasBalancete,
      'totalDebitos': totalDebitos,
      'totalCreditos': totalCreditos,
      'diferenca': totalDebitos - totalCreditos,
      'balanceado': (totalDebitos - totalCreditos).abs() < 0.01,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'dataGeracao': DateTime.now(),
    };
  }

  /// Obter DRE (Demonstração do Resultado do Exercício) simplificada
  Future<Map<String, dynamic>> gerarDRE({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final saldos = await _lancamentoRepository.obterSaldosPorConta(
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    final contasReceita = await _contaRepository.findByTipo(TipoConta.receita);
    final contasDespesas = await _contaRepository.findByTipo(TipoConta.despesa);

    double totalReceitas = 0;
    double totalDespesas = 0;
    List<Map<String, dynamic>> receitas = [];
    List<Map<String, dynamic>> despesas = [];

    for (final conta in contasReceita) {
      final saldo = saldos[conta.codigo] ?? 0.0;
      if (saldo != 0) {
        receitas.add({'conta': conta, 'valor': saldo});
        totalReceitas += saldo;
      }
    }

    for (final conta in contasDespesas) {
      final saldo = saldos[conta.codigo] ?? 0.0;
      if (saldo != 0) {
        despesas.add({'conta': conta, 'valor': saldo});
        totalDespesas += saldo;
      }
    }

    final resultado = totalReceitas - totalDespesas;

    return {
      'receitas': receitas,
      'despesas': despesas,
      'totalReceitas': totalReceitas,
      'totalDespesas': totalDespesas,
      'resultado': resultado,
      'tipoResultado': resultado >= 0 ? 'SUPERAVIT' : 'DEFICIT',
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'dataGeracao': DateTime.now(),
    };
  }

  /// Obter posição financeira (caixa + bancos)
  Future<Map<String, dynamic>> obterPosicaoFinanceira() async {
    final saldos = await _lancamentoRepository.obterSaldosPorConta();

    final saldoCaixa = saldos['1.1.1'] ?? 0.0;
    final saldoBanco = saldos['1.1.2'] ?? 0.0;
    final totalDisponivel = saldoCaixa + saldoBanco;

    return {
      'caixa': saldoCaixa,
      'banco': saldoBanco,
      'totalDisponivel': totalDisponivel,
      'dataConsulta': DateTime.now(),
    };
  }

  /// Validar integridade contábil
  Future<Map<String, dynamic>> validarIntegridade() async {
    final problemas = <String>[];

    // Verificar se há lançamentos desbalanceados
    final db = await _db;
    final lancamentosDesbalanceados = await db.rawQuery('''
      SELECT l.id, l.numero_lancamento, l.valor_total,
             SUM(CASE WHEN p.tipo_movimento = 'DEBITO' THEN p.valor ELSE 0 END) as total_debito,
             SUM(CASE WHEN p.tipo_movimento = 'CREDITO' THEN p.valor ELSE 0 END) as total_credito
      FROM lancamentos_contabeis l
      LEFT JOIN partidas_contabeis p ON l.id = p.lancamento_id
      GROUP BY l.id
      HAVING total_debito != total_credito OR total_debito != l.valor_total
    ''');

    if (lancamentosDesbalanceados.isNotEmpty) {
      problemas.add(
        '${lancamentosDesbalanceados.length} lançamentos desbalanceados encontrados',
      );
    }

    // Verificar se há partidas órfãs
    final partidasOrf = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM partidas_contabeis p 
      LEFT JOIN lancamentos_contabeis l ON p.lancamento_id = l.id 
      WHERE l.id IS NULL
    ''');

    final countOrfas = (partidasOrf.first['count'] as int);
    if (countOrfas > 0) {
      problemas.add('$countOrfas partidas órfãs encontradas');
    }

    // Verificar se há contas com saldo mas sem movimentação
    final contasSemMovimento = await db.rawQuery('''
      SELECT c.codigo, c.nome 
      FROM contas_contabeis c 
      LEFT JOIN partidas_contabeis p ON c.id = p.conta_id 
      WHERE p.id IS NULL AND c.ativa = 1 AND c.nivel >= 3
    ''');

    return {
      'integro': problemas.isEmpty,
      'problemas': problemas,
      'lancamentosDesbalanceados': lancamentosDesbalanceados.length,
      'partidasOrfas': countOrfas,
      'contasSemMovimento': contasSemMovimento.length,
      'dataVerificacao': DateTime.now(),
    };
  }

  /// Obter extrato de uma conta específica
  Future<List<Map<String, dynamic>>> obterExtratoConta({
    required String codigoConta,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    String query = '''
      SELECT l.data_lancamento, l.numero_lancamento, l.historico, l.valor_total,
             p.tipo_movimento, p.valor,
             CASE 
               WHEN p.tipo_movimento = 'DEBITO' THEN p.valor 
               ELSE 0 
             END as debito,
             CASE 
               WHEN p.tipo_movimento = 'CREDITO' THEN p.valor 
               ELSE 0 
             END as credito
      FROM partidas_contabeis p
      JOIN lancamentos_contabeis l ON p.lancamento_id = l.id
      JOIN contas_contabeis c ON p.conta_id = c.id
      WHERE c.codigo = ?
    ''';

    List<dynamic> whereArgs = [codigoConta];

    if (dataInicio != null) {
      query += ' AND l.data_lancamento >= ?';
      whereArgs.add(dataInicio.toIso8601String());
    }

    if (dataFim != null) {
      query += ' AND l.data_lancamento <= ?';
      whereArgs.add(dataFim.toIso8601String());
    }

    query += ' ORDER BY l.data_lancamento, l.numero_lancamento';

    final db = await _db;
    final result = await db.rawQuery(query, whereArgs);

    double saldoAcumulado = 0;
    List<Map<String, dynamic>> extrato = [];

    for (final linha in result) {
      final debito = (linha['debito'] as num).toDouble();
      final credito = (linha['credito'] as num).toDouble();

      // Para contas de natureza devedora (ativo/despesa)
      final conta = await _contaRepository.findByCodigo(codigoConta);
      if (conta != null) {
        switch (conta.tipo) {
          case TipoConta.ativo:
          case TipoConta.despesa:
            saldoAcumulado += debito - credito;
            break;
          case TipoConta.passivo:
          case TipoConta.patrimonioSocial:
          case TipoConta.receita:
            saldoAcumulado += credito - debito;
            break;
        }
      }

      extrato.add({
        'data': DateTime.parse(linha['data_lancamento'] as String),
        'numeroLancamento': linha['numero_lancamento'],
        'historico': linha['historico'],
        'debito': debito,
        'credito': credito,
        'saldo': saldoAcumulado,
      });
    }

    return extrato;
  }

  /// Criar template personalizado
  Future<int> criarTemplate({
    required String nome,
    required String descricao,
    required String historicoPadrao,
    required int contaDebitoId,
    required int contaCreditoId,
  }) async {
    final now = DateTime.now();

    final template = TemplateLancamento(
      nome: nome,
      descricao: descricao,
      historicoPadrao: historicoPadrao,
      contaDebitoId: contaDebitoId,
      contaCreditoId: contaCreditoId,
      createdAt: now,
      updatedAt: now,
    );

    return await _templateRepository.insert(template);
  }

  /// Relatório de movimentação por período
  Future<Map<String, dynamic>> relatorioMovimentacao({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final inicio = dataInicio ?? DateTime(DateTime.now().year, 1, 1);
    final fim = dataFim ?? DateTime.now();

    final lancamentos = await _lancamentoRepository.findAll(
      dataInicio: inicio,
      dataFim: fim,
    );

    double totalMovimentado = 0;
    Map<String, double> movimentacaoPorConta = {};
    Map<String, int> quantidadePorTipo = {};

    for (final lancamento in lancamentos) {
      totalMovimentado += lancamento.valorTotal;

      if (lancamento.partidas != null) {
        for (final partida in lancamento.partidas!) {
          if (partida.conta != null) {
            final codigo = partida.conta!.codigo;
            movimentacaoPorConta[codigo] =
                (movimentacaoPorConta[codigo] ?? 0) + partida.valor;
          }
        }
      }

      // Contar por tipo de documento
      final tipo = lancamento.tipoDocumento ?? 'SEM_TIPO';
      quantidadePorTipo[tipo] = (quantidadePorTipo[tipo] ?? 0) + 1;
    }

    return {
      'periodo': {'inicio': inicio, 'fim': fim},
      'totalLancamentos': lancamentos.length,
      'valorTotalMovimentado': totalMovimentado,
      'movimentacaoPorConta': movimentacaoPorConta,
      'quantidadePorTipoDocumento': quantidadePorTipo,
      'mediaValorLancamento': lancamentos.isNotEmpty
          ? totalMovimentado / lancamentos.length
          : 0,
      'dataGeracao': DateTime.now(),
    };
  }

  /// Backup dos dados contábeis em formato JSON
  Future<Map<String, dynamic>> exportarDadosContabeis({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final contas = await _contaRepository.findAll(somenteAtivas: false);
    final templates = await _templateRepository.findAll(somenteAtivos: false);
    final lancamentos = await _lancamentoRepository.findAll(
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    return {
      'versao': '1.0',
      'dataExportacao': DateTime.now().toIso8601String(),
      'periodo': {
        'inicio': dataInicio?.toIso8601String(),
        'fim': dataFim?.toIso8601String(),
      },
      'contas': contas.map((c) => c.toMap()).toList(),
      'templates': templates.map((t) => t.toMap()).toList(),
      'lancamentos': lancamentos
          .map(
            (l) => {
              ...l.toMap(),
              'partidas': l.partidas?.map((p) => p.toMap()).toList() ?? [],
            },
          )
          .toList(),
    };
  }
}

// Utilitários para formatação de valores e datas
class ContabilidadeUtils {
  static String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static String formatarCodigo(String codigo) {
    return codigo.padRight(10, ' ');
  }

  static Color corPorTipoConta(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.ativo:
        return Colors.blue;
      case TipoConta.passivo:
        return Colors.red;
      case TipoConta.patrimonioSocial:
        return Colors.purple;
      case TipoConta.receita:
        return Colors.green;
      case TipoConta.despesa:
        return Colors.orange;
    }
  }

  static String descricaoTipoConta(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.ativo:
        return 'Ativo';
      case TipoConta.passivo:
        return 'Passivo';
      case TipoConta.patrimonioSocial:
        return 'Patrimônio Social';
      case TipoConta.receita:
        return 'Receita';
      case TipoConta.despesa:
        return 'Despesa';
    }
  }

  static bool validarValor(String valor) {
    if (valor.isEmpty) return false;
    final valorNumerico = double.tryParse(valor.replaceAll(',', '.'));
    return valorNumerico != null && valorNumerico > 0;
  }

  static double parseValor(String valor) {
    return double.parse(valor.replaceAll(',', '.'));
  }

  /// Gerar número de lançamento baseado na data
  static String gerarNumeroLancamento(DateTime data, int sequencia) {
    final ano = data.year.toString();
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    final seq = sequencia.toString().padLeft(3, '0');
    return 'LC$ano$mes$dia-$seq';
  }

  /// Validar se uma string é um código de conta válido
  static bool validarCodigoConta(String codigo) {
    final regex = RegExp(r'^\d+(\.\d+)*$');
    return regex.hasMatch(codigo);
  }

  /// Obter nível do código da conta
  static int obterNivelConta(String codigo) {
    return codigo.split('.').length;
  }
}

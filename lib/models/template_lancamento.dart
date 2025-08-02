// models/template_lancamento.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';
import 'package:flutter_dashboard_3/models/lancamento_contabil.dart';
import 'package:flutter_dashboard_3/models/partida_contabil.dart';

class TemplateLancamento {
  final int? id;
  final String nome;
  final String? descricao;
  final String historicoPadrao;
  final int contaDebitoId;
  final int contaCreditoId;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ContaContabil? contaDebito; // Para joins
  final ContaContabil? contaCredito; // Para joins

  TemplateLancamento({
    this.id,
    required this.nome,
    this.descricao,
    required this.historicoPadrao,
    required this.contaDebitoId,
    required this.contaCreditoId,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
    this.contaDebito,
    this.contaCredito,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'historico_padrao': historicoPadrao,
      'conta_debito_id': contaDebitoId,
      'conta_credito_id': contaCreditoId,
      'ativo': ativo ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TemplateLancamento.fromMap(
    Map<String, dynamic> map, {
    ContaContabil? contaDebito,
    ContaContabil? contaCredito,
  }) {
    return TemplateLancamento(
      id: map['id']?.toInt(),
      nome: map['nome'] ?? '',
      descricao: map['descricao'],
      historicoPadrao: map['historico_padrao'] ?? '',
      contaDebitoId: map['conta_debito_id']?.toInt() ?? 0,
      contaCreditoId: map['conta_credito_id']?.toInt() ?? 0,
      ativo: (map['ativo'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      contaDebito: contaDebito,
      contaCredito: contaCredito,
    );
  }

  TemplateLancamento copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? historicoPadrao,
    int? contaDebitoId,
    int? contaCreditoId,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
    ContaContabil? contaDebito,
    ContaContabil? contaCredito,
  }) {
    return TemplateLancamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      historicoPadrao: historicoPadrao ?? this.historicoPadrao,
      contaDebitoId: contaDebitoId ?? this.contaDebitoId,
      contaCreditoId: contaCreditoId ?? this.contaCreditoId,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contaDebito: contaDebito ?? this.contaDebito,
      contaCredito: contaCredito ?? this.contaCredito,
    );
  }

  @override
  String toString() {
    return 'TemplateLancamento(id: $id, nome: $nome, ativo: $ativo)';
  }

  String processarHistorico(Map<String, String> variaveis) {
    String resultado = historicoPadrao;
    variaveis.forEach((chave, valor) {
      resultado = resultado.replaceAll('{$chave}', valor);
    });
    return resultado;
  }

  LancamentoContabil criarLancamento({
    required double valor,
    required DateTime data,
    Map<String, String> variaveis = const {},
    String? tipoDocumento,
    String? numeroDocumento,
    String? observacoes,
    int? usuarioId,
  }) {
    final now = DateTime.now();
    final numeroLancamento =
        'LC${data.year}${data.month.toString().padLeft(2, '0')}${data.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    return LancamentoContabil(
      numeroLancamento: numeroLancamento,
      dataLancamento: data,
      valorTotal: valor,
      historico: processarHistorico(variaveis),
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      observacoes: observacoes,
      usuarioId: usuarioId,
      templateId: id,
      createdAt: now,
      updatedAt: now,
      partidas: [
        PartidaContabil(
          lancamentoId: 0, // Será definido após salvar o lançamento
          contaId: contaDebitoId,
          tipoMovimento: TipoMovimento.debito,
          valor: valor,
          createdAt: now,
        ),
        PartidaContabil(
          lancamentoId: 0, // Será definido após salvar o lançamento
          contaId: contaCreditoId,
          tipoMovimento: TipoMovimento.credito,
          valor: valor,
          createdAt: now,
        ),
      ],
    );
  }
}

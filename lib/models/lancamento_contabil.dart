// models/lancamento_contabil.dart
import 'package:flutter_dashboard_3/models/partida_contabil.dart';

class LancamentoContabil {
  final int? id;
  final String numeroLancamento;
  final DateTime dataLancamento;
  final double valorTotal;
  final String historico;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? observacoes;
  final int? usuarioId;
  final int? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PartidaContabil>? partidas;

  LancamentoContabil({
    this.id,
    required this.numeroLancamento,
    required this.dataLancamento,
    required this.valorTotal,
    required this.historico,
    this.tipoDocumento,
    this.numeroDocumento,
    this.observacoes,
    this.usuarioId,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
    this.partidas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_lancamento': numeroLancamento,
      'data_lancamento': dataLancamento.toIso8601String(),
      'valor_total': valorTotal,
      'historico': historico,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'observacoes': observacoes,
      'usuario_id': usuarioId,
      'template_id': templateId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LancamentoContabil.fromMap(
    Map<String, dynamic> map, {
    List<PartidaContabil>? partidas,
  }) {
    return LancamentoContabil(
      id: map['id']?.toInt(),
      numeroLancamento: map['numero_lancamento'] ?? '',
      dataLancamento: DateTime.parse(map['data_lancamento']),
      valorTotal: map['valor_total']?.toDouble() ?? 0.0,
      historico: map['historico'] ?? '',
      tipoDocumento: map['tipo_documento'],
      numeroDocumento: map['numero_documento'],
      observacoes: map['observacoes'],
      usuarioId: map['usuario_id']?.toInt(),
      templateId: map['template_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      partidas: partidas,
    );
  }

  LancamentoContabil copyWith({
    int? id,
    String? numeroLancamento,
    DateTime? dataLancamento,
    double? valorTotal,
    String? historico,
    String? tipoDocumento,
    String? numeroDocumento,
    String? observacoes,
    int? usuarioId,
    int? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PartidaContabil>? partidas,
  }) {
    return LancamentoContabil(
      id: id ?? this.id,
      numeroLancamento: numeroLancamento ?? this.numeroLancamento,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      valorTotal: valorTotal ?? this.valorTotal,
      historico: historico ?? this.historico,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      observacoes: observacoes ?? this.observacoes,
      usuarioId: usuarioId ?? this.usuarioId,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      partidas: partidas ?? this.partidas,
    );
  }

  @override
  String toString() {
    return 'LancamentoContabil(id: $id, numero: $numeroLancamento, data: $dataLancamento, valor: $valorTotal, historico: $historico)';
  }

  bool get isBalanceado {
    if (partidas == null || partidas!.length != 2) return false;

    final debito = partidas!.firstWhere(
      (p) => p.tipoMovimento == TipoMovimento.debito,
    );
    final credito = partidas!.firstWhere(
      (p) => p.tipoMovimento == TipoMovimento.credito,
    );

    return debito.valor == credito.valor && debito.valor == valorTotal;
  }
}

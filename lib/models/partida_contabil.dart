// models/partida_contabil.dart
import 'package:flutter_dashboard_3/models/conta_contabil.dart';

enum TipoMovimento {
  debito('DEBITO'),
  credito('CREDITO');

  const TipoMovimento(this.value);
  final String value;

  static TipoMovimento fromString(String value) {
    return TipoMovimento.values.firstWhere((e) => e.value == value);
  }
}

class PartidaContabil {
  final int? id;
  final int lancamentoId;
  final int contaId;
  final TipoMovimento tipoMovimento;
  final double valor;
  final DateTime createdAt;
  final ContaContabil? conta; // Para joins

  PartidaContabil({
    this.id,
    required this.lancamentoId,
    required this.contaId,
    required this.tipoMovimento,
    required this.valor,
    required this.createdAt,
    this.conta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lancamento_id': lancamentoId,
      'conta_id': contaId,
      'tipo_movimento': tipoMovimento.value,
      'valor': valor,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PartidaContabil.fromMap(
    Map<String, dynamic> map, {
    ContaContabil? conta,
  }) {
    return PartidaContabil(
      id: map['id']?.toInt(),
      lancamentoId: map['lancamento_id']?.toInt() ?? 0,
      contaId: map['conta_id']?.toInt() ?? 0,
      tipoMovimento: TipoMovimento.fromString(map['tipo_movimento']),
      valor: map['valor']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      conta: conta,
    );
  }

  PartidaContabil copyWith({
    int? id,
    int? lancamentoId,
    int? contaId,
    TipoMovimento? tipoMovimento,
    double? valor,
    DateTime? createdAt,
    ContaContabil? conta,
  }) {
    return PartidaContabil(
      id: id ?? this.id,
      lancamentoId: lancamentoId ?? this.lancamentoId,
      contaId: contaId ?? this.contaId,
      tipoMovimento: tipoMovimento ?? this.tipoMovimento,
      valor: valor ?? this.valor,
      createdAt: createdAt ?? this.createdAt,
      conta: conta ?? this.conta,
    );
  }

  @override
  String toString() {
    return 'PartidaContabil(id: $id, lancamento: $lancamentoId, conta: $contaId, tipo: $tipoMovimento, valor: $valor)';
  }
}

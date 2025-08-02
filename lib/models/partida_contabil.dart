class PartidaContabil {
  final int? id;
  final int lancamentoId;
  final int contaId;
  final String tipo; // 'DEBITO' ou 'CREDITO'
  final double valor;
  final DateTime dataCriacao;

  PartidaContabil({
    this.id,
    required this.lancamentoId,
    required this.contaId,
    required this.tipo,
    required this.valor,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lancamentoId': lancamentoId,
      'contaId': contaId,
      'tipo': tipo,
      'valor': valor,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory PartidaContabil.fromMap(Map<String, dynamic> map) {
    return PartidaContabil(
      id: map['id'],
      lancamentoId: map['lancamentoId'],
      contaId: map['contaId'],
      tipo: map['tipo'],
      valor: map['valor'],
      dataCriacao: DateTime.parse(map['data_criacao']),
    );
  }

  PartidaContabil copyWith({
    int? id,
    int? lancamentoId,
    int? contaId,
    String? tipo, // 'DEBITO' ou 'CREDITO'
    double? valor,
    DateTime? dataCriacao,
  }) {
    return PartidaContabil(
      id: id ?? this.id,
      lancamentoId: lancamentoId ?? this.lancamentoId,
      contaId: contaId ?? this.contaId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  String toString() {
    return 'PartidaContabil(id: $id, lancamentoId: $lancamentoId, contaID: $contaId, tipo: $tipo, valor: $valor, dataCriacao: $dataCriacao)';
  }
}

class LancamentoContabil {
  final int? id;
  final DateTime data;
  final double valor;
  final String historico;
  final int? usuarioId;
  final int? templateId;
  final DateTime dataCriacao;
  final DateTime? dataAlteracao;

  LancamentoContabil({
    this.id,
    required this.valor,
    required this.historico,
    DateTime? data,
    this.usuarioId,
    this.templateId,
    DateTime? dataCriacao,
    this.dataAlteracao,
  }) : data = data ?? DateTime.now(),
       dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'valor': valor,
      'historico': historico,
      'usuarioId': usuarioId,
      'templateId': templateId,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_alteracao': dataAlteracao?.toIso8601String(),
    };
  }

  factory LancamentoContabil.fromMap(Map<String, dynamic> map) {
    return LancamentoContabil(
      id: map['id'],
      data: map['data'] != null ? DateTime.parse(map['data']) : DateTime.now(),
      valor: map['valor'],
      historico: map['historico'],
      usuarioId: map['usuarioId'],
      templateId: map['templateId'],
      dataCriacao: DateTime.parse(map['data_criacao']),
      dataAlteracao: map['data_alteracao'] != null
          ? DateTime.parse(map['data_alteracao'])
          : null,
    );
  }

  LancamentoContabil copyWith({
    int? id,
    DateTime? data,
    double? valor,
    String? historico,
    int? usuarioId,
    int? templateId,
    DateTime? dataCriacao,
    DateTime? dataAlteracao,
  }) {
    return LancamentoContabil(
      id: id ?? this.id,
      data: data ?? this.data,
      valor: valor ?? this.valor,
      historico: historico ?? this.historico,
      usuarioId: usuarioId ?? this.usuarioId,
      templateId: templateId ?? this.templateId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAlteracao: dataAlteracao ?? this.dataAlteracao,
    );
  }

  @override
  String toString() {
    return 'LancamentoContabil(id: $id, data: $data, valor: $valor, historico: $historico, usuarioId: $usuarioId, templateId: $templateId)';
  }
}

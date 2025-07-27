// models/contribuicao.dart
class Contribuicao {
  final int? id;
  final int membroId;
  final double valor;
  final int mesReferencia; // 1-12
  final int anoReferencia;
  final String status; // pendente, pago, cancelado
  final DateTime dataGeracao;
  final DateTime? dataPagamento;
  final String? observacoes;

  // Dados do membro (para exibição) - não são salvos no banco
  String? membroNome;
  String? membroStatus;

  Contribuicao({
    this.id,
    required this.membroId,
    required this.valor,
    required this.mesReferencia,
    required this.anoReferencia,
    this.status = 'pendente',
    DateTime? dataGeracao,
    this.dataPagamento,
    this.observacoes,
    this.membroNome,
    this.membroStatus,
  }) : dataGeracao = dataGeracao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'membro_id': membroId,
      'valor': valor,
      'mes_referencia': mesReferencia,
      'ano_referencia': anoReferencia,
      'status': status,
      'data_geracao': dataGeracao.millisecondsSinceEpoch,
      'data_pagamento': dataPagamento?.millisecondsSinceEpoch,
      'observacoes': observacoes,
    };
  }

  factory Contribuicao.fromMap(Map<String, dynamic> map) {
    return Contribuicao(
      id: map['id'],
      membroId: map['membro_id'],
      valor: map['valor'].toDouble(),
      mesReferencia: map['mes_referencia'],
      anoReferencia: map['ano_referencia'],
      status: map['status'] ?? 'pendente',
      dataGeracao: DateTime.fromMillisecondsSinceEpoch(map['data_geracao']),
      dataPagamento: map['data_pagamento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_pagamento'])
          : null,
      observacoes: map['observacoes'],
      // Campos do JOIN com tabela membros
      membroNome: map['membro_nome'],
      membroStatus: map['membro_status'],
    );
  }

  Contribuicao copyWith({
    int? id,
    int? membroId,
    double? valor,
    int? mesReferencia,
    int? anoReferencia,
    String? status,
    DateTime? dataGeracao,
    DateTime? dataPagamento,
    String? observacoes,
    String? membroNome,
    String? membroStatus,
  }) {
    return Contribuicao(
      id: id ?? this.id,
      membroId: membroId ?? this.membroId,
      valor: valor ?? this.valor,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      anoReferencia: anoReferencia ?? this.anoReferencia,
      status: status ?? this.status,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      observacoes: observacoes ?? this.observacoes,
      membroNome: membroNome ?? this.membroNome,
      membroStatus: membroStatus ?? this.membroStatus,
    );
  }

  String get mesReferenciaNome {
    const meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mesReferencia];
  }

  String get periodoReferencia => '$mesReferenciaNome/$anoReferencia';

  bool get isPago => status == 'pago';
  bool get isPendente => status == 'pendente';
  bool get isCancelado => status == 'cancelado';

  @override
  String toString() {
    return 'Contribuicao{id: $id, membroId: $membroId, valor: $valor, periodo: $periodoReferencia, status: $status}';
  }
}

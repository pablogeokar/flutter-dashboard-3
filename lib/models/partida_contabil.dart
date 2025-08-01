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

  // toMap, fromMap, copyWith e toString similares aos modelos anteriores
}

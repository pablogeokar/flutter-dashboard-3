class TemplateLancamento {
  final int? id;
  final String nome;
  final String? descricao;
  final int contaDebitoId;
  final int contaCreditoId;
  final String? historicoPadrao;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime? dataAlteracao;

  TemplateLancamento({
    this.id,
    required this.nome,
    this.descricao,
    required this.contaDebitoId,
    required this.contaCreditoId,
    this.historicoPadrao,
    this.ativo = true,
    DateTime? dataCriacao,
    this.dataAlteracao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'conta_debito_id': contaDebitoId,
      'conta_credito_id': contaCreditoId,
      'historico_padrao': historicoPadrao,
      'ativo': ativo ? 1 : 0,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_alteracao': dataAlteracao?.toIso8601String(),
    };
  }

  factory TemplateLancamento.fromMap(Map<String, dynamic> map) {
    return TemplateLancamento(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      contaDebitoId: map['conta_debito_id'],
      contaCreditoId: map['conta_credito_id'],
      historicoPadrao: map['historico_padrao'],
      ativo: map['ativo'] == 1,
      dataCriacao: DateTime.parse(map['data_criacao']),
      dataAlteracao: map['data_alteracao'] != null
          ? DateTime.parse(map['data_alteracao'])
          : null,
    );
  }

  TemplateLancamento copyWith({
    int? id,
    String? nome,
    String? descricao,
    int? contaDebitoId,
    int? contaCreditoId,
    String? historicoPadrao,
    bool? ativo,
    DateTime? dataCriacao,
    DateTime? dataAlteracao,
  }) {
    return TemplateLancamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      contaDebitoId: contaDebitoId ?? this.contaDebitoId,
      contaCreditoId: contaCreditoId ?? this.contaCreditoId,
      historicoPadrao: historicoPadrao ?? this.historicoPadrao,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAlteracao: dataAlteracao ?? this.dataAlteracao,
    );
  }

  // toMap, fromMap, copyWith e toString similares aos modelos anteriores
  // Construtor e métodos similares aos anteriores
}

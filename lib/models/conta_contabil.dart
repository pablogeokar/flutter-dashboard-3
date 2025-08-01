class ContaContabil {
  final int? id;
  final String codigo;
  final String nome;
  final String tipo;
  final bool ativa;
  final DateTime dataCriacao;
  final DateTime? dataAlteracao;

  ContaContabil({
    this.id,
    required this.codigo,
    required this.nome,
    required this.tipo,
    this.ativa = true,
    DateTime? dataCriacao,
    this.dataAlteracao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'tipo': tipo,
      'ativa': ativa ? 1 : 0,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_alteracao': dataAlteracao?.toIso8601String(),
    };
  }

  factory ContaContabil.fromMap(Map<String, dynamic> map) {
    return ContaContabil(
      id: map['id'],
      codigo: map['codigo'],
      nome: map['nome'],
      tipo: map['tipo'],
      ativa: map['ativa'] == 1,
      dataCriacao: DateTime.parse(map['data_criacao']),
      dataAlteracao: map['data_alteracao'] != null
          ? DateTime.parse(map['data_alteracao'])
          : null,
    );
  }

  ContaContabil copyWith({
    int? id,
    String? codigo,
    String? nome,
    String? tipo,
    bool? ativa,
    DateTime? dataCriacao,
    DateTime? dataAlteracao,
  }) {
    return ContaContabil(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      ativa: ativa ?? this.ativa,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAlteracao: dataAlteracao ?? this.dataAlteracao,
    );
  }

  @override
  String toString() {
    return 'ContaContabil(id: $id, codigo: $codigo, nome: $nome, tipo: $tipo, ativa: $ativa)';
  }
}

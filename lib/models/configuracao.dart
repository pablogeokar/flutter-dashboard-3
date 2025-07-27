// models/configuracao.dart
class Configuracao {
  final int? id;
  final String chave;
  final String valor;
  final String? descricao;
  final DateTime dataAtualizacao;

  Configuracao({
    this.id,
    required this.chave,
    required this.valor,
    this.descricao,
    DateTime? dataAtualizacao,
  }) : dataAtualizacao = dataAtualizacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chave': chave,
      'valor': valor,
      'descricao': descricao,
      'data_atualizacao': dataAtualizacao.millisecondsSinceEpoch,
    };
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      id: map['id'],
      chave: map['chave'],
      valor: map['valor'],
      descricao: map['descricao'],
      dataAtualizacao: DateTime.fromMillisecondsSinceEpoch(
        map['data_atualizacao'],
      ),
    );
  }

  Configuracao copyWith({
    int? id,
    String? chave,
    String? valor,
    String? descricao,
    DateTime? dataAtualizacao,
  }) {
    return Configuracao(
      id: id ?? this.id,
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  @override
  String toString() {
    return 'Configuracao{id: $id, chave: $chave, valor: $valor}';
  }
}

class Membro {
  // int? - número inteiro que pode ser nulo (? indica que pode ser null)
  // final - significa que uma vez definido, não pode ser alterado
  final int? id;
  final String nome;
  final String? email;
  final String? telefone;
  final String status; // ativo, inativo, pausado
  final String? observacoes;

  Membro({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.status = 'ativo', // Valor padrão 'ativo'
    required this.observacoes,
  });

  // Método para converter o objeto em Map (necessário para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'status': status,
      'observacoes': observacoes,
    };
  }

  // Método para criar um objeto Membro a partir de um Map (necessário para SQLite)
  factory Membro.fromMap(Map<String, dynamic> map) {
    return Membro(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      telefone: map['telefone'],
      status: map['status'] ?? 'ativo',
      observacoes: map['observacoes'],
    );
  }

  // Método para criar uma cópia do objeto com alguns campos alterados
  Membro copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? status,
    String? observacoes,
  }) {
    return Membro(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  String toString() {
    return 'Membro{id: $id, nome: $nome, status: $status}';
  }
}

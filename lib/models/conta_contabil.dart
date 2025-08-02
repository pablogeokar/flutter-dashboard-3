// models/conta_contabil.dart
enum TipoConta {
  ativo('ATIVO'),
  passivo('PASSIVO'),
  patrimonioSocial('PATRIMONIO_SOCIAL'),
  receita('RECEITA'),
  despesa('DESPESA');

  const TipoConta(this.value);
  final String value;

  static TipoConta fromString(String value) {
    return TipoConta.values.firstWhere((e) => e.value == value);
  }
}

class ContaContabil {
  final int? id;
  final String codigo;
  final String nome;
  final TipoConta tipo;
  final int nivel;
  final int? contaPaiId;
  final bool ativa;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContaContabil({
    this.id,
    required this.codigo,
    required this.nome,
    required this.tipo,
    required this.nivel,
    this.contaPaiId,
    this.ativa = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'tipo': tipo.value,
      'nivel': nivel,
      'conta_pai_id': contaPaiId,
      'ativa': ativa ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ContaContabil.fromMap(Map<String, dynamic> map) {
    return ContaContabil(
      id: map['id']?.toInt(),
      codigo: map['codigo'] ?? '',
      nome: map['nome'] ?? '',
      tipo: TipoConta.fromString(map['tipo']),
      nivel: map['nivel']?.toInt() ?? 0,
      contaPaiId: map['conta_pai_id']?.toInt(),
      ativa: (map['ativa'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  ContaContabil copyWith({
    int? id,
    String? codigo,
    String? nome,
    TipoConta? tipo,
    int? nivel,
    int? contaPaiId,
    bool? ativa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContaContabil(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      contaPaiId: contaPaiId ?? this.contaPaiId,
      ativa: ativa ?? this.ativa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ContaContabil(id: $id, codigo: $codigo, nome: $nome, tipo: $tipo, nivel: $nivel, ativa: $ativa)';
  }

  String get codigoNome => '$codigo - $nome';

  bool get isAnalitica =>
      nivel >= 3; // Contas analíticas são de nível 3 ou superior
  bool get isSintetica =>
      nivel < 3; // Contas sintéticas são de nível menor que 3
}

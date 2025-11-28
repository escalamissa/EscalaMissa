class Parish {
  final String? id;
  final String nome;
  final String? cidade;
  final String? uf;
  final bool isActive;

  Parish({
    this.id,
    required this.nome,
    this.cidade,
    this.uf,
    this.isActive = true,
  });

  Parish copyWith({
    String? id,
    String? nome,
    String? cidade,
    String? uf,
    bool? isActive,
  }) {
    return Parish(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'uf': uf,
      'ativa': isActive,
    };
  }

  factory Parish.fromMap(Map<String, dynamic> map) {
    return Parish(
      id: map['id'],
      nome: map['nome'] ?? '',
      cidade: map['cidade'],
      uf: map['uf'],
      isActive: map['ativa'] ?? true,
    );
  }

  @override
  String toString() {
    return 'Parish(id: $id, nome: $nome, cidade: $cidade, uf: $uf, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Parish &&
        other.id == id &&
        other.nome == nome &&
        other.cidade == cidade &&
        other.uf == uf &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        cidade.hashCode ^
        uf.hashCode ^
        isActive.hashCode;
  }
}

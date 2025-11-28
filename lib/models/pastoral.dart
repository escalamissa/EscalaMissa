import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/models/user_profile.dart';

class Pastoral {
  final String id;
  final String nome;
  final String paroquiaId; // Chave estrangeira
  final Parish? paroquia; // Objeto relacionado
  final String? coordenadorId; // Chave estrangeira
  final UserProfile? coordenador; // Objeto relacionado
  final bool ativa;

  Pastoral({
    required this.id,
    required this.nome,
    required this.paroquiaId,
    this.paroquia,
    this.coordenadorId,
    this.coordenador,
    required this.ativa,
  });

  /// Construtor de fábrica para criar uma instância de [Pastoral] a partir de um mapa (JSON).
  /// Ideal para decodificar a resposta da API do Supabase.
  factory Pastoral.fromMap(Map<String, dynamic> map) {
    return Pastoral(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      paroquiaId: map['paroquia_id'] ?? '',
      ativa: map['ativa'] ?? true,
      coordenadorId: map['coordenador_id'],
      // O Supabase retorna dados relacionados como mapas aninhados se especificado no .select()
      paroquia: map['paroquia'] != null
          ? Parish.fromMap(map['paroquia'])
          : null,
      coordenador: map['coordenador'] != null
          ? UserProfile.fromMap(map['coordenador'])
          : null,
    );
  }

  /// Converte a instância [Pastoral] em um mapa.
  /// Ideal para enviar dados para o Supabase (INSERT ou UPDATE).
  /// Note que apenas os IDs das chaves estrangeiras são enviados.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'paroquia_id': paroquiaId,
      'coordenador_id': coordenadorId,
      'ativa': ativa,
    };
  }

  /// Cria uma cópia da instância de Pastoral com a possibilidade de alterar alguns campos.
  Pastoral copyWith({
    String? id,
    String? nome,
    String? paroquiaId,
    Parish? paroquia,
    String? coordenadorId,
    UserProfile? coordenador,
    bool? ativa,
  }) {
    return Pastoral(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      paroquiaId: paroquiaId ?? this.paroquiaId,
      paroquia: paroquia ?? this.paroquia,
      coordenadorId: coordenadorId ?? this.coordenadorId,
      coordenador: coordenador ?? this.coordenador,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  String toString() {
    return 'Pastoral(id: $id, nome: $nome, paroquiaId: $paroquiaId, paroquia: ${paroquia?.nome}, coordenadorId: $coordenadorId, coordenador: ${coordenador?.nome}, ativa: $ativa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pastoral &&
        other.id == id &&
        other.nome == nome &&
        other.paroquiaId == paroquiaId &&
        other.coordenadorId == coordenadorId &&
        other.ativa == ativa;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        paroquiaId.hashCode ^
        coordenadorId.hashCode ^
        ativa.hashCode;
  }
}

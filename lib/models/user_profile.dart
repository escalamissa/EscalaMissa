class UserProfile {
  final String id;
  final String nome;
  final String? telefone;
  final String perfil;
  final String? paroquiaId;
  final bool ativo;
  final DateTime? criadoEm;

  UserProfile({
    required this.id,
    required this.nome,
    this.telefone,
    required this.perfil,
    this.paroquiaId,
    this.ativo = true,
    this.criadoEm,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      telefone: map['telefone'],
      perfil: map['perfil'] ?? 'fiel',
      paroquiaId: map['paroquia_id'],
      ativo: map['ativo'] ?? true,
      criadoEm: map['criado_em'] == null ? null : DateTime.parse(map['criado_em']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'perfil': perfil,
      'paroquia_id': paroquiaId,
      'ativo': ativo,
      'criado_em': criadoEm?.toIso8601String(),
    };
  }
}
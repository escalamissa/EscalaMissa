enum Perfil {
  admin,
  padre,
  secretario,
  coordenador,
  voluntario,
  fiel,
}

class AppUser {
  final String id;
  final String nome;
  final String? telefone;
  final Perfil perfil;
  final String? paroquiaId;
  final String? fcmToken;

  AppUser({
    required this.id,
    required this.nome,
    this.telefone,
    required this.perfil,
    this.paroquiaId,
    this.fcmToken,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      perfil: Perfil.values.firstWhere((e) => e.toString() == 'Perfil.' + map['perfil']),
      paroquiaId: map['paroquia_id'],
      fcmToken: map['fcm_token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'perfil': perfil.toString().split('.').last,
      'paroquia_id': paroquiaId,
      'fcm_token': fcmToken,
    };
  }
}

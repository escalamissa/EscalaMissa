import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/user_profile.dart';

class Aviso {
  final String? id;
  final String paroquiaId;
  final String? pastoralId;
  final String titulo;
  final String mensagem;
  final String? criadoPor;
  final DateTime? criadoEm;

  final Parish? paroquia;
  final Pastoral? pastoral;
  final UserProfile? autor;

  Aviso({
    this.id,
    required this.paroquiaId,
    this.pastoralId,
    required this.titulo,
    required this.mensagem,
    this.criadoPor,
    this.criadoEm,
    this.paroquia,
    this.pastoral,
    this.autor,
  });

  factory Aviso.fromMap(Map<String, dynamic> map) {
    return Aviso(
      id: map['id'],
      paroquiaId: map['paroquia_id'] ?? '',
      pastoralId: map['pastoral_id'],
      titulo: map['titulo'] ?? '',
      mensagem: map['mensagem'] ?? '',
      criadoPor: map['criado_por'],
      criadoEm: map['criado_em'] == null ? null : DateTime.parse(map['criado_em']),
      paroquia: map.containsKey('paroquias') && map['paroquias'] != null
          ? Parish.fromMap(map['paroquias'])
          : null,
      pastoral: map.containsKey('pastorais') && map['pastorais'] != null
          ? Pastoral.fromMap(map['pastorais'])
          : null,
      autor: map.containsKey('users') && map['users'] != null
          ? UserProfile.fromMap(map['users'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'paroquia_id': paroquiaId,
      'pastoral_id': pastoralId,
      'titulo': titulo,
      'mensagem': mensagem,
      'criado_por': criadoPor,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
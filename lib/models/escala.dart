import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/models/user_profile.dart';

class Escala {
  final String? id;
  final String eventId;
  final String pastoralId;
  final String? functionId; // Made nullable
  final String? volunteerId; // Made nullable
  final String paroquiaId;
  final String status;
  final String? observation;

  final Evento? evento;
  final Pastoral? pastoral;
  final AppFunction? funcao;
  final UserProfile? voluntario;

  Escala({
    this.id,
    required this.eventId,
    required this.pastoralId,
    this.functionId, // Changed to optional
    this.volunteerId, // Changed to optional
    required this.paroquiaId,
    this.status = 'pendente',
    this.observation,
    this.evento,
    this.pastoral,
    this.funcao,
    this.voluntario,
  });

  Escala copyWith({
    String? id,
    String? eventId,
    String? pastoralId,
    String? functionId,
    String? volunteerId,
    String? paroquiaId,
    String? status,
    String? observation,
    Evento? evento,
    Pastoral? pastoral,
    AppFunction? funcao,
    UserProfile? voluntario,
  }) {
    return Escala(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      pastoralId: pastoralId ?? this.pastoralId,
      functionId: functionId ?? this.functionId,
      volunteerId: volunteerId ?? this.volunteerId,
      paroquiaId: paroquiaId ?? this.paroquiaId,
      status: status ?? this.status,
      observation: observation ?? this.observation,
      evento: evento ?? this.evento,
      pastoral: pastoral ?? this.pastoral,
      funcao: funcao ?? this.funcao,
      voluntario: voluntario ?? this.voluntario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventId,
      'pastoral_id': pastoralId,
      'funcao_id': functionId,
      'voluntario_id': volunteerId,
      'paroquia_id': paroquiaId,
      'status': status,
      'observation': observation,
      'evento': evento?.toMap(),
      'pastoral': pastoral?.toMap(),
      'funcao': funcao?.toMap(),
      'voluntario': voluntario?.toMap(),
    };
  }

  factory Escala.fromMap(Map<String, dynamic> map) {
    return Escala(
      id: map['id'],
      eventId: map['event_id'] ?? '',
      pastoralId: map['pastoral_id'] ?? '',
      functionId: map['function_id'] ?? '',
      volunteerId: map['volunteer_id'] ?? '',
      paroquiaId: map['paroquia_id'] ?? '',
      status: map['status'] ?? '',
      observation: map['observation'],
      evento: map['evento'] != null ? Evento.fromMap(map['evento']) : null,
      pastoral: map['pastoral'] != null
          ? Pastoral.fromMap(map['pastoral'])
          : null,
      funcao: map['funcao'] != null
          ? AppFunction.fromMap(map['funcao'])
          : null,
      voluntario: map['voluntario'] != null
          ? UserProfile.fromMap(map['voluntario'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Escala(id: $id, eventId: $eventId, pastoralId: $pastoralId, functionId: $functionId, volunteerId: $volunteerId, paroquiaId: $paroquiaId, status: $status, observation: $observation, evento: $evento, pastoral: $pastoral, funcao: $funcao, voluntario: $voluntario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Escala &&
        other.id == id &&
        other.eventId == eventId &&
        other.pastoralId == pastoralId &&
        other.functionId == functionId &&
        other.volunteerId == volunteerId &&
        other.paroquiaId == paroquiaId &&
        other.status == status &&
        other.observation == observation &&
        other.evento == evento &&
        other.pastoral == pastoral &&
        other.funcao == funcao &&
        other.voluntario == voluntario;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventId.hashCode ^
        pastoralId.hashCode ^
        functionId.hashCode ^
        volunteerId.hashCode ^
        paroquiaId.hashCode ^
        status.hashCode ^
        observation.hashCode ^
        evento.hashCode ^
        pastoral.hashCode ^
        funcao.hashCode ^
        voluntario.hashCode;
  }
}

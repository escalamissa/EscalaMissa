import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/app_function.dart';

class Disponibilidade {
  final String? id;
  final String usuarioId;
  final String? pastoralId;
  final Pastoral? pastoral;
  final String? funcaoId;
  final AppFunction? funcao;
  final String dia; // Armazenado como 'YYYY-MM-DD'
  final String? hora; // Armazenado como 'HH:mm:ss'
  final String? observacao;

  Disponibilidade({
    this.id,
    required this.usuarioId,
    this.pastoralId,
    this.pastoral,
    this.funcaoId,
    this.funcao,
    required this.dia,
    this.hora,
    this.observacao,
  });

  /// Construtor de fábrica para criar uma instância a partir de um mapa (JSON do Supabase).
  factory Disponibilidade.fromMap(Map<String, dynamic> map) {
    return Disponibilidade(
      id: map['id'],
      usuarioId: map['usuario_id'] ?? '',
      pastoralId: map['pastoral_id'],
      funcaoId: map['funcao_id'],
      dia: map['dia'] ?? '',
      hora: map['hora'],
      observacao: map['observacao'],
      // Processa os objetos aninhados que vêm da consulta
      pastoral: map['pastoral'] != null
          ? Pastoral.fromMap(map['pastoral'])
          : null,
      funcao: map['funcao'] != null ? AppFunction.fromMap(map['funcao']) : null,
    );
  }

  /// Cria uma cópia do objeto com a possibilidade de alterar alguns campos.
  Disponibilidade copyWith({
    String? id,
    String? usuarioId,
    String? pastoralId,
    Pastoral? pastoral,
    String? funcaoId,
    AppFunction? funcao,
    String? dia,
    String? hora,
    String? observacao,
  }) {
    return Disponibilidade(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      pastoralId: pastoralId ?? this.pastoralId,
      pastoral: pastoral ?? this.pastoral,
      funcaoId: funcaoId ?? this.funcaoId,
      funcao: funcao ?? this.funcao,
      dia: dia ?? this.dia,
      hora: hora ?? this.hora,
      observacao: observacao ?? this.observacao,
    );
  }

  @override
  String toString() {
    return 'Disponibilidade(id: $id, usuarioId: $usuarioId, pastoralId: $pastoralId, pastoral: ${pastoral?.nome}, funcaoId: $funcaoId, funcao: ${funcao?.name}, dia: $dia, hora: $hora, observacao: $observacao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Disponibilidade &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.pastoralId == pastoralId &&
        other.funcaoId == funcaoId &&
        other.dia == dia &&
        other.hora == hora &&
        other.observacao == observacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        usuarioId.hashCode ^
        pastoralId.hashCode ^
        funcaoId.hashCode ^
        dia.hashCode ^
        hora.hashCode ^
        observacao.hashCode;
  }
}

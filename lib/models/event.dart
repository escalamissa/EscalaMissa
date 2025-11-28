import 'package:escala_missa/models/parish.dart';

class Evento {
  final String id;
  final String paroquiaId;
  final Parish? paroquia;
  final String titulo;
  final String? descricao; // Corrigido de 'description'
  final String data_hora;
  final String? local;
  final String? tempoLiturgico;
  final String? solenidade;

  Evento({
    required this.id,
    required this.paroquiaId,
    this.paroquia,
    required this.titulo,
    this.descricao, // Corrigido
    required this.data_hora,
    this.local,
    this.tempoLiturgico,
    this.solenidade,
  });

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'] ?? '',
      paroquiaId: map['paroquia_id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'], // Corrigido
      data_hora: map['data_hora'] ?? '',
      local: map['local'],
      tempoLiturgico: map['tempo_liturgico'],
      solenidade: map['solenidade'],
      paroquia: map['paroquia'] != null
          ? Parish.fromMap(map['paroquia'])
          : null,
    );
  }

  /// Converte o objeto Evento para um mapa para ser salvo no Supabase.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao, // Corrigido
      'data_hora': data_hora,
      'paroquia_id': paroquiaId,
      'local': local,
      'tempo_liturgico': tempoLiturgico,
      'solenidade': solenidade,
    };
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:escala_missa/models/event.dart'; // Import the Event model

class EventService {
  final _client = Supabase.instance.client;

  Future<List<Evento>> getEvents() async {
    final response = await _client
        .from('eventos')
        .select(
          '*, paroquia_id, paroquias(nome), users(nome)',
        ); // Ensure paroquia_id is selected
    return (response as List).map((e) => Evento.fromMap(e)).toList();
  }

  Future<void> createEvent(
    Evento eventoData, {
    required String paroquiaId,
    required String title,
    required String descricao,
    required String dateTime,
    String? local,
    String? tempoLiturgico,
    String? solenidade,
  }) async {
    await _client.from('eventos').insert({
      'paroquia_id': paroquiaId,
      'titulo': title,
      'descricao': descricao,
      'data_hora': dateTime,
      'local': local,
      'tempo_liturgico': tempoLiturgico,
      'solenidade': solenidade,
    });
  }

  Future<void> updateEvent(
    String id, {
    required String paroquiaId,
    required String title,
    required String descricao,
    required String dateTime,
    String? local,
    String? tempoLiturgico,
    String? solenidade,
  }) async {
    await _client
        .from('eventos')
        .update({
          'paroquia_id': paroquiaId,
          'titulo': title,
          'descricao': descricao,
          'data_hora': dateTime,
          'local': local,
          'tempo_liturgico': tempoLiturgico,
          'solenidade': solenidade,
        })
        .eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('eventos').delete().eq('id', id);
  }
}

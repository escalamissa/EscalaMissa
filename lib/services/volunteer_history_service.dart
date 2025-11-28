
import 'package:supabase_flutter/supabase_flutter.dart';

class VolunteerHistoryService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMyParticipationHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('escalas')
        .select(
            '*, eventos(titulo, data_hora, local), pastorais(nome), funcoes(nome)')
        .eq('voluntario_id', user.id)
        .lt('eventos.data_hora', DateTime.now().toIso8601String())
        .order('eventos(data_hora)', ascending: false);
    return response;
  }
}

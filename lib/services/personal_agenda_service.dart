
import 'package:escala_missa/models/escala.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalAgendaService {
  final _client = Supabase.instance.client;

  Future<List<Escala>> getMyAgenda() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('escalas')
        .select(
            '*, evento:evento_id(*), pastoral:pastoral_id(*), funcao:funcao_id(*), voluntario:voluntario_id(*)')
        .eq('voluntario_id', user.id);

    final escalas = response.map((map) => Escala.fromMap(map)).toList();
    return escalas;
  }
}

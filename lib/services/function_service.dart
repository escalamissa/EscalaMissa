
import 'package:supabase_flutter/supabase_flutter.dart';

class FunctionService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getFunctions() async {
    final response = await _client.from('funcoes').select();
    return response;
  }

  Future<void> createFunction({
    required String nome,
    String? descricao,
  }) async {
    await _client.from('funcoes').insert({
      'nome': nome,
      'descricao': descricao,
    });
  }

  Future<void> updateFunction({
    required String id,
    required String nome,
    String? descricao,
  }) async {
    await _client.from('funcoes').update({
      'nome': nome,
      'descricao': descricao,
    }).eq('id', id);
  }

  Future<void> deleteFunction(String id) async {
    await _client.from('funcoes').delete().eq('id', id);
  }
}

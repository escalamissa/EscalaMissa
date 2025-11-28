
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:escala_missa/models/parish.dart'; // Import the Parish model

class ParishService {
  final _client = Supabase.instance.client;

  Future<List<Parish>> getParishes() async {
    final response = await _client.from('paroquias').select();
    return (response as List).map((e) => Parish.fromMap(e)).toList();
  }

  Future<void> createParish(Parish parish) async {
    await _client.from('paroquias').insert({
      'nome': parish.nome,
      'cidade': parish.cidade,
      'uf': parish.uf,
      'ativa': parish.isActive,
    });
  }

  Future<void> updateParish(Parish parish) async {
    await _client.from('paroquias').update({
      'nome': parish.nome,
      'cidade': parish.cidade,
      'uf': parish.uf,
      'ativa': parish.isActive,
    }).eq('id', parish.id!);
  }

  Future<void> deleteParish(String id) async {
    await _client.from('paroquias').delete().eq('id', id);
  }
}

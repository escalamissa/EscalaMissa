import 'package:escala_missa/models/aviso.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvisoService {
  final _client = Supabase.instance.client;

  Future<List<Aviso>> getAvisos() async {
    final response = await _client.from('avisos').select('*, paroquias(nome), pastorais(nome), users(nome)');
    return (response as List).map((e) => Aviso.fromMap(e)).toList();
  }

  Future<void> createAviso(Aviso aviso) async {
    await _client.from('avisos').insert(aviso.toMap());
  }

  Future<void> updateAviso(Aviso aviso) async {
    await _client.from('avisos').update(aviso.toMap()).eq('id', aviso.id!);
  }

  Future<void> deleteAviso(String id) async {
    await _client.from('avisos').delete().eq('id', id);
  }
}
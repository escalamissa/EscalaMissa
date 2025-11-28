import 'package:escala_missa/models/disponibilidade.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisponibilidadeService {
  final _client = Supabase.instance.client;

  /// Busca as disponibilidades de um usuário específico.
  Future<List<Disponibilidade>> getDisponibilidades({
    required String userId,
  }) async {
    try {
      // A consulta agora usa a sintaxe correta para buscar os dados relacionados.
      final response = await _client
          .from('disponibilidades')
          .select('*, pastoral:pastoral_id(*), funcao:funcao_id(*)')
          .eq('usuario_id', userId)
          .order('dia', ascending: true);

      // CORREÇÃO: Converte a lista de mapas (JSON) em uma lista de objetos Disponibilidade.
      final disponibilidades = response
          .map((map) => Disponibilidade.fromMap(map))
          .toList();
      return disponibilidades;
    } catch (e) {
      print('Erro ao buscar disponibilidades: $e');
      rethrow;
    }
  }

  /// Cria uma nova disponibilidade no banco de dados.
  Future<void> createDisponibilidade({
    required String usuarioId,
    String? pastoralId,
    String? funcaoId,
    required DateTime dia,
    TimeOfDay? hora,
    String? observacao,
  }) async {
    try {
      await _client.from('disponibilidades').insert({
        'usuario_id': usuarioId,
        'pastoral_id': pastoralId,
        'funcao_id': funcaoId,
        'dia': DateFormat('yyyy-MM-dd').format(dia),
        'hora': hora != null
            ? '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00'
            : null,
        'observacao': observacao,
      });
    } catch (e) {
      print('Erro ao criar disponibilidade: $e');
      rethrow;
    }
  }

  /// Deleta uma disponibilidade do banco de dados.
  Future<void> deleteDisponibilidade(String id) async {
    try {
      await _client.from('disponibilidades').delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar disponibilidade: $e');
      rethrow;
    }
  }
}

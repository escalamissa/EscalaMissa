import 'package:escala_missa/models/escala.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



/// Serviço para gerenciar todas as operações relacionadas a Escalas no Supabase.
class EscalaService {
  final _client = Supabase.instance.client;

  EscalaService(); // Modified constructor

  /// Busca todas as escalas e os dados completos dos objetos relacionados.
  Future<List<Escala>> getEscalas() async {
    try {
      // CORREÇÃO: A consulta agora busca todos os dados (*) das tabelas relacionadas,
      // garantindo que todos os campos, incluindo os IDs, estejam disponíveis.
      final response = await _client
          .from('escalas')
          .select(
            '*, evento:evento_id(*), pastoral:pastoral_id(*), funcao:funcao_id(*), voluntario:voluntario_id(*)',
          );

      final escalas = response.map((map) => Escala.fromMap(map)).toList();
      return escalas;
    } catch (e) {
      print('Erro ao buscar escalas: $e');
      rethrow;
    }
  }

  /// Cria uma nova escala no banco de dados.
  Future<void> createEscala(Escala escala) async {
    try {
      final mapToInsert = {
        'evento_id': escala.eventId,
        'pastoral_id': escala.pastoralId,
        'funcao_id': escala.functionId,
        'voluntario_id': escala.volunteerId,
        'paroquia_id': escala.paroquiaId,
        'status': escala.status,
        'observacao': escala.observation,
        'criado_em': null,
      };
      if (escala.id != null) {
        mapToInsert['id'] = escala.id;
      }
      await _client.from('escalas').insert(mapToInsert);

      // Check if the current user is the assigned volunteer
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId != null && escala.volunteerId == currentUserId) {
        // notificationService.showAssignedToScaleNotification(
        //   'Você foi escalado!',
        //   'Você foi escalado para o evento ${escala.evento?.titulo ?? 'sem título'} como ${escala.funcao?.name ?? 'sem função'}.',
        // );
      }
    } catch (e) {
      print('Erro ao criar escala: $e');
      rethrow;
    }
  }

  /// Atualiza uma escala existente no banco de dados.
  Future<void> updateEscala(Escala escala) async {
    try {
      final mapToUpdate = {
        'evento_id': escala.eventId,
        'pastoral_id': escala.pastoralId,
        'funcao_id': escala.functionId,
        'voluntario_id': escala.volunteerId,
        'paroquia_id': escala.paroquiaId,
        'status': escala.status,
        'observacao': escala.observation,
      };
      await _client.from('escalas').update(mapToUpdate).eq('id', escala.id!);

      // Check if the current user is the assigned volunteer
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId != null && escala.volunteerId == currentUserId) {
        // notificationService.showAssignedToScaleNotification(
        //   'Sua escala foi atualizada!',
        //   'Sua escala para o evento ${escala.evento?.titulo ?? 'sem título'} como ${escala.funcao?.name ?? 'sem função'} foi atualizada.',
        // );
      }
    } catch (e) {
      print('Erro ao atualizar escala: $e');
      rethrow;
    }
  }

  /// Atualiza apenas o status de uma escala específica.
  Future<void> updateEscalaStatus({
    required String id,
    required String status,
  }) async {
    try {
      await _client.from('escalas').update({'status': status}).eq('id', id);
    } catch (e) {
      print('Erro ao atualizar status da escala: $e');
      rethrow;
    }
  }

  /// Deleta uma escala do banco de dados usando o ID.
  Future<void> deleteEscala(String id) async {
    try {
      await _client.from('escalas').delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar escala: $e');
      rethrow;
    }
  }
}

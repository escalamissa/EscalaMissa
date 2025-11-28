import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:escala_missa/models/pastoral.dart';

/// Serviço para gerenciar todas as operações relacionadas a Pastorais no Supabase.
class PastoralService {
  final _client = Supabase.instance.client;

  /// Busca todas as pastorais e os dados relacionados da paróquia e do coordenador.
  Future<List<Pastoral>> getPastorais() async {
    try {
      // CORREÇÃO: A consulta agora especifica as colunas das tabelas relacionadas
      // para buscar os nomes da paróquia e do coordenador, em vez de apenas os IDs.
      final response = await _client
          .from('pastorais')
          .select(
            '*, paroquia:paroquia_id(id, nome), coordenador:coordenador_id(id, nome)',
          );

      // Converte a lista de mapas (JSON) em uma lista de objetos Pastoral.
      final pastorals = response.map((map) => Pastoral.fromMap(map)).toList();
      return pastorals;
    } catch (e) {
      print('Erro ao buscar pastorais: $e');
      // Lança o erro novamente para que a UI possa tratá-lo (ex: mostrar um SnackBar).
      rethrow;
    }
  }

  /// Cria uma nova pastoral no banco de dados.
  Future<void> createPastoral(Pastoral pastoral) async {
    try {
      // CORREÇÃO: Os nomes das colunas ('coordenador_id') agora correspondem
      // exatamente ao schema do banco de dados. O campo 'ativa' foi removido.
      await _client.from('pastorais').insert({
        'nome': pastoral.nome,
        'paroquia_id': pastoral.paroquiaId,
        'coordenador_id': pastoral.coordenadorId,
      });
    } catch (e) {
      print('Erro ao criar pastoral: $e');
      rethrow;
    }
  }

  /// Atualiza uma pastoral existente no banco de dados.
  Future<void> updatePastoral(Pastoral pastoral) async {
    try {
      // CORREÇÃO: Os nomes das colunas também foram corrigidos aqui.
      await _client
          .from('pastorais')
          .update({
            'nome': pastoral.nome,
            'paroquia_id': pastoral.paroquiaId,
            'coordenador_id': pastoral.coordenadorId,
          })
          .eq('id', pastoral.id);
    } catch (e) {
      print('Erro ao atualizar pastoral: $e');
      rethrow;
    }
  }

  /// Deleta uma pastoral do banco de dados usando o ID.
  Future<void> deletePastoral(String id) async {
    try {
      await _client.from('pastorais').delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar pastoral: $e');
      rethrow;
    }
  }
}

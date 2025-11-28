import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsService {
  final _client = Supabase.instance.client;

  Future<int> getTotalEvents() async {
    final response = await _client
        .from('eventos')
        .select()
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> getTotalScales() async {
    final response = await _client
        .from('escalas')
        .select()
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> getConfirmedScales() async {
    final response = await _client
        .from('escalas')
        .select()
        .eq('status', 'confirmado')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> getTotalUsers() async {
    final response = await _client
        .from('users')
        .select()
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> getTotalVolunteers() async {
    final response = await _client
        .from('users')
        .select()
        .eq('perfil', 'voluntario')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> getOpenSlots() async {
    final response = await _client
        .from('escalas')
        .select()
        .isFilter('voluntario_id', null)
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  /// Fetches all statistics concurrently for better performance.
  Future<Map<String, int>> getAllStats() async {
    final results = await Future.wait([
      getTotalEvents(),
      getTotalScales(),
      getConfirmedScales(),
      getTotalUsers(),
      getTotalVolunteers(),
      getOpenSlots(),
    ]);

    return {
      'totalEvents': results[0],
      'totalScales': results[1],
      'confirmedScales': results[2],
      'totalUsers': results[3],
      'totalVolunteers': results[4],
      'openSlots': results[5],
    };
  }
}

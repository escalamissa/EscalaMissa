import 'package:escala_missa/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  /// Busca o perfil do usuário atualmente logado.
  Future<UserProfile?> getProfile() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromMap(response);
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  /// FUNÇÃO ADICIONADA: Busca uma lista de perfis de usuário com base nos seus cargos (perfis).
  Future<List<UserProfile>> getProfilesByRoles(List<String> roles) async {
    try {
      // CORREÇÃO: O nome do método para o filtro 'IN' é .in(), e não .in_()
      final response = await _client
          .from('users')
          .select()
          .filter('perfil', 'in', roles);

      final profiles = response
          .map<UserProfile>((item) => UserProfile.fromMap(item))
          .toList();
      return profiles;
    } catch (e) {
      print('Erro ao buscar perfis por cargo: $e');
      return [];
    }
  }
}

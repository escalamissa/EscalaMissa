import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paroquia.dart';
import '../models/app_user.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Paroquia>> getParoquias() async {
    final response = await _supabase.from('paroquias').select();
    final List<dynamic> data = response as List<dynamic>;
    return data.map((map) => Paroquia.fromMap(map)).toList();
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _supabase.from('users').update(user.toMap()).eq('id', user.id);
  }

  Future<AppUser?> getAppUser(String id) async {
    final response = await _supabase.from('users').select().eq('id', id).single();
    if (response.isEmpty) {
      return null;
    }
    return AppUser.fromMap(response);
  }
}

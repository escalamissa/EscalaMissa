import 'package:flutter_dotenv/flutter_dotenv.dart';

final supabaseUrl = dotenv.env['SUPABASE_URL'];
final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

void checkSupabaseCredentials() {
  if (supabaseUrl?.isEmpty ?? true) {
    throw Exception('SUPABASE_URL is not defined in .env file');
  }
  if (supabaseAnonKey?.isEmpty ?? true) {
    throw Exception('SUPABASE_ANON_KEY is not defined in .env file');
  }
}
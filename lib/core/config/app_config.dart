import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const String tafsirTable = 'tafsir';
  static const String tafsirTematikTable = 'tafsir_tematik';
  static const String tafsirTematikAyatTable = 'tafsir_tematik_ayat';
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
  }

  static SupabaseClient get supabase => Supabase.instance.client;
}

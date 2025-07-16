// tafsir_tematik_repository.dart
import 'package:al_quran/core/config/app_config.dart';
import 'package:al_quran/data/models/tafsir/tafsir_tematik.dart';

class TafsirTematikRepository {
  final _supabase = AppConfig.supabase;

  Future<List<TafsirTematik>> getTafsirTematik({required int surahNomor}) async {
    try {
      final response = await _supabase
          .from(AppConfig.tafsirTable)
          .select()
          .filter('kategori', 'eq', 'tematik')
          .filter(
            'surah_nomor',
            'eq',
            surahNomor.toString(),
          )
          .order('ayat', ascending: true);

      if (response.isEmpty) return [];

      return (response as List).map((e) => TafsirTematik.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tafsir tematik: $e');
    }
  }
}
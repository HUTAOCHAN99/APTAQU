// tafsir_tarikh_repository.dart
import 'package:al_quran/core/config/app_config.dart';
import 'package:al_quran/data/models/tafsir/tafsir_tarikh.dart';

class TafsirTarikhRepository {
  final _supabase = AppConfig.supabase;

  Future<List<TafsirTarikh>> getTafsirTarikh({required int surahNomor}) async {
    try {
      final response = await _supabase
          .from(AppConfig.tafsirTable)
          .select()
          .filter('kategori', 'eq', 'tarikh')
          .filter(
            'surah_nomor',
            'eq',
            surahNomor.toString(),
          ) // Konversi ke String
          .order('ayat', ascending: true);

      if (response.isEmpty) return [];

      return (response as List).map((e) => TafsirTarikh.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tafsir tarikh: $e');
    }
  }
}

import 'package:al_quran/core/config/app_config.dart';
import 'package:al_quran/data/models/tafsir/tafsir_ilmi.dart';

class TafsirRepository {
  final _supabase = AppConfig.supabase;

  Future<List<TafsirIlmi>> getTafsirIlmi({required String surahNomor}) async {
    try {
      final response = await _supabase
          .from(AppConfig.tafsirTable)
          .select()
          .filter('kategori', 'eq', 'ilmi')
          .filter('surah_nomor', 'eq', surahNomor)
          .order('ayat', ascending: true); // Tambahkan ascending

      if (response.isEmpty) return [];

      return (response as List).map((e) => TafsirIlmi.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tafsir: $e');
    }
  }
}

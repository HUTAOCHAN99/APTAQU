import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_quran/core/config/app_config.dart';
import 'package:al_quran/data/models/history_model.dart';

class HistoryService {
  final _supabase = AppConfig.supabase;

  Future<List<History>> getHistory(String userId) async {
    try {
      final response = await _supabase
          .from('history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((h) => History.fromJson(h)).toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> addHistory({
    required String userId,
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    int? juzNumber,
  }) async {
    await _supabase.from('history').insert({
      'user_id': userId,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'ayah_number': ayahNumber,
      'ayah_text': ayahText,
      'juz_number': juzNumber,
    });
  }

  Future<void> updateHistory(History history) async {
    try {
      await _supabase
          .from('history')
          .update({
            'surah_number': history.surahNumber,
            'surah_name': history.surahName,
            'ayah_number': history.ayahNumber,
            'ayah_text': history.ayahText,
            'juz_number': history.juzNumber,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', history.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      await _supabase.from('history').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> deleteMultiple(List<String> ids) async {
    try {
      await _supabase.from('history').delete().inFilter('id', ids);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete histories: ${e.message}');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SignLanguageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> getTafsirVideoUrl({
    required int surahNumber,
    required int ayahNumber,
    required TafsirType tafsirType,
  }) async {
    try {
      final typePath = _getTafsirTypePath(tafsirType);
      
      // Coba kedua format penamaan file
      final pathsToTry = [
        '$typePath/surah_$surahNumber/ayah_$ayahNumber.mp4', // Format baru
      ];

      for (final path in pathsToTry) {
        try {
          debugPrint('Mencoba path: $path');
          
          // Coba dapatkan public URL terlebih dahulu
          final publicUrl = _supabase.storage
              .from('quran-videos')
              .getPublicUrl(path);
          
          // Verifikasi file ada
          final response = await http.head(Uri.parse(publicUrl));
          if (response.statusCode == 200) {
            debugPrint('File ditemukan di: $publicUrl');
            return publicUrl;
          }

          // Jika tidak public, coba signed URL
          final signedUrl = await _supabase.storage
              .from('quran-videos')
              .createSignedUrl(path, 3600);
          
          return signedUrl;
        } catch (e) {
          debugPrint('Gagal dengan path $path: ${e.toString()}');
          continue;
        }
      }
      
      debugPrint('File tidak ditemukan di semua path yang dicoba');
      return null;
    } catch (e) {
      debugPrint('Error getting tafsir video: ${e.toString()}');
      return null;
    }
  }

  String _getTafsirTypePath(TafsirType type) {
    return switch (type) {
      TafsirType.bahasa => 'tafsir_bahasa',
      TafsirType.ilmi => 'tafsir_ilmi',
      TafsirType.tarikh => 'tafsir_tarikh',
      TafsirType.tematik => 'tafsir_tematik',
    };
  }
}

enum TafsirType { bahasa, ilmi, tarikh, tematik }
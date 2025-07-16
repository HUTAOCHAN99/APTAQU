import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:al_quran/data/models/juz_model.dart';
import 'package:http/http.dart' as http;
import 'package:al_quran/data/models/ayah_model.dart';
import 'package:al_quran/data/models/surah_model.dart';

class QuranService {
  static const String _baseUrl = 'https://api.quran.gading.dev';
  static const Duration _timeout = Duration(seconds: 15);

  // Method to fetch list of Surahs
  static Future<List<Surah>> fetchSurahList() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/surah'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List).map((s) {
            try {
              return Surah.fromJson(s);
            } catch (e) {
              throw Exception('Failed to parse surah data');
            }
          }).toList();
        }
        throw Exception('Invalid data format: Missing data array');
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Waktu permintaan habis');
    } catch (e) {
      throw Exception('Gagal memuat daftar Surah: $e');
    }
  }

  // Get tafsir for a specific ayah
  static Future<Ayah> fetchTafsir(int surahNumber, int ayahNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/surah/$surahNumber/$ayahNumber'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Ayah.fromJson(data);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Failed to load tafsir: $e');
    }
  }

  static Future<List<Juz>> fetchAllJuz() async {
    try {
      final List<Juz> juzList = [];
     

      for (int i = 1; i <= 30; i++) {
        final response = await http.get(Uri.parse('$_baseUrl/juz/$i'));
        

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          juzList.add(Juz.fromJson(data));
        }
      }

      return juzList;
    } catch (e) {
      throw Exception('Failed to load juz list');
    }
  }

  // Get list of Juz (manually generated since /juz endpoint doesn't exist)
  static Future<List<Juz>> fetchJuzList() async {
    try {
      final List<Juz> juzList = [];

      for (int juzNumber = 1; juzNumber <= 30; juzNumber++) {
        final response = await http.get(
          Uri.parse('$_baseUrl/juz/$juzNumber'),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          juzList.add(Juz.fromJson(data));
        }
      }

      return juzList;
    } catch (e) {
      throw Exception('Gagal memuat daftar Juz: $e');
    }
  }

  static Future<Surah> fetchSurahDetail(int surahNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/surah/$surahNumber'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Surah.fromJson(data);
      } else {
        throw Exception('Failed to load surah: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleError('Failed to load surah detail', e);
    }
  }

  // Get verses in a Juz
  static Future<Map<String, dynamic>> fetchVersesInJuz(int juzNumber) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/juz/$juzNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'verses': (data['data']['verses'] as List)
              .map((ayah) => Ayah.fromJson(ayah))
              .toList(),
          'startInfo': data['data']['juzStartInfo'],
          'endInfo': data['data']['juzEndInfo'],
        };
      }
      throw Exception('Failed to load juz $juzNumber');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchJuzDetails(int juzNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/juz/$juzNumber'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return {
          'verses': (data['verses'] as List)
              .map((ayah) => Ayah.fromJson(ayah))
              .toList(),
          'startInfo': data['juzStartInfo'],
          'endInfo': data['juzEndInfo'],
        };
      } else {
        throw Exception(
          'Failed to load juz $juzNumber: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw _handleError('Failed to load juz details', e);
    }
  }

  // Get verses in a Surah

  static Future<List<Ayah>> fetchVersesInSurah(int surahNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/surah/$surahNumber'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debugging info surah
        if (data['data'] != null) {
        }

        if (data['data'] != null && data['data']['verses'] is List) {
          return (data['data']['verses'] as List)
              .map((ayah) => Ayah.fromJson(ayah))
              .toList();
        }
        throw Exception('Invalid data format');
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Failed to load verses in Surah $surahNumber: $e');
    }
  }

  static Exception _handleError(String message, dynamic error) {
    if (error is SocketException) {
      return Exception('No internet connection');
    } else if (error is TimeoutException) {
      return Exception('Request timed out');
    }
    return Exception('$message: ${error.toString()}');
  }


}

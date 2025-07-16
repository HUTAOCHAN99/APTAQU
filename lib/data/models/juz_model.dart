import 'package:al_quran/data/models/ayah_model.dart';

class Juz {
  final int number;
  final String startInfo;
  final String endInfo;
  final List<Ayah> verses;
  final List<int> surahNumbers; // Tambahkan ini untuk menyimpan nomor surah dalam juz

  Juz({
    required this.number,
    required this.startInfo,
    required this.endInfo,
    required this.verses,
    required this.surahNumbers, // Tambahkan ke constructor
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List).map((v) => Ayah.fromJson(v)).toList();
    
    // Ekstrak nomor surah unik dari verses
    final surahNumbers = verses
        .map((ayah) => ayah.surahNumber)
        .toSet() // Untuk menghapus duplikat
        .toList();

    return Juz(
      number: json['number'] ?? json['juz'] ?? 0,
      startInfo: json['juzStartInfo'] ?? json['start'] ?? '',
      endInfo: json['juzEndInfo'] ?? json['end'] ?? '',
      verses: verses,
      surahNumbers: surahNumbers, // Simpan daftar surah
    );
  }
}
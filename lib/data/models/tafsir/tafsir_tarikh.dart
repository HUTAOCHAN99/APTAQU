// tafsir_tarikh.dart
class TafsirTarikh {
  final String id;
  final String surahNomor;
  final String surahNama;
  final String ayat;
  final String juz;
  final String isi;

  TafsirTarikh({
    required this.id,
    required this.surahNomor,
    required this.surahNama,
    required this.ayat,
    required this.juz,
    required this.isi,
  });

  // tafsir_tarikh.dart
  factory TafsirTarikh.fromMap(Map<String, dynamic> map) {
    return TafsirTarikh(
      id: map['id']?.toString() ?? '',
      surahNomor: map['surah_nomor']?.toString() ?? '', // Pastikan String
      surahNama: map['surah_nama']?.toString() ?? '',
      ayat: map['ayat']?.toString() ?? '',
      juz: map['juz']?.toString() ?? '',
      isi: map['isi']?.toString() ?? '',
    );
  }
}

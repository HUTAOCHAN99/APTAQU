// tafsir_tematik.dart
class TafsirTematik {
  final int id;
  final String kategori;
  final int surahNomor;
  final String surahNama;
  final int ayat;
  final int juz;
  final String isi;

  TafsirTematik({
    required this.id,
    required this.kategori,
    required this.surahNomor,
    required this.surahNama,
    required this.ayat,
    required this.juz,
    required this.isi,
  });

  factory TafsirTematik.fromMap(Map<String, dynamic> map) {
    return TafsirTematik(
      id: map['id'] as int,
      kategori: map['kategori'] as String,
      surahNomor: map['surah_nomor'] as int,
      surahNama: map['surah_nama'] as String,
      ayat: map['ayat'] as int,
      juz: map['juz'] as int,
      isi: map['isi'] as String,
    );
  }
}
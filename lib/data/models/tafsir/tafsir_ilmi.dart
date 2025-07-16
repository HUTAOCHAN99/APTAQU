class TafsirIlmi {
  final String id;
  final String kategori;
  final String surahNomor;
  final String surahNama;
  final int ayat;
  final int juz;
  final String isi;

  TafsirIlmi({
    required this.id,
    required this.kategori,
    required this.surahNomor,
    required this.surahNama,
    required this.ayat,
    required this.juz,
    required this.isi,
  });

  factory TafsirIlmi.fromMap(Map<String, dynamic> map) {
    return TafsirIlmi(
      id: map['id']?.toString() ?? '',
      kategori: map['kategori']?.toString() ?? 'ilmi',
      surahNomor: map['surah_nomor']?.toString() ?? '',
      surahNama: map['surah_nama']?.toString() ?? '',
      ayat: (map['ayat'] is int) ? map['ayat'] : int.tryParse(map['ayat']?.toString() ?? '1') ?? 1,
      juz: (map['juz'] is int) ? map['juz'] : int.tryParse(map['juz']?.toString() ?? '1') ?? 1,
      isi: map['isi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kategori': kategori,
      'surah_nomor': surahNomor,
      'surah_nama': surahNama,
      'ayat': ayat,
      'juz': juz,
      'isi': isi,
    };
  }
}
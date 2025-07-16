class Ayah {
  final int inQuran;
  final int inSurah;
  final String arabic;
  final String transliteration;
  final String translation;
  final String surahName;
  final String surahRevelation;
  final String shortTafsir;
  final String longTafsir;
  final int surahNumber;
  final int numberOfVerses;
  final String audioUrl; // Add this field

  Ayah({
    required this.inQuran,
    required this.inSurah,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.surahName,
    required this.surahRevelation,
    required this.shortTafsir,
    required this.longTafsir,
    required this.surahNumber,
    required this.numberOfVerses,
    required this.audioUrl, // Add to constructor
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      inQuran: json['number']?['inQuran'] ?? 0,
      inSurah: json['number']?['inSurah'] ?? 0,
      arabic: json['text']?['arab'] ?? '',
      transliteration: json['text']?['transliteration']?['en'] ?? '',
      translation: json['translation']?['id'] ?? json['translation']?['en'] ?? '',
      surahName: json['surah']?['name']?['long'] ?? json['surah']?['name']?['short'] ?? '',
      surahRevelation: json['surah']?['revelation']?['id'] ?? json['surah']?['revelation']?['en'] ?? '',
      shortTafsir: json['tafsir']?['id']?['short'] ?? '',
      longTafsir: json['tafsir']?['id']?['long'] ?? '',
      surahNumber: json['surah']?['number'] ?? 0,
      numberOfVerses: json['surah']?['numberOfVerses'] ?? 0,
      audioUrl: json['audio']?['primary'] ?? '', // Add audio URL parsing
    );
  }

  String get shortText {
    return arabic.length > 30 ? '${arabic.substring(0, 30)}...' : arabic;
  }
}
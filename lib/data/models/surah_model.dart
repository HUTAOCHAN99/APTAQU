class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String transliterationId;
  final int numberOfAyahs;
  final String revelationType;
  final int sequence;
  final String audioUrl;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.transliterationId,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.sequence,
    required this.audioUrl,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name']?['long'] ?? json['name']?['short'] ?? '',
      englishName: json['name']?['transliteration']?['en'] ?? '',
      englishNameTranslation: json['name']?['translation']?['en'] ?? '',
      transliterationId:
          json['name']?['transliteration']?['id'] ??
          json['name']?['translation']?['id'] ?? // Fallback ke translation id
          json['name']?['transliteration']?['en'] ??
          '', // Fallback ke english
      numberOfAyahs: json['numberOfVerses'] ?? 0,
      revelationType:
          json['revelation']?['id'] ?? json['revelation']?['en'] ?? '',
      sequence: json['sequence'] ?? 0,
      audioUrl:
          json['audio']?['primary'] ??
          'https://download.quranicaudio.com/quran/mishary_rashid_alafasy/${json['number']}.mp3',
    );
  }
}

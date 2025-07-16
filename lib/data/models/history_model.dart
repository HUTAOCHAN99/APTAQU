class History {
  final String id;
  final String userId;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final int? juzNumber;
  final DateTime createdAt;
  bool isSelected;

  History({
    required this.id,
    required this.userId,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    this.juzNumber,
    required this.createdAt,
    this.isSelected = false,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      userId: json['user_id'],
      surahNumber: json['surah_number'],
      surahName: json['surah_name'],
      ayahNumber: json['ayah_number'],
      ayahText: json['ayah_text'],
      juzNumber: json['juz_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'ayah_number': ayahNumber,
      'ayah_text': ayahText,
      'juz_number': juzNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  History copyWith({
    String? id,
    String? userId,
    int? surahNumber,
    String? surahName,
    int? ayahNumber,
    String? ayahText,
    int? juzNumber,
    DateTime? createdAt,
    bool? isSelected,
  }) {
    return History(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahText: ayahText ?? this.ayahText,
      juzNumber: juzNumber ?? this.juzNumber,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
// Remove UserScoreModel.dart and keep only user_score.dart with this content:
class UserScore {
  final String id;
  final String userId;
  final String userName;
  final String category;
  final int score;
  final DateTime date;

  UserScore({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.score,
    required this.date,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      category: json['category'],
      score: json['score'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'category': category,
      'score': score,
      'date': date.toIso8601String(),
    };
  }
}
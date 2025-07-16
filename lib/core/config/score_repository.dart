import 'dart:convert';

import 'package:al_quran/core/utils/game/shared_prefs.dart';
import 'package:al_quran/data/models/game/user_score.dart';

class ScoreRepository {
  final SharedPrefs _prefs = SharedPrefs();

  Future<void> saveScore(UserScore score) async {
    await _prefs.init();
    final scores = await getScores();
    scores.add(score);
    await _prefs.save('user_scores', scores);
  }

  Future<List<UserScore>> getScores() async {
    await _prefs.init();
    final data = await _prefs.get('user_scores');
    if (data is String) {
      try {
        final list = jsonDecode(data) as List;
        return list.map((json) => UserScore.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // In score_repository.dart
  Future<List<UserScore>> getLeaderboard(String category) async {
    final scores = await getScores();
    return scores.where((score) => score.category == category).toList()
      ..sort((a, b) {
        // First by score descending
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;

        // Then by date ascending (earlier dates first for same score)
        return a.date.compareTo(b.date);
      });
  }
}

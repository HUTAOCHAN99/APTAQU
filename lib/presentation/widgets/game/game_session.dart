import 'package:al_quran/presentation/widgets/game/crossword_template.dart';

class GameSession {
  final List<CrosswordTemplate> templates;
  int currentIndex = 0;
  int score = 0;

  GameSession(this.templates);

  CrosswordTemplate get currentTemplate => templates[currentIndex];

  bool moveToNext() {
    if (currentIndex < templates.length - 1) {
      currentIndex++;
      return true;
    }
    return false;
  }

  void addScore(int points) {
    score += points;
  }
}
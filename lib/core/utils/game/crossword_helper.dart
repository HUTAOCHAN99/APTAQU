import 'package:al_quran/core/constant/constants.dart';
import 'package:al_quran/data/models/game/clue.dart';

List<List<bool>> generateWhiteGrid(List<Clue> across, List<Clue> down) {
  final grid = List.generate(
    CrosswordConstants.defaultGridSize, 
    (_) => List.filled(CrosswordConstants.defaultGridSize, false)
  );
  
  void process(List<Clue> clues, bool isAcross) {
    for (var c in clues) {
      for (int i = 0; i < c.answer.length; i++) {
        if (isAcross && c.col + i < CrosswordConstants.defaultGridSize) {
          grid[c.row][c.col + i] = true;
        }
        if (!isAcross && c.row + i < CrosswordConstants.defaultGridSize) {
          grid[c.row + i][c.col] = true;
        }
      }
    }
  }
  
  process(across, true);
  process(down, false);
  return grid;
}
import 'package:al_quran/data/models/game/clue.dart';

class CrosswordTemplate {
  final List<String> layout;
  final int rows;
  final int cols;
  final String? name;
  final int? difficulty;
  final List<Clue> acrossClues;
  final List<Clue> downClues;

  CrosswordTemplate({
    required this.layout,
    required this.rows,
    required this.cols,
    this.name,
    this.difficulty,
    required this.acrossClues,
    required this.downClues,
  }) : assert(
         layout.length == rows * cols,
         'Layout length must match rows x cols',
       );

  List<List<bool>> generateGrid() {
    final grid = List.generate(rows, (_) => List.filled(cols, false));

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final index = row * cols + col;
        grid[row][col] = layout[index] == '1';
      }
    }

    return grid;
  }
}

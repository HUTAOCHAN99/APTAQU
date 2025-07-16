class Clue {
  final int number;
  final String clue;
  final String answer;
  final int row;
  final int col;

  Clue({
    required this.number,
    required this.clue,
    required this.answer,
    required this.row,
    required this.col,
  });

  @override
  String toString() {
    return 'Clue(number: $number, clue: $clue, answer: $answer, row: $row, col: $col)';
  }
}
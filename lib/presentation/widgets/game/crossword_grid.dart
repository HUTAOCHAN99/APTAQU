import 'package:flutter/material.dart';
import 'package:al_quran/core/config/crosssword_config.dart';
import 'package:al_quran/core/constant/crossword_theme.dart';

class CrosswordGrid extends StatelessWidget {
  final List<List<bool>> isWhite;
  final List<List<String>> letters;
  final List<List<int?>> numbers;
  final Function(int row, int col, String value) onChanged;
  final List<List<FocusNode>> focusNodes;
  final CrosswordTheme theme;
  final int? activeRow;
  final int? activeCol;
  final double cellSize;
  final CrosswordConfig config;

  const CrosswordGrid({
    super.key,
    required this.isWhite,
    required this.letters,
    required this.numbers,
    required this.onChanged,
    required this.focusNodes,
    this.theme = const CrosswordTheme(),
    this.activeRow,
    this.activeCol,
    required this.cellSize,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.gridLinesColor,
          width: theme.borderWidth,
        ),
      ),
      child: Column(
        children: List.generate(isWhite.length, (row) {
          return Row(
            children: List.generate(isWhite[row].length, (col) {
              return SizedBox(
                // Replaced Container with SizedBox
                width: cellSize - theme.borderWidth,
                height: cellSize - theme.borderWidth,
                child: _buildCell(row, col),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final isActive = activeRow == row && activeCol == col;
    final hasNumber = numbers[row][col] != null;

    return GestureDetector(
      onTap: () => focusNodes[row][col].requestFocus(),
      child: DecoratedBox(
        // Using DecoratedBox instead of Container for decoration
        decoration: BoxDecoration(
          color: _getCellColor(row, col, isActive),
          border: _getCellBorder(row, col, isActive),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (hasNumber)
              Positioned(
                top: 4,
                left: 4,
                child: Text(
                  '${numbers[row][col]}',
                  style: TextStyle(
                    fontSize: cellSize * 0.18,
                    color: theme.clueNumberColor,
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(theme.borderWidth),
                child: TextField(
                  focusNode: focusNodes[row][col],
                  controller: TextEditingController(text: letters[row][col]),
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: cellSize * 0.45,
                    fontWeight: FontWeight.bold,
                    color: theme.inputTextColor,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) => onChanged(row, col, value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor(int row, int col, bool isActive) {
    if (!isWhite[row][col]) return theme.inactiveCellColor;
    return isActive ? theme.cellHighlightColor : theme.activeCellColor;
  }

  Border? _getCellBorder(int row, int col, bool isActive) {
    if (!isWhite[row][col]) return null;
    return isActive ? Border.all(color: Colors.blue, width: 1.5) : null;
  }
}

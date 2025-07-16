import 'package:al_quran/presentation/screens/game/crossword_screen.dart';
import 'package:al_quran/presentation/widgets/game/crossword_template.dart';
import 'package:flutter/material.dart';

class TemplateEditor extends StatefulWidget {
  const TemplateEditor({super.key});

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  final int rows = 3;
  final int cols = 3;
  late List<List<bool>> cells;

  @override
  void initState() {
    super.initState();
    cells = List.generate(rows, (_) => List.filled(cols, true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor Template')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final row = index ~/ cols;
          final col = index % cols;
          return GestureDetector(
            onTap: () {
              setState(() {
                cells[row][col] = !cells[row][col];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: cells[row][col] ? Colors.white : Colors.black,
                border: Border.all(color: Colors.grey),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final layout = cells
              .expand((row) => row.map((cell) => cell ? '1' : '0'))
              .toList();
          final template = CrosswordTemplate(
            rows: rows,
            cols: cols,
            layout: layout,
            acrossClues: [], // Add clues to the template instead
            downClues: [], // Add clues to the template instead
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrosswordScreen(
                template: template, // Only pass template
              ),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

import 'package:al_quran/presentation/widgets/game/crossword_template.dart';
import 'package:al_quran/presentation/widgets/game/crossword_template_manager.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/presentation/screens/game/crossword_screen.dart';

class CrosswordGameScreen extends StatelessWidget {
  final List<CrosswordTemplate> randomTemplates;

  CrosswordGameScreen({super.key})
    : randomTemplates = CrosswordTemplateManager.getRandomTemplates(5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle Acak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pilih Puzzle:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: randomTemplates.length,
                itemBuilder: (context, index) {
                  final template = randomTemplates[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(template.name ?? 'Puzzle ${index + 1}'),
                      subtitle: Text(
                        '${template.rows}x${template.cols} - ${_getDifficultyText(template.difficulty)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CrosswordScreen(
                              template:
                                  template, // Properly passing the template
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyText(int? difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }
}

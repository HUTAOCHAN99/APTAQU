import 'package:flutter/material.dart';
import 'package:al_quran/data/models/game/clue.dart';

class ClueSection extends StatelessWidget {
  final String title;
  final List<Clue> clues;
  final Function(Clue, bool) onClueSelected;

  const ClueSection({
    super.key,
    required this.title,
    required this.clues,
    required this.onClueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clues.length,
            itemBuilder: (context, index) {
              final clue = clues[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () => onClueSelected(clue, title == 'Across'),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${index + 1}. ', // Gunakan index + 1 sebagai nomor
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: clue.clue),
                        TextSpan(
                          text: ' (${clue.answer.length})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

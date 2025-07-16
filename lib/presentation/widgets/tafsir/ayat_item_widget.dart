import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/audio_provider.dart';
import 'package:al_quran/data/models/ayah_model.dart';

class AyahItemWidget extends StatelessWidget {
  final Ayah ayah;
  final bool showTafsirButton;

  const AyahItemWidget({
    super.key,
    required this.ayah,
    this.showTafsirButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final isCurrentAyah =
        audioProvider.currentSurah == ayah.surahNumber &&
        audioProvider.currentAyah == ayah.inSurah;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isCurrentAyah && audioProvider.isPlaying) {
            audioProvider.pause(); // Now this will work
          } else {
            audioProvider.playAyah(ayah.surahNumber, ayah.inSurah);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrentAyah ? Colors.green : Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${ayah.inSurah}',
                      style: TextStyle(
                        color: isCurrentAyah ? Colors.white : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isCurrentAyah && audioProvider.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: isCurrentAyah ? Colors.green : null,
                        ),
                        onPressed: () {
                          if (isCurrentAyah && audioProvider.isPlaying) {
                            audioProvider.pause();
                          } else {
                            audioProvider.playAyah(
                              ayah.surahNumber,
                              ayah.inSurah,
                            );
                          }
                        },
                      ),
                      if (showTafsirButton)
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            // Navigate to tafsir screen
                          },
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ayah.arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'UthmanicHafs',
                ),
              ),
              const SizedBox(height: 16),
              Text(ayah.translation, style: const TextStyle(fontSize: 16)),
              if (ayah.shortTafsir.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Tafsir: ${ayah.shortTafsir}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

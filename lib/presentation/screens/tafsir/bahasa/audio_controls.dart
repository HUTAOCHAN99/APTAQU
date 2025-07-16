// audio_controls.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/audio_provider.dart';

class AudioControls extends StatelessWidget {
  const AudioControls({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return StreamBuilder<PlayerState>(
      stream: audioProvider.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing ?? false;

        if (!audioProvider.hasActiveAudio) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(audioProvider.currentSurah),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNowPlayingInfo(context, audioProvider),
                const SizedBox(height: 8),
                _buildPlayerControls(audioProvider, playing, processingState),
                const SizedBox(height: 8),
                _buildProgressBar(audioProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNowPlayingInfo(
    BuildContext context,
    AudioProvider audioProvider,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${audioProvider.currentAyah}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                audioProvider.currentJuz != null
                    ? 'Juz ${audioProvider.currentJuz}'
                    : 'Surah ${audioProvider.currentSurah}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Ayah ${audioProvider.currentAyah}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: audioProvider.stop,
        ),
      ],
    );
  }

  Widget _buildPlayerControls(
    AudioProvider audioProvider,
    bool playing,
    ProcessingState? processingState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          onPressed: audioProvider.playPrevious,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            processingState == ProcessingState.loading
                ? Icons.circle
                : playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            size: 48,
            color: Colors.green,
          ),
          onPressed: audioProvider.togglePlayPause,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          onPressed: audioProvider.playNext,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildProgressBar(AudioProvider audioProvider) {
    return StreamBuilder<Duration?>(
      stream: audioProvider.player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: audioProvider.player.positionStream,
          builder: (context, positionSnapshot) {
            var position = positionSnapshot.data ?? Duration.zero;
            if (position > duration) position = duration;

            return Column(
              children: [
                Slider(
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  value: position.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    audioProvider.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

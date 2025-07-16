// audio_provider.dart
import 'package:al_quran/data/models/ayah_model.dart';
import 'package:flutter/foundation.dart';
import 'package:al_quran/core/api/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider with ChangeNotifier {
  final AudioService _audioService;

  AudioProvider(this._audioService) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _audioService.init();
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  bool get isPlaying => _audioService.isPlaying;
  int? get currentSurah => _audioService.currentSurah;
  int? get currentAyah => _audioService.currentAyah;
  int? get currentJuz => _audioService.currentJuz;
  List<Ayah> get playlist => _audioService.playlist;
  AudioPlayer get player => _audioService.player;
  bool get hasActiveAudio => _audioService.hasActiveAudio;

  Future<void> playAyah(int surah, int ayah) async {
    try {
      await _audioService.playAyah(surah, ayah);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playSurah(int surah) async {
    try {
      await _audioService.playSurah(surah);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playJuz(int juz) async {
    try {
      await _audioService.playJuz(juz);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    await _audioService.playNext();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioService.stop();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    notifyListeners();
  }
}

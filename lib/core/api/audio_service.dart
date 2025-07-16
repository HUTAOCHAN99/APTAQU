// audio_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:al_quran/core/api/quran_service.dart';
import 'package:al_quran/data/models/ayah_model.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  List<Ayah> _playlist = [];
  int _currentIndex = 0;
  int? _currentSurah;
  int? _currentAyah;
  int? _currentJuz;
  bool _isPlaying = false;
  bool _isInitialized = false;

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  int? get currentSurah => _currentSurah;
  int? get currentAyah => _currentAyah;
  int? get currentJuz => _currentJuz;
  List<Ayah> get playlist => _playlist;
  bool get hasActiveAudio => _currentSurah != null && _currentAyah != null;

  Future<void> init() async {
    if (_isInitialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    session.interruptionEventStream.listen((event) {
      if (event.begin) pause();
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (error) {
        // Handle audio player errors
      },
    );

    _isInitialized = true;
  }

  Future<void> playAyah(int surah, int ayah) async {
    try {
      final verses = await QuranService.fetchVersesInSurah(surah);
      final targetAyah = verses.firstWhere((a) => a.inSurah == ayah);

      if (targetAyah.audioUrl.isEmpty) {
        throw Exception('Audio URL not available for this ayah');
      }

      await _player.stop();
      await _player.setUrl(targetAyah.audioUrl);
      await _player.play();

      _currentSurah = surah;
      _currentAyah = ayah;
      _currentJuz = null;
      _currentIndex = ayah - 1;
      _isPlaying = true;
      _playlist = verses;
      _setupListeners();
    } catch (e) {
      throw Exception('Failed to play ayah: $e');
    }
  }

  Future<void> playSurah(int surah) async {
    try {
      _playlist = await QuranService.fetchVersesInSurah(surah);
      _playlist = _playlist.where((ayah) => ayah.audioUrl.isNotEmpty).toList();

      if (_playlist.isEmpty) {
        throw Exception('No audio available for this surah');
      }

      _currentSurah = surah;
      _currentAyah = 1;
      _currentJuz = null;
      await _playFromStart();
    } catch (e) {
      throw Exception('Failed to play surah: $e');
    }
  }

  Future<void> playJuz(int juz) async {
    try {
      final juzData = await QuranService.fetchJuzDetails(juz);
      _playlist = (juzData['verses'] as List<Ayah>)
          .where((ayah) => ayah.audioUrl.isNotEmpty)
          .toList();

      if (_playlist.isEmpty) {
        throw Exception('No audio available for this juz');
      }

      _currentJuz = juz;
      _currentSurah = _playlist.first.surahNumber;
      _currentAyah = _playlist.first.inSurah;
      await _playFromStart();
    } catch (e) {
      throw Exception('Failed to play juz: $e');
    }
  }

  Future<void> _playFromStart() async {
    if (_playlist.isEmpty) return;

    _currentIndex = 0;
    _isPlaying = true;
    await _player.stop();
    await _player.setUrl(_playlist[_currentIndex].audioUrl);
    await _player.play();
    _setupListeners();
  }

  void _setupListeners() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> _playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentSurah = _playlist[_currentIndex].surahNumber;
      _currentAyah = _playlist[_currentIndex].inSurah;
      await _player.setUrl(_playlist[_currentIndex].audioUrl);
      await _player.play();
      _isPlaying = true;
    } else {
      await stop();
    }
  }

  Future<void> playNext() async {
    await _playNext();
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSurah = _playlist[_currentIndex].surahNumber;
      _currentAyah = _playlist[_currentIndex].inSurah;
      await _player.setUrl(_playlist[_currentIndex].audioUrl);
      await _player.play();
      _isPlaying = true;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _player.play();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentIndex = 0;
    _currentSurah = null;
    _currentAyah = null;
    _currentJuz = null;
    _playlist = [];
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}

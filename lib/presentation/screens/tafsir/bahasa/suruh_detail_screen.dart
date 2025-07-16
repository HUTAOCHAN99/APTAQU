import 'package:al_quran/core/provider/audio_provider.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/sign_language_screen.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/core/api/quran_service.dart';
import 'package:al_quran/data/models/ayah_model.dart';
import 'package:al_quran/data/models/surah_model.dart';
import 'package:al_quran/core/api/history_service.dart';
import 'package:al_quran/core/services/auth_service.dart';
import 'package:provider/provider.dart';

enum ContentMode { translation, tafsir }

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyah;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onGoToAyah;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah,
    this.onPlayAudio,
    this.onGoToAyah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late final Future<List<Ayah>> _futureVerses;
  late final Future<Surah> _futureSurah;
  late final ScrollController _scrollController;
  bool _isLoading = true;
  String _errorMessage = '';
  final ValueNotifier<int?> _highlightedAyah = ValueNotifier(null);
  final AuthService _authService = AuthService();
  final HistoryService _historyService = HistoryService();
  ContentMode _contentMode = ContentMode.translation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadData();

    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToAyah(widget.initialAyah!);
          _highlightedAyah.value = widget.initialAyah;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _highlightedAyah.value = null;
            }
          });
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _futureSurah = QuranService.fetchSurahDetail(widget.surahNumber);
      _futureVerses = QuranService.fetchVersesInSurah(widget.surahNumber);

      await _futureSurah;
      await _futureVerses;

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final verseIndex = ayahNumber - 1;
    final itemHeight = 180.0;
    final scrollOffset = verseIndex * itemHeight;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final adjustedOffset = scrollOffset.clamp(0.0, maxScroll);

    if (mounted) {
      _scrollController.animateTo(
        adjustedOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildContentToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _contentMode == ContentMode.translation
                    ? Colors.green
                    : Colors.grey[300],
                foregroundColor: _contentMode == ContentMode.translation
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () =>
                  setState(() => _contentMode = ContentMode.translation),
              child: const Text('Terjemahan'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _contentMode == ContentMode.tafsir
                    ? Colors.green
                    : Colors.grey[300],
                foregroundColor: _contentMode == ContentMode.tafsir
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () =>
                  setState(() => _contentMode = ContentMode.tafsir),
              child: const Text('Tafsir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahItem(Ayah ayah, int index) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final isCurrentAyah =
        audioProvider.currentSurah == widget.surahNumber &&
        audioProvider.currentAyah == ayah.inSurah;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isCurrentAyah ? Colors.green[50] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isCurrentAyah && audioProvider.isPlaying) {
            audioProvider.pause();
          } else {
            audioProvider.playAyah(widget.surahNumber, ayah.inSurah);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sign_language),
                        onPressed: () => _navigateToSignLanguage(ayah.inSurah),
                        tooltip: 'Bahasa Isyarat',
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isCurrentAyah
                              ? Colors.green
                              : Colors.green[100],
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
                    ],
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
                              widget.surahNumber,
                              ayah.inSurah,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add),
                        onPressed: () => _saveHistory(ayah),
                        tooltip: 'Simpan ke Riwayat',
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
              if (_contentMode == ContentMode.translation)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ayah.translation,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              if (_contentMode == ContentMode.tafsir)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tafsir:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ayah.shortTafsir.isNotEmpty
                          ? ayah.shortTafsir
                          : 'Tafsir tidak tersedia',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSignLanguage(int ayahNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignLanguageScreen(
          surahNumber: widget.surahNumber,
          ayahNumber: ayahNumber,
        ),
      ),
    );
  }

  Widget _buildSurahHeader(Surah surah) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            surah.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'UthmanicHafs',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            surah.transliterationId,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                label: Text(
                  surah.revelationType,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
              Chip(
                label: Text(
                  '${surah.numberOfAyahs} Ayat',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveHistory(Ayah ayah) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harap login untuk menyimpan riwayat'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await _historyService.addHistory(
        userId: user.id,
        surahNumber: widget.surahNumber,
        surahName: ayah.surahName,
        ayahNumber: ayah.inSurah,
        ayahText: ayah.shortText,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ayat ${ayah.inSurah} disimpan ke riwayat'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    return Scaffold(
      // In SurahDetailScreen's build method
      appBar: AppBar(
        title: Text('Surah ${widget.surahNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              final audioProvider = Provider.of<AudioProvider>(
                context,
                listen: false,
              );
              audioProvider.playSurah(widget.surahNumber);
            },
            tooltip: 'Putar seluruh Surah',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: widget.onGoToAyah,
            tooltip: 'Pergi ke Ayat',
          ),
          if (widget.initialAyah != null)
            IconButton(
              icon: const Icon(Icons.center_focus_weak),
              onPressed: () {
                if (mounted) {
                  _scrollToAyah(widget.initialAyah!);
                  _highlightedAyah.value = widget.initialAyah;
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      _highlightedAyah.value = null;
                    }
                  });
                }
              },
              tooltip: 'Scroll to highlighted ayah',
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          _buildContentToggle(),
          Expanded(
            child: FutureBuilder<Surah>(
              future: _futureSurah,
              builder: (context, surahSnapshot) {
                if (!surahSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final surah = surahSnapshot.data!;

                return FutureBuilder<List<Ayah>>(
                  future: _futureVerses,
                  builder: (context, versesSnapshot) {
                    if (versesSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${versesSnapshot.error}'),
                      );
                    }

                    if (!versesSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final verses = versesSnapshot.data!;

                    return ListView(
                      controller: _scrollController,
                      children: [
                        _buildSurahHeader(surah),
                        ...List.generate(verses.length, (index) {
                          return _buildAyahItem(verses[index], index);
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _highlightedAyah.dispose();
    super.dispose();
  }
}

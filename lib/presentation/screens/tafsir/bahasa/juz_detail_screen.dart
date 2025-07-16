import 'dart:convert';
import 'package:al_quran/presentation/screens/tafsir/bahasa/audio_controls.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/sign_language_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/audio_provider.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/tafsir_screen.dart';
import 'package:al_quran/data/models/ayah_model.dart';
import 'package:al_quran/data/models/surah_model.dart';
import 'package:al_quran/data/models/juz_ranges.dart';
import 'package:al_quran/core/api/history_service.dart';
import 'package:al_quran/core/services/auth_service.dart';

enum ContentMode { translation, tafsir }

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  final int? highlightSurah;
  final int? highlightAyah;

  const JuzDetailScreen({
    super.key,
    required this.juzNumber,
    this.highlightSurah,
    this.highlightAyah,
  });

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  final Map<int, List<Ayah>> _surahVersesCache = {};
  final Map<int, Surah> _surahCache = {};
  String _errorMessage = '';
  bool _isLoading = true;
  late final Map<String, dynamic> _juzRange;
  late final ScrollController _scrollController;
  final ValueNotifier<int?> _highlightedAyah = ValueNotifier(null);
  final ValueNotifier<int?> _highlightedSurah = ValueNotifier(null);
  final AuthService _authService = AuthService();
  final HistoryService _historyService = HistoryService();
  ContentMode _contentMode = ContentMode.translation;

  @override
  void initState() {
    super.initState();
    _juzRange = juzRanges[widget.juzNumber]!;
    _scrollController = ScrollController();
    _loadJuzData();

    if (widget.highlightSurah != null && widget.highlightAyah != null) {
      _highlightedSurah.value = widget.highlightSurah;
      _highlightedAyah.value = widget.highlightAyah;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted)
              _scrollToAyah(widget.highlightSurah!, widget.highlightAyah!);
          });
        }
      });
    }
  }

  void _scrollToAyah(int surahNumber, int ayahNumber) {
    if (!_surahVersesCache.containsKey(surahNumber)) return;

    final surahIndex = _juzRange['surahs'].indexOf(surahNumber);
    if (surahIndex == -1) return;

    double position = 0.0;
    for (int i = 0; i < surahIndex; i++) {
      final prevSurah = _juzRange['surahs'][i];
      final verses = _surahVersesCache[prevSurah] ?? [];
      position += 80.0 + verses.length * 180.0;
    }

    final verses = _surahVersesCache[surahNumber] ?? [];
    final ayahIndex = verses.indexWhere((a) => a.inSurah == ayahNumber);
    if (ayahIndex != -1) {
      position += 80.0 + ayahIndex * 180.0;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final adjustedOffset = position.clamp(0.0, maxScroll);

    if (mounted) {
      _scrollController.animateTo(
        adjustedOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadJuzData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      for (int surahNumber in _juzRange['surahs']) {
        final verses = await _fetchVersesInSurah(surahNumber);
        if (!mounted) return;
        setState(() => _surahVersesCache[surahNumber] = verses);
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Ayah>> _fetchVersesInSurah(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/surah/$surahNumber'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final allVerses = (data['verses'] as List)
            .map((v) => Ayah.fromJson(v))
            .toList();

        final startAyah = _getStartAyahForSurah(surahNumber);
        final endAyah = _getEndAyahForSurah(surahNumber);

        return allVerses
            .where(
              (ayah) => ayah.inSurah >= startAyah && ayah.inSurah <= endAyah,
            )
            .toList();
      }
      throw Exception('Failed to load surah $surahNumber');
    } catch (e) {
      throw Exception('Error loading surah $surahNumber: $e');
    }
  }

  int _getStartAyahForSurah(int surahNumber) {
    final start = _juzRange['start'];
    return surahNumber == start['surah'] ? start['ayah'] : 1;
  }

  int _getEndAyahForSurah(int surahNumber) {
    final end = _juzRange['end'];
    if (surahNumber == end['surah']) return end['ayah'];

    final nextJuzNumber = widget.juzNumber + 1;
    if (nextJuzNumber <= 30) {
      final nextJuzRange = juzRanges[nextJuzNumber];
      if (nextJuzRange != null &&
          nextJuzRange['start']['surah'] == surahNumber) {
        return nextJuzRange['start']['ayah'] - 1;
      }
    }
    return 999;
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

  Widget _buildAyahContent(Ayah ayah) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ayah.arabic,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 22, fontFamily: 'UthmanicHafs'),
        ),
        const SizedBox(height: 16),
        if (_contentMode == ContentMode.translation)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(ayah.translation, style: const TextStyle(fontSize: 16)),
          )
        else if (_contentMode == ContentMode.tafsir)
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
    );
  }

 Widget _buildAyahItem(Ayah ayah, int surahNumber, int index) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final isCurrentAyah =
        audioProvider.currentSurah == surahNumber &&
        audioProvider.currentAyah == ayah.inSurah;

    return ValueListenableBuilder<int?>(
      valueListenable: _highlightedAyah,
      builder: (context, highlightedAyah, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color:
              highlightedAyah == ayah.inSurah &&
                  _highlightedSurah.value == surahNumber
              ? Colors.green[50]
              : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isCurrentAyah && audioProvider.isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.playAyah(surahNumber, ayah.inSurah);
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
                            onPressed: () => _navigateToSignLanguage(surahNumber, ayah.inSurah),
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
                                  surahNumber,
                                  ayah.inSurah,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.bookmark_add),
                            onPressed: () => _saveHistory(ayah, surahNumber),
                            tooltip: 'Simpan ke Riwayat',
                          ),
                          if (_contentMode != ContentMode.tafsir)
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TafsirScreen(
                                      surahNumber: surahNumber,
                                      ayahNumber: ayah.inSurah,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'Lihat Tafsir Lengkap',
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAyahContent(ayah),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToSignLanguage(int surahNumber, int ayahNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignLanguageScreen(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      ),
    );
  }

  Future<Surah?> _fetchSurahDetail(int surahNumber) async {
    if (_surahCache.containsKey(surahNumber)) return _surahCache[surahNumber];

    try {
      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/surah/$surahNumber'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final surah = Surah.fromJson(data);
        _surahCache[surahNumber] = surah;
        return surah;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching surah detail: $e');
      return null;
    }
  }

  Widget _buildSurahHeader(Surah surah) {
    return ValueListenableBuilder<int?>(
      valueListenable: _highlightedSurah,
      builder: (context, highlightedSurah, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: highlightedSurah == surah.number
                ? Colors.green[50]
                : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.name, // Nama Arab
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'UthmanicHafs',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          surah.transliterationId.isNotEmpty
                              ? surah.transliterationId
                              : surah
                                    .englishName, // Transliterasi Indonesia atau fallback ke English
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      surah.revelationType == 'Meccan'
                          ? 'Makkiyah'
                          : 'Madaniyah',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  const SizedBox(width: 8),
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
      },
    );
  }

  Future<void> _saveHistory(Ayah ayah, int surahNumber) async {
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
        surahNumber: surahNumber,
        surahName: ayah.surahName,
        ayahNumber: ayah.inSurah,
        ayahText: ayah.shortText,
        juzNumber: widget.juzNumber,
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
          ElevatedButton(
            onPressed: _loadJuzData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    final surahNumbers = _juzRange['surahs'] as List<int>;

    return Scaffold(
      // In JuzDetailScreen's build method
      appBar: AppBar(
        title: Text('Juz ${widget.juzNumber}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              final audioProvider = Provider.of<AudioProvider>(
                context,
                listen: false,
              );
              audioProvider.playJuz(widget.juzNumber);
            },
            tooltip: 'Putar seluruh Juz',
          ),
          if (widget.highlightSurah != null && widget.highlightAyah != null)
            IconButton(
              icon: const Icon(Icons.center_focus_weak),
              onPressed: () {
                if (mounted) {
                  _scrollToAyah(widget.highlightSurah!, widget.highlightAyah!);
                }
              },
              tooltip: 'Scroll to highlighted ayah',
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadJuzData),
        ],
      ),
      body: Column(
        children: [
          _buildContentToggle(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: surahNumbers.length,
              itemBuilder: (context, surahIndex) {
                final surahNumber = surahNumbers[surahIndex];
                final verses = _surahVersesCache[surahNumber] ?? [];

                return FutureBuilder<Surah?>(
                  future: _fetchSurahDetail(surahNumber),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final surah = snapshot.data!;
                    return Column(
                      children: [
                        _buildSurahHeader(surah),
                        ...List.generate(verses.length, (index) {
                          return _buildAyahItem(
                            verses[index],
                            surahNumber,
                            index,
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const AudioControls(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _highlightedAyah.dispose();
    _highlightedSurah.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

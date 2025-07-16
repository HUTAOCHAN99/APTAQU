import 'package:al_quran/core/api/history_service.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/core/api/quran_service.dart';
import 'package:al_quran/data/models/ayah_model.dart';
import 'package:al_quran/core/services/auth_service.dart';

class TafsirScreen extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const TafsirScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  late Future<Ayah> _futureAyah;
  bool _isLoading = true;
  String _errorMessage = '';
  final HistoryService _historyService = HistoryService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ayah = await QuranService.fetchTafsir(
        widget.surahNumber,
        widget.ayahNumber,
      );

      if (!mounted) return;

      setState(() {
        _futureAyah = Future.value(ayah);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _saveHistory(Ayah ayah) async {
    try {
      final user = _authService.currentUser;
      if (user == null || !mounted) return;

      await _historyService.addHistory(
        userId: user.id,
        surahNumber: widget.surahNumber,
        surahName: ayah.surahName,
        ayahNumber: widget.ayahNumber,
        ayahText: ayah.shortText,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat berhasil disimpan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tafsir Surah ${widget.surahNumber}:${widget.ayahNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTafsir,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat tafsir...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Tafsir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTafsir,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<Ayah>(
      future: _futureAyah,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTafsir,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data tafsir tersedia'));
        }

        final ayah = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surah Info
                    if (ayah.surahName.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ayah.surahName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (ayah.surahRevelation.isNotEmpty)
                            Text(
                              ayah.surahRevelation,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Arabic Text
                    if (ayah.arabic.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            ayah.arabic,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'UthmanicHafs',
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    // Transliteration
                    if (ayah.transliteration.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            ayah.transliteration,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    // Translation
                    if (ayah.translation.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            ayah.translation,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Short Tafsir
                    if (ayah.shortTafsir.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tafsir Singkat:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah.shortTafsir,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Long Tafsir
                    if (ayah.longTafsir.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tafsir Lengkap:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah.longTafsir,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),

                    // Jika tidak ada tafsir
                    if (ayah.shortTafsir.isEmpty && ayah.longTafsir.isEmpty)
                      const Center(
                        child: Text('Tafsir tidak tersedia untuk ayat ini'),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bookmark),
                label: const Text('Simpan Riwayat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _saveHistory(ayah),
              ),
            ),
          ],
        );
      },
    );
  }
}

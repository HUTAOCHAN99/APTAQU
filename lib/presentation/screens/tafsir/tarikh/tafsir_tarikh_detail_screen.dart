// tafsir_tarikh_detail_screen.dart
import 'package:al_quran/data/models/tafsir/tafsir_tarikh.dart';
import 'package:flutter/material.dart';

class TafsirTarikhDetailScreen extends StatefulWidget {
  final List<TafsirTarikh> tafsirList;
  final int initialIndex;

  const TafsirTarikhDetailScreen({
    super.key,
    required this.tafsirList,
    this.initialIndex = 0,
  });

  @override
  State<TafsirTarikhDetailScreen> createState() => _TafsirTarikhDetailScreenState();
}

class _TafsirTarikhDetailScreenState extends State<TafsirTarikhDetailScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAyah(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.tafsirList.length) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tafsir Tarikh - Surah ${widget.tafsirList[_currentIndex].surahNama}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Navigation indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentIndex > 0
                      ? () => _navigateToAyah(_currentIndex - 1)
                      : null,
                ),
                Text(
                  'Ayat ${widget.tafsirList[_currentIndex].ayat} (${_currentIndex + 1}/${widget.tafsirList.length})',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentIndex < widget.tafsirList.length - 1
                      ? () => _navigateToAyah(_currentIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.tafsirList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final tafsir = widget.tafsirList[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'QS. ${tafsir.surahNama}:${tafsir.ayat}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Juz ${tafsir.juz} • Tafsir Tarikh',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Penjelasan Sejarah:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tafsir.isi,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:al_quran/data/models/tafsir/tafsir_ilmi.dart';
import 'package:flutter/material.dart';

class TafsirIlmiDetailScreen extends StatefulWidget {
  final List<TafsirIlmi> tafsirList;
  final int initialIndex;

  const TafsirIlmiDetailScreen({
    super.key,
    required this.tafsirList,
    this.initialIndex = 0,
  });

  @override
  State<TafsirIlmiDetailScreen> createState() => _TafsirIlmiDetailScreenState();
}

class _TafsirIlmiDetailScreenState extends State<TafsirIlmiDetailScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToAyah(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.tafsirList.length) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tafsir = widget.tafsirList[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('QS. ${tafsir.surahNama}:${tafsir.ayat}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _navigateToAyah(_currentIndex + 1);
          } else if (details.primaryVelocity! < 0) {
            _navigateToAyah(_currentIndex - 1);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentIndex > 0
                        ? () => _navigateToAyah(_currentIndex - 1)
                        : null,
                  ),
                  Text(
                    'Ayat ${tafsir.ayat} (${_currentIndex + 1}/${widget.tafsirList.length})',
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
              const SizedBox(height: 20),
              
              // Tafsir Content
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
                        'Juz ${tafsir.juz} • Tafsir Ilmi',
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
                'Penjelasan Ilmiah:',
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
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/history_screen.dart';
import 'package:al_quran/core/api/quran_service.dart';
import 'package:al_quran/data/models/juz_model.dart';
import 'package:al_quran/data/models/surah_model.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/juz_detail_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/suruh_detail_screen.dart';

class TafsirBahasaScreen extends StatefulWidget {
  const TafsirBahasaScreen({super.key});

  @override
  State<TafsirBahasaScreen> createState() => _TafsirBahasaScreenState();
}

class _TafsirBahasaScreenState extends State<TafsirBahasaScreen> {
  bool _showJuzList = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahList = [];
  List<Juz> _filteredJuzList = [];
  List<Surah> _allSurahList = [];
  List<Juz> _allJuzList = [];
  bool _isLoading = true;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final surahList = await QuranService.fetchSurahList();
      final juzList = await QuranService.fetchAllJuz();

      if (!mounted) return;

      setState(() {
        _allSurahList = surahList;
        _allJuzList = juzList;
        _filteredSurahList = surahList;
        _filteredJuzList = juzList;
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

  bool _matchesWordParts(String text, String query) {
    if (query.isEmpty) return true;
    
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final words = textLower.split(RegExp(r'[\s-]+')); 

    return words.any((word) => word.startsWith(queryLower));
  }

  void _filterSearchResults(String query) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }
    
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      if (query.isEmpty) {
        setState(() {
          _filteredSurahList = _allSurahList;
          _filteredJuzList = _allJuzList;
        });
        return;
      }

      if (_showJuzList) {
        setState(() {
          _filteredJuzList = _allJuzList
              .where((juz) =>
                  juz.number.toString().contains(query) ||
                  _matchesWordParts(juz.startInfo, query) ||
                  _matchesWordParts(juz.endInfo, query))
              .toList();
        });
      } else {
        setState(() {
          _filteredSurahList = _allSurahList
              .where((surah) =>
                  _matchesWordParts(surah.name, query) ||
                  _matchesWordParts(surah.englishName, query) ||
                  _matchesWordParts(surah.transliterationId, query) ||
                  surah.number.toString().contains(query))
              .toList();
        });
      }
    });
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text);
    
    final queryLower = query.toLowerCase();
    final words = text.split(RegExp(r'(\s+|-)')); // Split by space or hyphen
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          for (final word in words)
            TextSpan(
              text: word,
              style: word.toLowerCase().startsWith(queryLower)
                  ? const TextStyle(
                      backgroundColor: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )
                  : null,
            ),
          if (words.isNotEmpty) const TextSpan(text: ' '),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showJuzList = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showJuzList ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Berdasarkan Juz',
                    style: TextStyle(
                      color: _showJuzList ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showJuzList = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showJuzList ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Berdasarkan Surah',
                    style: TextStyle(
                      color: !_showJuzList ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzList() {
    final query = _searchController.text;
    
    return ListView.builder(
      itemCount: _filteredJuzList.length,
      itemBuilder: (context, index) {
        final juz = _filteredJuzList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JuzDetailScreen(juzNumber: juz.number),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${juz.number}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juz ${juz.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildHighlightedText(juz.startInfo, query),
                        _buildHighlightedText(juz.endInfo, query),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahList() {
    final query = _searchController.text;
    
    return ListView.builder(
      itemCount: _filteredSurahList.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SurahDetailScreen(surahNumber: surah.number),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHighlightedText(surah.name, query),
                        const SizedBox(height: 4),
                        _buildHighlightedText(surah.transliterationId, query),
                        Text(
                          '${surah.numberOfAyahs} ayat • ${surah.revelationType}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return _showJuzList ? _buildJuzList() : _buildSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tafsir Bahasa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'Riwayat Pembacaan',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Surah/Juz...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearchResults('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _filterSearchResults,
            ),
          ),
          _buildToggleButtons(),
          const SizedBox(height: 8),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
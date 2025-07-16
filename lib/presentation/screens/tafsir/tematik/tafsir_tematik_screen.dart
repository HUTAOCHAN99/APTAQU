// tafsir_tematik_screen.dart
import 'package:al_quran/data/models/surah_model.dart';
import 'package:al_quran/presentation/screens/tafsir/tematik/tafsir_tematik_repository.dart';
import 'package:al_quran/presentation/screens/tafsir/tematik/tafsir_tematik_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/core/api/quran_service.dart';

class TafsirTematikScreen extends StatefulWidget {
  const TafsirTematikScreen({super.key});

  @override
  State<TafsirTematikScreen> createState() => _TafsirTematikScreenState();
}

class _TafsirTematikScreenState extends State<TafsirTematikScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahList = [];
  List<Surah> _allSurahList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TafsirTematikRepository _tafsirRepo = TafsirTematikRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSurahList);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final surahList = await QuranService.fetchSurahList();

      if (!mounted) return;

      setState(() {
        _allSurahList = surahList;
        _filteredSurahList = _allSurahList;
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

  void _filterSurahList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahList = _allSurahList.where((surah) {
        final name = surah.name.toLowerCase();
        final englishName = surah.englishName.toLowerCase();
        return name.contains(query) || englishName.contains(query);
      }).toList();
    });
  }

  Widget _buildSurahItem(Surah surah) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            surah.number.toString(),
            style: const TextStyle(color: Colors.green),
          ),
        ),
        title: Text(surah.name),
        subtitle: Text('${surah.englishName} • ${surah.numberOfAyahs} ayat'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToFirstAyah(surah),
      ),
    );
  }

  Future<void> _navigateToFirstAyah(Surah surah) async {
    try {
      final tafsirList = await _tafsirRepo.getTafsirTematik(
        surahNomor: surah.number,
      );

      if (tafsirList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafsir tematik tidak ditemukan untuk surah ini'),
          ),
        );
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TafsirTematikDetailScreen(tafsirList: tafsirList),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat tafsir tematik: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tafsir Tematik'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari surah...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _filteredSurahList.isEmpty
                ? const Center(child: Text('Tidak ada surah yang ditemukan'))
                : ListView.builder(
                    itemCount: _filteredSurahList.length,
                    itemBuilder: (context, index) =>
                        _buildSurahItem(_filteredSurahList[index]),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSurahList);
    _searchController.dispose();
    super.dispose();
  }
}
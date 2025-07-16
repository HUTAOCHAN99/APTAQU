import 'package:al_quran/data/models/surah_model.dart';
import 'package:al_quran/presentation/screens/tafsir/imli/tafsir_ilmi_detail_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/imli/tafsir_repository.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/core/api/quran_service.dart';

class TafsirIlmiScreen extends StatefulWidget {
  const TafsirIlmiScreen({super.key});

  @override
  State<TafsirIlmiScreen> createState() => _TafsirIlmiScreenState();
}

class _TafsirIlmiScreenState extends State<TafsirIlmiScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahList = [];
  List<Surah> _allSurahList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TafsirRepository _tafsirRepo = TafsirRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Widget _buildSurahItem(Surah surah) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Text(surah.number.toString()),
      ),
      title: Text(surah.name),
      subtitle: Text('${surah.numberOfAyahs} ayat'),
      onTap: () => _navigateToFirstAyah(surah),
    );
  }

  Future<void> _navigateToFirstAyah(Surah surah) async {
    try {
      final tafsirList = await _tafsirRepo.getTafsirIlmi(
        surahNomor: surah.number.toString(),
      );

      if (tafsirList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tafsir tidak ditemukan')),
        );
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TafsirIlmiDetailScreen(
              tafsirList: tafsirList,
              initialIndex: 0, // Langsung ke ayat pertama
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tafsir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tafsir Ilmi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _filteredSurahList.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildSurahItem(_filteredSurahList[index]),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
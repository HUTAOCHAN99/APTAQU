import 'package:al_quran/core/api/history_service.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/juz_detail_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/suruh_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/data/models/history_model.dart';
import 'package:al_quran/core/services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final AuthService _authService = AuthService();
  List<History> _historyList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showBySurah = true;
  final List<String> _selectedIds = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _selectedIds.clear();
      _isSelectionMode = false;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final histories = await _historyService.getHistory(user.id);
        if (mounted) {
          setState(() {
            _historyList = histories;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAyah(History history) {
    if (_showBySurah) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahDetailScreen(
            surahNumber: history.surahNumber,
            initialAyah: history.ayahNumber,
          ),
        ),
      );
    } else {
      if (history.juzNumber != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JuzDetailScreen(
              juzNumber: history.juzNumber!,
              highlightSurah: history.surahNumber,
              highlightAyah: history.ayahNumber,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informasi juz tidak tersedia untuk riwayat ini'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

Future<void> _deleteSelected() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Text('Yakin ingin menghapus ${_selectedIds.length} riwayat?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await _historyService.deleteMultiple(_selectedIds);
      
      if (!mounted) return; // Add mounted check
      await _loadHistory();
      
      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedIds.length} riwayat berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIds.length} dipilih')
            : const Text('Riwayat Pembacaan'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
              tooltip: 'Hapus yang dipilih',
            ),
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadHistory,
              tooltip: 'Muat Ulang',
            ),
        ],
      ),
  
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Berdasarkan Surah'),
                  selected: _showBySurah,
                  onSelected: (selected) {
                    setState(() {
                      _showBySurah = selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Berdasarkan Juz'),
                  selected: !_showBySurah,
                  onSelected: (selected) {
                    setState(() {
                      _showBySurah = !selected;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadHistory,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _historyList.isEmpty
                        ? const Center(child: Text('Tidak ada riwayat pembacaan'))
                        : ListView.builder(
                            itemCount: _historyList.length,
                            itemBuilder: (context, index) {
                              final history = _historyList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(
                                      '${history.surahName} : ${history.ayahNumber}'),
                                  subtitle: Text(
                                    _showBySurah
                                        ? 'Ayat ${history.ayahNumber}'
                                        : 'Juz ${history.juzNumber ?? '-'}',
                                  ),
                                  leading: _isSelectionMode
                                      ? Checkbox(
                                          value: _selectedIds.contains(history.id),
                                          onChanged: (_) =>
                                              _toggleSelection(history.id),
                                        )
                                      : null,
                                  trailing: _isSelectionMode
                                      ? null
                                      : const Icon(Icons.chevron_right),
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      _toggleSelection(history.id);
                                    } else {
                                      _navigateToAyah(history);
                                    }
                                  },
                                  onLongPress: () {
                                    _toggleSelection(history.id);
                                    if (!_isSelectionMode) {
                                      setState(() => _isSelectionMode = true);
                                    }
                                  },
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
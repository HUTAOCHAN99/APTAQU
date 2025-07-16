import 'package:al_quran/presentation/screens/tafsir/bahasa/juz_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:al_quran/core/api/quran_service.dart';
import 'package:al_quran/data/models/juz_model.dart';

class JuzListScreen extends StatefulWidget {
  const JuzListScreen({super.key});

  @override
  State<JuzListScreen> createState() => _JuzListScreenState();
}

class _JuzListScreenState extends State<JuzListScreen> {
  late Future<List<Juz>> _juzListFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadJuzList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJuzList() async {
    setState(() {
      _juzListFuture = QuranService.fetchAllJuz();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Juz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJuzList,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadJuzList,
        child: FutureBuilder<List<Juz>>(
          future: _juzListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorWidget(
                error: snapshot.error.toString(),
                onRetry: _loadJuzList,
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data Juz'));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final juz = snapshot.data![index];
                return _JuzListItem(
                  juz: juz,
                  onTap: () => _navigateToDetail(context, juz.number),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int juzNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JuzDetailScreen(juzNumber: juzNumber),
      ),
    );
  }
}

class _JuzListItem extends StatelessWidget {
  final Juz juz;
  final VoidCallback onTap;

  const _JuzListItem({required this.juz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                  juz.number.toString(),
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
                    Text(
                      'Mulai: ${juz.startInfo}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text(
                      'Sampai: ${juz.endInfo}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

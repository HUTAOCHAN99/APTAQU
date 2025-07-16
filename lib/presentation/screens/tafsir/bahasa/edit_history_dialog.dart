import 'package:flutter/material.dart';
import 'package:al_quran/data/models/history_model.dart';

class EditHistoryDialog extends StatefulWidget {
  final History history;

  const EditHistoryDialog({super.key, required this.history});

  @override
  State<EditHistoryDialog> createState() => _EditHistoryDialogState();
}

class _EditHistoryDialogState extends State<EditHistoryDialog> {
  late final TextEditingController _surahController;
  late final TextEditingController _ayahController;
  late final TextEditingController _textController;
  late final TextEditingController _juzController;

  @override
  void initState() {
    super.initState();
    _surahController = TextEditingController(text: widget.history.surahName);
    _ayahController = TextEditingController(
        text: widget.history.ayahNumber.toString());
    _textController = TextEditingController(text: widget.history.ayahText);
    _juzController = TextEditingController(
        text: widget.history.juzNumber?.toString() ?? '');
  }

  @override
  void dispose() {
    _surahController.dispose();
    _ayahController.dispose();
    _textController.dispose();
    _juzController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Riwayat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _surahController,
              decoration: const InputDecoration(labelText: 'Nama Surah'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ayahController,
              decoration: const InputDecoration(labelText: 'Nomor Ayat'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Teks Ayat'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _juzController,
              decoration: const InputDecoration(labelText: 'Juz (opsional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _saveChanges() {
    final updatedHistory = widget.history.copyWith(
      surahName: _surahController.text,
      ayahNumber: int.tryParse(_ayahController.text) ?? widget.history.ayahNumber,
      ayahText: _textController.text,
      juzNumber: int.tryParse(_juzController.text),
    );

    Navigator.pop(context, updatedHistory);
  }
}
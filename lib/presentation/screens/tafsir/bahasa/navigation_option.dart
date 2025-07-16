import 'package:flutter/material.dart';

class NavigationOption extends StatelessWidget {
  final bool isSurahSelected;
  final Function(bool) onChanged;

  const NavigationOption({
    super.key,
    required this.isSurahSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSurahSelected ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Berdasarkan Juz',
                    style: TextStyle(
                      color: !isSurahSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSurahSelected ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Berdasarkan Surah',
                    style: TextStyle(
                      color: isSurahSelected ? Colors.white : Colors.black,
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
}
import 'dart:ui';

import 'package:al_quran/core/config/score_repository.dart';
import 'package:al_quran/data/models/game/user_score.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaderboardScreen extends StatefulWidget {
  final String category;

  const LeaderboardScreen({super.key, required this.category});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<UserScore>> _leaderboardFuture;
  final ScoreRepository _scoreRepository = ScoreRepository();

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _scoreRepository.getLeaderboard(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard ${widget.category}')),
      body: FutureBuilder<List<UserScore>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data leaderboard'));
          }

          final leaderboard = snapshot.data!;

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final score = leaderboard[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(score.userName),
                subtitle: Text(
                  'Skor: ${score.score} - ${DateFormat('dd MMM yyyy').format(score.date)}',
                ),
                trailing: Text(
                  '${score.score}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

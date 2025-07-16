// quiz_screen.dart
// import 'package:al_quran/core/config/quiz_data.dart'; // Hapus import ini karena sudah digabungkan
import 'package:al_quran/core/config/score_repository.dart';
import 'package:al_quran/core/constant/colors.dart';
import 'package:al_quran/core/utils/game/shared_prefs.dart';
import 'package:al_quran/data/models/game/question.dart';
import 'package:al_quran/data/models/game/user_score.dart';
import 'package:al_quran/presentation/screens/game/leaderboard.dart';
import 'package:flutter/material.dart';

// ==========================================================
// QUIZ_DATA.DART ISI KODE DI BAWAH INI DIGABUNGKAN KE SINI
// ==========================================================
class QuizData {
  static final List<Question> _questions = [
    Question(
      id: '1',
      question: 'Berapa jumlah Surah dalam Al-Quran?',
      options: ['114', '124', '104', '94'],
      correctAnswer: 0,
      category: 'Umum',
    ),
    Question(
      id: '2',
      question: 'Surah pertama dalam Al-Quran adalah?',
      options: ['Al-Baqarah', 'An-Nas', 'Al-Fatihah', 'Al-Ikhlas'],
      correctAnswer: 2,
      category: 'Umum',
    ),
    Question(
      id: '3',
      question: 'Siapa nama nabi yang menerima mukjizat Al-Quran?',
      options: ['Nabi Musa', 'Nabi Isa', 'Nabi Muhammad', 'Nabi Ibrahim'],
      correctAnswer: 2,
      category: 'Sejarah Islam',
    ),
    Question(
      id: '4',
      question: 'Pada bulan apa umat Islam wajib berpuasa?',
      options: ['Syawal', 'Dzulhijjah', 'Ramadhan', 'Muharram'],
      correctAnswer: 2,
      category: 'Fiqih',
    ),
    Question(
      id: '5',
      question: 'Shalat fardhu yang paling utama adalah?',
      options: ['Shubuh', 'Dzuhur', 'Ashar', 'Isya'],
      correctAnswer: 0,
      category: 'Fiqih',
    ),
    Question(
      id: '6',
      question: 'Berapa rakaat shalat Isya?',
      options: ['2', '3', '4', '5'],
      correctAnswer: 2,
      category: 'Fiqih',
    ),
    Question(
      id: '7',
      question: 'Apa kiblat umat Islam saat shalat?',
      options: ['Masjid Nabawi', 'Masjid Al-Aqsa', 'Ka\'bah', 'Bukit Shafa'],
      correctAnswer: 2,
      category: 'Umum',
    ),
    Question(
      id: '8',
      question: 'Siapa yang dikenal sebagai "Sahabat Nabi" yang pertama kali mengumandangkan adzan?',
      options: ['Umar bin Khattab', 'Ali bin Abi Thalib', 'Bilal bin Rabah', 'Abu Bakar Ash-Shiddiq'],
      correctAnswer: 2,
      category: 'Sejarah Islam',
    ),
    Question(
      id: '9',
      question: 'Nama kota suci tempat Nabi Muhammad SAW dilahirkan adalah?',
      options: ['Madinah', 'Yerusalem', 'Makkah', 'Damaskus'],
      correctAnswer: 2,
      category: 'Sejarah Islam',
    ),
    Question(
      id: '10',
      question: 'Rukun Islam yang pertama adalah?',
      options: ['Shalat', 'Puasa', 'Syahadat', 'Zakat'],
      correctAnswer: 2,
      category: 'Fiqih',
    ),
    // 10 PERTANYAAN BARU DITAMBAHKAN DI SINI
    Question(
      id: '11',
      question: 'Bulan-bulan Haram dalam Islam adalah kecuali?',
      options: ['Ramadhan', 'Dzulqa’dah', 'Dzulhijjah', 'Muharram'],
      correctAnswer: 0,
      category: 'Fiqih',
    ),
    Question(
      id: '12',
      question: 'Siapa nama istri pertama Nabi Muhammad SAW?',
      options: ['Aisyah', 'Fatimah', 'Khadijah', 'Zainab'],
      correctAnswer: 2,
      category: 'Sejarah Islam',
    ),
    Question(
      id: '13',
      question: 'Berapa jumlah nabi yang wajib diimani dalam Islam?',
      options: ['10', '25', '99', '124000'],
      correctAnswer: 1,
      category: 'Umum',
    ),
    Question(
      id: '14',
      question: 'Kitab suci Zabur diturunkan kepada Nabi siapa?',
      options: ['Nabi Musa', 'Nabi Isa', 'Nabi Daud', 'Nabi Ibrahim'],
      correctAnswer: 2,
      category: 'Umum',
    ),
    Question(
      id: '15',
      question: 'Peristiwa Isra Mi\'raj dialami Nabi Muhammad SAW pada tahun ke berapa kenabian?',
      options: ['Tahun ke-5', 'Tahun ke-7', 'Tahun ke-10', 'Tahun ke-13'],
      correctAnswer: 2,
      category: 'Sejarah Islam',
    ),
    Question(
      id: '16',
      question: 'Zakat fitrah wajib dibayarkan pada bulan apa?',
      options: ['Syawal', 'Ramadhan', 'Dzulhijjah', 'Muharram'],
      correctAnswer: 1,
      category: 'Fiqih',
    ),
    Question(
      id: '17',
      question: 'Puasa sunnah yang dilakukan setiap hari Senin dan Kamis adalah?',
      options: ['Puasa Arafah', 'Puasa Daud', 'Puasa Tasu\'a', 'Puasa Asyura'],
      correctAnswer: 1,
      category: 'Fiqih',
    ),
    Question(
      id: '18',
      question: 'Ayat terpanjang dalam Al-Quran terdapat di surah apa?',
      options: ['Al-Fatihah', 'Al-Baqarah', 'Ali Imran', 'Yasin'],
      correctAnswer: 1,
      category: 'Umum',
    ),
    Question(
      id: '19',
      question: 'Berapa jumlah Juz dalam Al-Quran?',
      options: ['10', '20', '30', '40'],
      correctAnswer: 2,
      category: 'Umum',
    ),
    Question(
      id: '20',
      question: 'Siapa nama paman Nabi Muhammad SAW yang meninggal sebagai syuhada di perang Uhud?',
      options: ['Abu Thalib', 'Hamzah bin Abdul Muthalib', 'Abbas bin Abdul Muthalib', 'Abu Lahab'],
      correctAnswer: 1,
      category: 'Sejarah Islam',
    ),
  ];

  static List<Question> getQuestionsByCategory(String category, {int limit = 10}) {
    final categoryQuestions = _questions.where((q) => q.category == category).toList();
    categoryQuestions.shuffle();
    return categoryQuestions.take(limit).toList(); // Perhatikan limit default 10
  }

  static List<String> getCategories() {
    return _questions.map((q) => q.category).toSet().toList();
  }
}
// ==========================================================
// AKHIR DARI QUIZ_DATA.DART
// ==========================================================


class QuizScreen extends StatefulWidget {
  final String category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  final ScoreRepository _scoreRepository = ScoreRepository();

  final SharedPrefs _sharedPrefs = SharedPrefs();
  late Future<void> _prefsInitializationFuture;

  @override
  void initState() {
    super.initState();
    // Jika Anda ingin semua 20 pertanyaan dari kategori yang sama
    // maka ubah limit di sini menjadi 20 atau buang limit jika ingin semua yang ada
    _questions = QuizData.getQuestionsByCategory(widget.category, limit: 20); // <<< UBAH LIMIT DI SINI
    _prefsInitializationFuture = _sharedPrefs.init();
  }

  void _answerQuestion(int selectedIndex) {
    if (_questions[_currentQuestionIndex].correctAnswer == selectedIndex) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    try {
      await _prefsInitializationFuture;

      final user = await _sharedPrefs.getUser();

      await _scoreRepository.saveScore(
        UserScore(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user['id'] ?? 'guest',
          userName: user['name'] ?? 'Guest',
          category: widget.category,
          score: _score,
          date: DateTime.now(),
        ),
      );

      setState(() {
        _quizCompleted = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving score: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis ${widget.category}'),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.secondaryGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: _prefsInitializationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error initializing preferences: ${snapshot.error}'));
              } else {
                return _quizCompleted ? _buildResults() : _buildQuestion();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pertanyaan ${_currentQuestionIndex + 1}/${_questions.length}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.white24,
          color: Colors.white,
        ),
        const SizedBox(height: 30),
        Text(
          question.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.builder(
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                child: ListTile(
                  title: Text(
                    question.options[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => _answerQuestion(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz Selesai!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Skor Anda: $_score/${_questions.length}',
            style: TextStyle(
              color: _score == _questions.length
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(category: widget.category),
                ),
              );
            },
            child: const Text('Main Lagi'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LeaderboardScreen(category: widget.category),
                ),
              );
            },
            child: const Text('Lihat Leaderboard'),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:al_quran/presentation/widgets/game/crossword_template_manager.dart';
import 'package:al_quran/presentation/widgets/game/game_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:al_quran/core/config/crosssword_config.dart';
import 'package:al_quran/core/constant/constants.dart';
import 'package:al_quran/data/models/game/clue.dart';
import 'package:al_quran/presentation/widgets/game/crossword_grid.dart';
import 'package:al_quran/presentation/widgets/game/clue_section.dart';
import 'package:al_quran/presentation/widgets/game/crossword_template.dart';

enum GameStatus { initializing, playing, paused, completed, error }

class CrosswordScreen extends StatefulWidget {
  final CrosswordTemplate template; // Non-nullable
  final GameSession? gameSession;
  final List<Clue> acrossClues;
  final List<Clue> downClues;
  final CrosswordConfig config;

  const CrosswordScreen({
    super.key,
    required this.template, // Required parameter
    this.gameSession,
    this.acrossClues = const [],
    this.downClues = const [],
    this.config = const CrosswordConfig(),
  });

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late GameSession _gameSession;
  late List<Clue> _acrossClues;
  late List<Clue> _downClues;
  late List<List<bool>> _isWhite;
  late List<List<String>> _letters;
  late List<List<int?>> _numbers;
  late List<List<FocusNode>> _focusNodes;
  int? _activeRow;
  int? _activeCol;
  GameStatus _status = GameStatus.initializing;
  Duration _elapsedTime = Duration.zero;
  late Timer _timer;
  int _hintsUsed = 0;
  bool _showCompletionDialog = false;
  final _scrollController = ScrollController();

  // Getter for the template to avoid repeating widget.template
  CrosswordTemplate get _template => widget.template;

  @override
  void initState() {
    super.initState();
    _gameSession = widget.gameSession ?? GameSession([widget.template]);
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      setState(() => _status = GameStatus.initializing);

      _isWhite = _template.generateGrid();
      _acrossClues = widget.acrossClues.isNotEmpty
          ? widget.acrossClues
          : _template.acrossClues;
      _downClues = widget.downClues.isNotEmpty
          ? widget.downClues
          : _template.downClues;

      // Sort clues by their starting position (row then column)
      _acrossClues.sort((a, b) {
        if (a.row == b.row) return a.col.compareTo(b.col);
        return a.row.compareTo(b.row);
      });

      _downClues.sort((a, b) {
        if (a.col == b.col) return a.row.compareTo(b.row);
        return a.col.compareTo(b.col);
      });

      _initializeGameState();
      _startTimer();

      setState(() => _status = GameStatus.playing);
    } catch (e) {
      debugPrint('Error initializing game: $e');
      setState(() => _status = GameStatus.error);
      _loadFallbackTemplate();
    }
  }

  void _initializeGameState() {
    _letters = List.generate(
      _template.rows,
      (row) => List.filled(_template.cols, ''),
    );

    _numbers = _generateNumberGrid();
    _focusNodes = _initializeFocusNodes();
  }

  List<List<FocusNode>> _initializeFocusNodes() {
    return List.generate(
      _template.rows,
      (row) => List.generate(
        _template.cols,
        (col) => FocusNode(
          onKeyEvent: (node, event) =>
              _handleKeyboardNavigation(event, row, col),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyboardNavigation(KeyEvent event, int row, int col) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        _moveFocus(row, col + 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _moveFocus(row, col - 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _moveFocus(row + 1, col);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveFocus(row - 1, col);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.tab:
        _moveToNextClue();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _moveFocus(int newRow, int newCol) {
    if (widget.config.allowWrapAround) {
      newRow = newRow % _template.rows;
      newCol = newCol % _template.cols;
      if (newRow < 0) newRow = _template.rows - 1;
      if (newCol < 0) newCol = _template.cols - 1;
    }

    if (_isValidIndex(newRow, newCol) && _isWhite[newRow][newCol]) {
      setState(() {
        _activeRow = newRow;
        _activeCol = newCol;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        if (mounted) {
          _focusNodes[newRow][newCol].requestFocus();
        }
      });
    }
  }

  void _moveToNextClue() {
    if (_activeRow == null || _activeCol == null) return;

    // Simple implementation - move to next empty cell
    for (int row = _activeRow!; row < _template.rows; row++) {
      for (
        int col = (row == _activeRow! ? _activeCol! + 1 : 0);
        col < _template.cols;
        col++
      ) {
        if (_isWhite[row][col] && _letters[row][col].isEmpty) {
          _moveFocus(row, col);
          return;
        }
      }
    }
  }

  void _loadFallbackTemplate() {
    // Use first available template as fallback
    final fallback = CrosswordTemplateManager.templates.first;

    setState(() {
      _isWhite = fallback.generateGrid();
      _acrossClues = fallback.acrossClues;
      _downClues = fallback.downClues;
    });

    _initializeGameState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    for (var row in _focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final cellSize = _calculateCellSize(mediaQuery.size);

    return Scaffold(
      appBar: AppBar(
        title: Text(_template.name ?? 'Crossword Puzzle'),
        actions: [
          if (_status == GameStatus.playing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
              tooltip: 'Restart',
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkAnswers,
            tooltip: 'Check Answers',
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          if (_status == GameStatus.error) {
            return _buildErrorScreen();
          }

          if (_status == GameStatus.initializing) {
            return const Center(child: CircularProgressIndicator());
          }

          return isLandscape
              ? _buildLandscapeLayout(mediaQuery, cellSize)
              : _buildPortraitLayout(mediaQuery, cellSize);
        },
      ),
    );
  }

  Widget _buildLandscapeLayout(MediaQueryData mediaQuery, double cellSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (widget.config.showTimer) _buildTimer(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildResponsiveGrid(cellSize),
                      ),
                    ),
                    if (widget.config.showHints)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildHintButton(),
                      ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                height: constraints.maxHeight,
                child: _buildCluesSection(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPortraitLayout(MediaQueryData mediaQuery, double cellSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridHeight = _template.rows * cellSize;
        final remainingHeight = constraints.maxHeight - gridHeight - 100;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.config.showTimer) _buildTimer(),
                const SizedBox(height: 16),
                _buildResponsiveGrid(cellSize),
                const SizedBox(height: 16),
                SizedBox(
                  height: max(remainingHeight, 150), // Use max instead of clamp
                  child: _buildCluesSection(),
                ),
                if (widget.config.showHints)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: _buildHintButton(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveGrid(double cellSize) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: min(
            _template.cols * cellSize,
            MediaQuery.of(context).size.width * 0.95,
          ),
          maxHeight: min(
            _template.rows * cellSize,
            MediaQuery.of(context).size.height * 0.6,
          ),
        ),
        child: CrosswordGrid(
          isWhite: _isWhite,
          letters: _letters,
          numbers: _numbers,
          onChanged: _handleLetterChanged,
          cellSize: cellSize,
          activeRow: _activeRow,
          activeCol: _activeCol,
          config: widget.config,
          focusNodes: _focusNodes,
        ),
      ),
    );
  }

  Widget _buildCluesSection() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClueSection(
                title: 'Across',
                clues: _acrossClues,
                onClueSelected: _highlightClue,
              ),
              const SizedBox(height: 16),
              ClueSection(
                title: 'Down',
                clues: _downClues,
                onClueSelected: _highlightClue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCellSize(Size screenSize) {
    // Subtract 4px to account for potential borders and padding
    final pixelAdjustment = 4.0;

    final isPortrait = screenSize.height > screenSize.width;
    final padding = isPortrait ? 32.0 : 48.0;

    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final maxAvailableHeight =
        screenSize.height -
        appBarHeight -
        statusBarHeight -
        bottomPadding -
        (isPortrait ? 200 : 0) -
        pixelAdjustment;

    final maxAvailableWidth = screenSize.width - padding - pixelAdjustment;

    final maxCellWidth = maxAvailableWidth / _template.cols;
    final maxCellHeight = maxAvailableHeight / _template.rows;

    return min(
      maxCellWidth,
      maxCellHeight,
    ).clamp(CrosswordConstants.minCellSize, CrosswordConstants.maxCellSize);
  }

  Widget _buildTimer() {
    final minutes = _elapsedTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _elapsedTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer, size: 20),
        const SizedBox(width: 8),
        Text(
          '$minutes:$seconds',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHintButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lightbulb_outline),
      label: Text('Hint ($_hintsUsed used)'),
      onPressed: _showHintDialog,
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Failed to load puzzle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLetterChanged(int row, int col, String value) {
    if (!_isValidIndex(row, col)) return;

    setState(() {
      _letters[row][col] = value.isNotEmpty ? value[0].toUpperCase() : '';
      _activeRow = row;
      _activeCol = col;
    });

    if (value.isNotEmpty && col < _template.cols - 1) {
      _moveFocus(row, col + 1);
    }
  }

  void _checkAnswers() {
    final isComplete = _isPuzzleComplete();
    setState(() {
      _status = isComplete ? GameStatus.completed : GameStatus.playing;
      _showCompletionDialog = isComplete;
    });

    if (_showCompletionDialog) {
      _showCompletionMessage();
    }
  }

  bool _isValidIndex(int row, int col) {
    return row >= 0 && row < _template.rows && col >= 0 && col < _template.cols;
  }

  bool _isPuzzleComplete() {
    for (int row = 0; row < _template.rows; row++) {
      for (int col = 0; col < _template.cols; col++) {
        if (_isWhite[row][col] && _letters[row][col].isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void _showCompletionMessage() {
    final timeBonus = 100 - min(_elapsedTime.inSeconds, 100);
    final hintPenalty = _hintsUsed * 20;
    final points = (100 + timeBonus - hintPenalty).toInt();

    _gameSession.addScore(points);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selamat!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Waktu: ${_formatTime(_elapsedTime)}'),
            Text('Bonus Waktu: +$timeBonus'),
            Text('Penalti Hint: -$hintPenalty'),
            Text('Total Poin: $points'),
            const SizedBox(height: 16),
            Text('Skor Sesi: ${_gameSession.score}'),
          ],
        ),
        actions: [
          if (_gameSession.moveToNext())
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Puzzle Berikutnya'),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Selesai'),
            ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _resetGame() {
    setState(() {
      _status = GameStatus.initializing;
      _elapsedTime = Duration.zero;
      _hintsUsed = 0;
      _showCompletionDialog = false;
    });
    _timer.cancel();
    _initializeGame();
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Hint'),
        content: const Text('Select hint type:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _revealLetter();
            },
            child: const Text('Reveal Letter'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _revealWord();
            },
            child: const Text('Reveal Word'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _revealLetter() {
    for (int row = 0; row < _template.rows; row++) {
      for (int col = 0; col < _template.cols; col++) {
        if (_isWhite[row][col] && _letters[row][col].isEmpty) {
          setState(() {
            _letters[row][col] = _getCorrectLetter(row, col);
            _hintsUsed++;
          });
          return;
        }
      }
    }
  }

  void _revealWord() {
    for (final clue in _acrossClues) {
      if (_isWordIncomplete(clue, true)) {
        _fillWord(clue, true);
        return;
      }
    }
    for (final clue in _downClues) {
      if (_isWordIncomplete(clue, false)) {
        _fillWord(clue, false);
        return;
      }
    }
  }

  bool _isWordIncomplete(Clue clue, bool isAcross) {
    if (isAcross) {
      for (int i = 0; i < clue.answer.length; i++) {
        if (_letters[clue.row][clue.col + i].isEmpty) {
          return true;
        }
      }
    } else {
      for (int i = 0; i < clue.answer.length; i++) {
        if (_letters[clue.row + i][clue.col].isEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  void _fillWord(Clue clue, bool isAcross) {
    setState(() {
      if (isAcross) {
        for (int i = 0; i < clue.answer.length; i++) {
          _letters[clue.row][clue.col + i] = clue.answer[i];
        }
      } else {
        for (int i = 0; i < clue.answer.length; i++) {
          _letters[clue.row + i][clue.col] = clue.answer[i];
        }
      }
      _hintsUsed++;
    });
  }

  String _getCorrectLetter(int row, int col) {
    for (final clue in _acrossClues) {
      if (row == clue.row) {
        for (int i = 0; i < clue.answer.length; i++) {
          if (col == clue.col + i) {
            return clue.answer[i];
          }
        }
      }
    }
    for (final clue in _downClues) {
      if (col == clue.col) {
        for (int i = 0; i < clue.answer.length; i++) {
          if (row == clue.row + i) {
            return clue.answer[i];
          }
        }
      }
    }
    return 'A'; // fallback
  }

  void _highlightClue(Clue clue, bool isAcross) {
    if (_isValidIndex(clue.row, clue.col)) {
      setState(() {
        _activeRow = clue.row;
        _activeCol = clue.col;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        if (mounted) {
          _focusNodes[clue.row][clue.col].requestFocus();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == GameStatus.playing && mounted) {
        setState(() => _elapsedTime += const Duration(seconds: 1));
      }
    });
  }

  List<List<int?>> _generateNumberGrid() {
    final grid = List.generate(
      _template.rows,
      (row) => List<int?>.filled(_template.cols, null),
    );

    // Generate numbers for Across clues
    int acrossNumber = 1;
    for (final clue in _acrossClues) {
      if (_isValidIndex(clue.row, clue.col)) {
        // ← Tambahkan tanda kurung tutup di sini
        grid[clue.row][clue.col] = acrossNumber;
      }
      acrossNumber++;
    }

    // Generate numbers for Down clues
    int downNumber = 1;
    for (final clue in _downClues) {
      // Only put number if there isn't already an Across number
      if (_isValidIndex(clue.row, clue.col)) {
        // ← Tambahkan tanda kurung tutup di sini juga
        if (grid[clue.row][clue.col] == null) {
          grid[clue.row][clue.col] = downNumber;
        }
      }
      downNumber++;
    }

    return grid;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import "../subpages/minigame.dart";

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe Trio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

enum GameMode { vsComputer, vsPlayer }

// ---------------------------------------------------------------------------
// HOME SCREEN — choose how you want to play
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(mode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.grid_3x3_rounded,
                  size: 90,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tic Tac Toe',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Best of 3 Series',
                  style: TextStyle(fontSize: 16, color: Colors.white60),
                ),
                const SizedBox(height: 48),
                _ModeButton(
                  icon: Icons.smart_toy_rounded,
                  label: 'Play vs Computer',
                  onTap: () => _startGame(context, GameMode.vsComputer),
                ),
                const SizedBox(height: 16),
                _ModeButton(
                  icon: Icons.people_alt_rounded,
                  label: 'Play vs Friend',
                  onTap: () => _startGame(context, GameMode.vsPlayer),
                ),
                const SizedBox(height: 20),

                _ModeButton(
                  icon: Icons.arrow_back_ios_new_outlined,
                  label: 'Exit',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MiniGames()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 26),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GAME SCREEN — plays a best-of-3 series
// ---------------------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const List<List<int>> winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  List<String> board = List.filled(9, '');
  bool xTurn = true;
  int round = 1;
  int xWins = 0;
  int oWins = 0;
  int draws = 0;
  bool roundOver = false;
  String? winner; // 'X', 'O', or 'Draw'
  List<int>? winningLine;
  final Random _rand = Random();

  bool get vsComputer => widget.mode == GameMode.vsComputer;

  void _handleTap(int index) {
    if (roundOver || board[index].isNotEmpty) return;
    if (vsComputer && !xTurn) return; // block taps during computer's turn
    _placeMark(index);
  }

  void _placeMark(int index) {
    setState(() => board[index] = xTurn ? 'X' : 'O');

    final result = _checkResult();
    if (result != null) {
      _finishRound(result);
      return;
    }

    setState(() => xTurn = !xTurn);

    if (vsComputer && !xTurn && !roundOver) {
      Future.delayed(const Duration(milliseconds: 500), _computerMove);
    }
  }

  void _computerMove() {
    if (roundOver) return;
    final move = _bestComputerMove();
    if (move != -1) _placeMark(move);
  }

  // Simple heuristic AI: win > block > center > corner > random
  int _bestComputerMove() {
    final winMove = _findWinningMove('O');
    if (winMove != -1) return winMove;

    final blockMove = _findWinningMove('X');
    if (blockMove != -1) return blockMove;

    if (board[4].isEmpty) return 4;

    final corners = [0, 2, 6, 8]..shuffle(_rand);
    for (final c in corners) {
      if (board[c].isEmpty) return c;
    }

    final remaining = [
      for (int i = 0; i < 9; i++)
        if (board[i].isEmpty) i,
    ]..shuffle(_rand);
    return remaining.isNotEmpty ? remaining.first : -1;
  }

  int _findWinningMove(String mark) {
    for (final line in winLines) {
      final values = line.map((i) => board[i]).toList();
      if (values.where((v) => v == mark).length == 2 && values.contains('')) {
        return line[values.indexOf('')];
      }
    }
    return -1;
  }

  String? _checkResult() {
    for (final line in winLines) {
      final a = board[line[0]], b = board[line[1]], c = board[line[2]];
      if (a.isNotEmpty && a == b && b == c) {
        winningLine = line;
        return a;
      }
    }
    if (!board.contains('')) return 'Draw';
    return null;
  }

  void _finishRound(String result) {
    setState(() {
      roundOver = true;
      winner = result;
      if (result == 'X') {
        xWins++;
      } else if (result == 'O') {
        oWins++;
      } else {
        draws++;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _showRoundResultDialog(result);
    });
  }

  void _showRoundResultDialog(String result) {
    final seriesOver = round >= 3;
    final title = result == 'Draw'
        ? "Round $round: It's a Draw!"
        : 'Round $round: ${_labelFor(result)} Wins!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title),
        content: Text(
          seriesOver
              ? _seriesResultText()
              : 'Score  X: $xWins   O: $oWins   Draws: $draws',
        ),
        actions: [
          if (!seriesOver)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nextRound();
              },
              child: const Text('Next Round'),
            ),
          if (seriesOver) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetSeries();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Home'),
            ),
          ],
        ],
      ),
    );
  }

  String _labelFor(String mark) {
    if (mark == 'X') return 'Player X';
    return vsComputer ? 'Computer (O)' : 'Player O';
  }

  String _seriesResultText() {
    if (xWins == oWins) {
      return 'The series ends in a tie!\nX: $xWins   O: $oWins   Draws: $draws';
    }
    final championIsX = xWins > oWins;
    final champion = championIsX
        ? 'Player X'
        : (vsComputer ? 'Computer (O)' : 'Player O');
    return '$champion wins the series!\nX: $xWins   O: $oWins   Draws: $draws';
  }

  void _nextRound() {
    setState(() {
      round++;
      board = List.filled(9, '');
      roundOver = false;
      winner = null;
      winningLine = null;
      // Alternate who starts each round for fairness
      xTurn = round % 2 != 0;
    });

    if (vsComputer && !xTurn) {
      Future.delayed(const Duration(milliseconds: 500), _computerMove);
    }
  }

  void _resetSeries() {
    setState(() {
      round = 1;
      xWins = 0;
      oWins = 0;
      draws = 0;
      board = List.filled(9, '');
      roundOver = false;
      winner = null;
      winningLine = null;
      xTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Round $round of 3'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ScoreBoard(
                xWins: xWins,
                oWins: oWins,
                draws: draws,
                vsComputer: vsComputer,
              ),
              const SizedBox(height: 24),
              Text(
                roundOver
                    ? (winner == 'Draw'
                          ? "It's a draw!"
                          : "${_labelFor(winner!)} wins this round!")
                    : (xTurn
                          ? "Player X's turn"
                          : (vsComputer
                                ? 'Computer is thinking...'
                                : "Player O's turn")),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _Board(
                      board: board,
                      winningLine: winningLine,
                      onTap: _handleTap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  final int xWins;
  final int oWins;
  final int draws;
  final bool vsComputer;

  const _ScoreBoard({
    required this.xWins,
    required this.oWins,
    required this.draws,
    required this.vsComputer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ScoreChip(
          label: 'Player X',
          value: xWins,
          color: const Color(0xFF6C63FF),
        ),
        _ScoreChip(label: 'Draws', value: draws, color: Colors.white38),
        _ScoreChip(
          label: vsComputer ? 'Computer' : 'Player O',
          value: oWins,
          color: const Color(0xFFFF6584),
        ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white60),
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  final List<String> board;
  final List<int>? winningLine;
  final ValueChanged<int> onTap;

  const _Board({
    required this.board,
    required this.winningLine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final mark = board[index];
        final isWinning = winningLine?.contains(index) ?? false;
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isWinning
                  ? const Color(0xFF6C63FF).withOpacity(0.35)
                  : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isWinning ? const Color(0xFF6C63FF) : Colors.white10,
                width: isWinning ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                mark,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: mark == 'X'
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFFFF6584),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

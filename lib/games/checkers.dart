import 'dart:math';
import 'package:flutter/material.dart';

class CheckersApp extends StatelessWidget {
  const CheckersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.brown),
      home: const GameScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Core game model
// ---------------------------------------------------------------------------
//
// Board values:
//   0  -> empty
//   1  -> red man       (human, moves toward row 0)
//  -1  -> black man      (computer, moves toward row 7)
//   2  -> red king
//  -2  -> black king
//
// Players are represented by the sign: 1 = red (human), -1 = black (AI).

const int kHuman = 1;
const int kAI = -1;
const int kBoardSize = 8;

class Pos {
  final int row;
  final int col;
  const Pos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => row * 8 + col;
}

class Move {
  final List<Pos> path; // path[0] = origin, path.last = final destination
  final List<Pos> captured; // squares of captured pieces, in order

  Move(this.path, this.captured);

  Pos get from => path.first;
  Pos get to => path.last;
  bool get isCapture => captured.isNotEmpty;
}

List<List<int>> initialBoard() {
  final board = List.generate(
    kBoardSize,
    (_) => List<int>.filled(kBoardSize, 0),
  );
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < kBoardSize; c++) {
      if ((r + c) % 2 == 1) board[r][c] = kAI; // black men, top of board
    }
  }
  for (int r = 5; r < 8; r++) {
    for (int c = 0; c < kBoardSize; c++) {
      if ((r + c) % 2 == 1) board[r][c] = kHuman; // red men, bottom of board
    }
  }
  return board;
}

List<List<int>> _cloneBoard(List<List<int>> board) => [
  for (final row in board) List<int>.from(row),
];

bool _inBounds(Pos p) =>
    p.row >= 0 && p.row < kBoardSize && p.col >= 0 && p.col < kBoardSize;

int _sign(int v) => v == 0 ? 0 : (v > 0 ? 1 : -1);

bool _posInList(Pos p, List<Pos> list) => list.any((e) => e == p);

const List<Pos> _kingDirs = [Pos(-1, -1), Pos(-1, 1), Pos(1, -1), Pos(1, 1)];
const List<Pos> _redManDirs = [Pos(-1, -1), Pos(-1, 1)]; // red moves up
const List<Pos> _blackManDirs = [Pos(1, -1), Pos(1, 1)]; // black moves down

List<Pos> _dirsFor(int pieceVal, int player) {
  final isKing = pieceVal.abs() == 2;
  if (isKing) return _kingDirs;
  return player == kHuman ? _redManDirs : _blackManDirs;
}

/// Finds all capture sequences (including multi-jumps) starting from [pos].
List<Move> _capturesFrom(
  List<List<int>> board,
  Pos pos,
  int player,
  List<Pos> path,
  List<Pos> capturedSoFar,
) {
  final results = <Move>[];
  final pieceVal = board[path.first.row][path.first.col];
  final dirs = _dirsFor(pieceVal, player);
  bool foundFurther = false;

  for (final d in dirs) {
    final mid = Pos(pos.row + d.row, pos.col + d.col);
    final land = Pos(pos.row + 2 * d.row, pos.col + 2 * d.col);
    if (!_inBounds(land)) continue;
    if (_posInList(mid, capturedSoFar)) continue;
    final midVal = board[mid.row][mid.col];
    if (midVal == 0 || _sign(midVal) != -player) continue;
    if (board[land.row][land.col] != 0) continue;
    if (_posInList(land, path)) continue;

    foundFurther = true;
    final newPath = [...path, land];
    final newCaptured = [...capturedSoFar, mid];
    results.addAll(_capturesFrom(board, land, player, newPath, newCaptured));
  }

  if (!foundFurther && capturedSoFar.isNotEmpty) {
    results.add(Move(path, capturedSoFar));
  }
  return results;
}

List<Move> _simpleMovesFrom(List<List<int>> board, Pos pos, int player) {
  final moves = <Move>[];
  final pieceVal = board[pos.row][pos.col];
  final dirs = _dirsFor(pieceVal, player);
  for (final d in dirs) {
    final dest = Pos(pos.row + d.row, pos.col + d.col);
    if (!_inBounds(dest)) continue;
    if (board[dest.row][dest.col] == 0) {
      moves.add(Move([pos, dest], const []));
    }
  }
  return moves;
}

/// Generates every legal move for [player]. If any capture is available,
/// only capture moves are returned (captures are mandatory).
List<Move> generateAllMoves(List<List<int>> board, int player) {
  final captureMoves = <Move>[];
  final simpleMoves = <Move>[];

  for (int r = 0; r < kBoardSize; r++) {
    for (int c = 0; c < kBoardSize; c++) {
      final val = board[r][c];
      if (val == 0 || _sign(val) != player) continue;
      final pos = Pos(r, c);
      captureMoves.addAll(_capturesFrom(board, pos, player, [pos], []));
      simpleMoves.addAll(_simpleMovesFrom(board, pos, player));
    }
  }

  return captureMoves.isNotEmpty ? captureMoves : simpleMoves;
}

List<List<int>> applyMove(List<List<int>> board, Move move) {
  final newBoard = _cloneBoard(board);
  final from = move.from;
  final to = move.to;
  final val = newBoard[from.row][from.col];
  final player = _sign(val);
  final wasKing = val.abs() == 2;

  for (final cap in move.captured) {
    newBoard[cap.row][cap.col] = 0;
  }
  newBoard[from.row][from.col] = 0;

  final reachedBackRow =
      (player == kHuman && to.row == 0) || (player == kAI && to.row == 7);
  final finalVal = wasKing
      ? val
      : (reachedBackRow ? (player == kHuman ? 2 : -2) : val);

  newBoard[to.row][to.col] = finalVal;
  return newBoard;
}

int evaluateBoard(List<List<int>> board) {
  int score = 0;
  for (int r = 0; r < kBoardSize; r++) {
    for (int c = 0; c < kBoardSize; c++) {
      final val = board[r][c];
      switch (val) {
        case -1:
          score += 100 + r * 4; // encourage advancing toward row 7
          break;
        case -2:
          score += 160;
          break;
        case 1:
          score -= 100 + (7 - r) * 4; // encourage advancing toward row 0
          break;
        case 2:
          score -= 160;
          break;
      }
    }
  }
  return score;
}

int _minimax(
  List<List<int>> board,
  int depth,
  int player,
  int alpha,
  int beta,
) {
  final moves = generateAllMoves(board, player);
  if (moves.isEmpty) {
    // Current player has no legal moves: they lose.
    return player == kAI ? -100000 : 100000;
  }
  if (depth == 0) return evaluateBoard(board);

  if (player == kAI) {
    int maxEval = -1000000;
    for (final m in moves) {
      final newBoard = applyMove(board, m);
      final eval = _minimax(newBoard, depth - 1, kHuman, alpha, beta);
      if (eval > maxEval) maxEval = eval;
      if (maxEval > alpha) alpha = maxEval;
      if (beta <= alpha) break;
    }
    return maxEval;
  } else {
    int minEval = 1000000;
    for (final m in moves) {
      final newBoard = applyMove(board, m);
      final eval = _minimax(newBoard, depth - 1, kAI, alpha, beta);
      if (eval < minEval) minEval = eval;
      if (minEval < beta) beta = minEval;
      if (beta <= alpha) break;
    }
    return minEval;
  }
}

/// Picks the best move for the AI using minimax with alpha-beta pruning.
Move? findBestMove(List<List<int>> board, int player, int depth) {
  final moves = generateAllMoves(board, player);
  if (moves.isEmpty) return null;

  Move? best;
  int bestVal = -1000000;
  int alpha = -1000000;
  const beta = 1000000;

  // Small randomization among equally-good moves keeps the AI from being
  // perfectly predictable when several moves score the same.
  final rnd = Random();
  final shuffled = [...moves]..shuffle(rnd);

  for (final m in shuffled) {
    final newBoard = applyMove(board, m);
    final val = _minimax(newBoard, depth - 1, kHuman, alpha, beta);
    if (val > bestVal) {
      bestVal = val;
      best = m;
    }
    if (bestVal > alpha) alpha = bestVal;
  }
  return best ?? shuffled.first;
}

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int aiDepth = 5; // increase for a stronger (slower) AI

  late List<List<int>> board;
  int currentPlayer = kHuman;
  Pos? selected;
  List<Move> movesThisTurn = [];
  List<Move> selectedMoves = [];
  bool aiThinking = false;
  bool gameOver = false;
  int? winner; // kHuman, kAI, or null

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = initialBoard();
      currentPlayer = kHuman;
      selected = null;
      selectedMoves = [];
      aiThinking = false;
      gameOver = false;
      winner = null;
      movesThisTurn = generateAllMoves(board, currentPlayer);
    });
  }

  void _startTurn() {
    final moves = generateAllMoves(board, currentPlayer);
    if (moves.isEmpty) {
      setState(() {
        gameOver = true;
        winner = -currentPlayer;
      });
      return;
    }
    setState(() {
      movesThisTurn = moves;
    });
    if (currentPlayer == kAI) {
      _runAiMove();
    }
  }

  Future<void> _runAiMove() async {
    setState(() => aiThinking = true);
    // Small delay so the "thinking" state is visible and the UI stays smooth.
    await Future.delayed(const Duration(milliseconds: 400));
    final move = findBestMove(board, kAI, aiDepth);
    if (!mounted) return;
    if (move == null) {
      setState(() {
        aiThinking = false;
        gameOver = true;
        winner = kHuman;
      });
      return;
    }
    setState(() {
      board = applyMove(board, move);
      currentPlayer = kHuman;
      aiThinking = false;
    });
    _startTurn();
  }

  void _onCellTap(int row, int col) {
    if (currentPlayer != kHuman || aiThinking || gameOver) return;
    final pos = Pos(row, col);
    final val = board[row][col];

    if (selected == null) {
      if (val != 0 && _sign(val) == kHuman) {
        final myMoves = movesThisTurn.where((m) => m.from == pos).toList();
        if (myMoves.isNotEmpty) {
          setState(() {
            selected = pos;
            selectedMoves = myMoves;
          });
        }
      }
      return;
    }

    if (pos == selected) {
      setState(() {
        selected = null;
        selectedMoves = [];
      });
      return;
    }

    final match = selectedMoves.where((m) => m.to == pos).toList();
    if (match.isNotEmpty) {
      final move = match.first;
      setState(() {
        board = applyMove(board, move);
        currentPlayer = kAI;
        selected = null;
        selectedMoves = [];
      });
      _startTurn();
      return;
    }

    if (val != 0 && _sign(val) == kHuman) {
      final myMoves = movesThisTurn.where((m) => m.from == pos).toList();
      if (myMoves.isNotEmpty) {
        setState(() {
          selected = pos;
          selectedMoves = myMoves;
        });
      }
    }
  }

  String get _statusText {
    if (gameOver) {
      if (winner == kHuman) return 'You win! 🎉';
      if (winner == kAI) return 'Computer wins.';
      return 'Game over.';
    }
    if (aiThinking) return 'Computer is thinking…';
    if (currentPlayer == kHuman) {
      final forcedCapture =
          movesThisTurn.isNotEmpty && movesThisTurn.first.isCapture;
      return forcedCapture ? 'Your turn — capture available!' : 'Your turn';
    }
    return "Computer's turn";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkers'),
        actions: [
          IconButton(
            tooltip: 'New game',
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(_statusText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildBoard(),
                  ),
                ),
              ),
            ),
            _buildLegend(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown.shade900, width: 4),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kBoardSize * kBoardSize,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: kBoardSize,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ kBoardSize;
          final col = index % kBoardSize;
          return _buildCell(row, col);
        },
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final pos = Pos(row, col);
    final isDark = (row + col) % 2 == 1;
    final val = board[row][col];
    final isSelected = selected == pos;
    final isDestination = selectedMoves.any((m) => m.to == pos);

    Color bg = isDark ? const Color(0xFF7B4A2B) : const Color(0xFFEFD9B4);
    if (isSelected) bg = Colors.yellow.shade600;

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        color: bg,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isDestination)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            if (val != 0) _buildPiece(val),
          ],
        ),
      ),
    );
  }

  Widget _buildPiece(int val) {
    final isRed = val > 0;
    final isKing = val.abs() == 2;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isRed
                ? [Colors.red.shade400, Colors.red.shade900]
                : [Colors.grey.shade800, Colors.black],
          ),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: isKing
            ? const Center(
                child: Icon(Icons.star, color: Colors.amberAccent, size: 20),
              )
            : null,
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.red.shade700, 'You'),
        const SizedBox(width: 24),
        _legendDot(Colors.black, 'Computer'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

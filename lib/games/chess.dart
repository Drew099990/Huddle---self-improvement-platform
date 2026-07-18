import 'package:flutter/material.dart';
import 'chess_engine.dart';
import 'chess_ai.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown, useMaterial3: true),
      home: const ChessGamePage(),
    );
  }
}

class ChessGamePage extends StatefulWidget {
  const ChessGamePage({super.key});

  @override
  State<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends State<ChessGamePage> {
  late ChessEngine engine;
  final ChessAI ai = ChessAI(depth: 2);

  int? selectedRow, selectedCol;
  List<Move> selectedMoves = [];
  bool isThinking = false;
  String statusMessage = "Your move (White)";

  final PieceColor humanColor = PieceColor.white;
  final PieceColor aiColorPlayer = PieceColor.black;

  @override
  void initState() {
    super.initState();
    engine = ChessEngine();
  }

  void _restart() {
    setState(() {
      engine = ChessEngine();
      selectedRow = null;
      selectedCol = null;
      selectedMoves = [];
      isThinking = false;
      statusMessage = "Your move (White)";
    });
  }

  void _onSquareTap(int r, int c) {
    if (isThinking || engine.turn != humanColor) return;

    if (selectedRow == null) {
      final piece = engine.at(r, c);
      if (piece != null && piece.color == humanColor) {
        setState(() {
          selectedRow = r;
          selectedCol = c;
          selectedMoves = engine.legalMovesForPiece(r, c);
        });
      }
      return;
    }

    final move = selectedMoves.where((m) => m.toRow == r && m.toCol == c);
    if (move.isNotEmpty) {
      setState(() {
        engine.makeMove(move.first);
        selectedRow = null;
        selectedCol = null;
        selectedMoves = [];
      });
      _checkGameStatus();
      if (!engine.isCheckmate && !engine.isStalemate) {
        _makeAIMove();
      }
      return;
    }

    // Tapped somewhere else: either switch selection or clear it.
    final piece = engine.at(r, c);
    if (piece != null && piece.color == humanColor) {
      setState(() {
        selectedRow = r;
        selectedCol = c;
        selectedMoves = engine.legalMovesForPiece(r, c);
      });
    } else {
      setState(() {
        selectedRow = null;
        selectedCol = null;
        selectedMoves = [];
      });
    }
  }

  Future<void> _makeAIMove() async {
    setState(() {
      isThinking = true;
      statusMessage = "Computer is thinking...";
    });

    // Small delay so the UI can update before the (synchronous) search runs.
    await Future.delayed(const Duration(milliseconds: 250));
    final move = ai.findBestMove(engine, aiColorPlayer);

    if (!mounted) return;
    if (move != null) {
      setState(() {
        engine.makeMove(move);
        isThinking = false;
      });
    } else {
      setState(() => isThinking = false);
    }
    _checkGameStatus();
  }

  void _checkGameStatus() {
    if (engine.isCheckmate) {
      final winner = engine.turn == PieceColor.white ? "Black" : "White";
      setState(() => statusMessage = "Checkmate! $winner wins.");
    } else if (engine.isStalemate) {
      setState(() => statusMessage = "Stalemate! It's a draw.");
    } else if (engine.isInCheck(engine.turn, engine.board)) {
      final side = engine.turn == PieceColor.white ? "White" : "Black";
      setState(() => statusMessage = "$side is in check!");
    } else {
      setState(() {
        statusMessage = engine.turn == humanColor
            ? "Your move (White)"
            : "Computer's move";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess vs Computer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New game',
            onPressed: _restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isThinking)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Text(
                    statusMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildBoard(),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'You play White. Tap a piece, then tap a highlighted square to move.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final r = index ~/ 8;
        final c = index % 8;
        final piece = engine.at(r, c);
        final isLight = (r + c) % 2 == 0;
        final isSelected = selectedRow == r && selectedCol == c;
        final isLegalMove = selectedMoves.any(
          (m) => m.toRow == r && m.toCol == c,
        );

        Color squareColor = isLight
            ? const Color(0xFFEEEED2)
            : const Color(0xFF769656);
        if (isSelected) squareColor = const Color(0xFFF6F669);

        return GestureDetector(
          onTap: () => _onSquareTap(r, c),
          child: Container(
            color: squareColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (piece != null)
                  Text(
                    piece.symbol,
                    style: TextStyle(
                      fontSize: 32,
                      color: piece.color == PieceColor.white
                          ? Colors.white
                          : Colors.black,
                      shadows: piece.color == PieceColor.white
                          ? [const Shadow(color: Colors.black45, blurRadius: 2)]
                          : [],
                    ),
                  ),
                if (isLegalMove)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

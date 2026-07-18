import 'dart:math';
import 'chess_engine.dart';

/// A simple minimax AI with alpha-beta pruning and a material + center-control
/// evaluation function. Depth 2-3 plays reasonably and stays fast on device.
class ChessAI {
  final int depth;
  ChessAI({this.depth = 2});

  static const Map<PieceType, int> pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  int evaluateBoard(Board board, PieceColor aiColor) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null) {
          int value = pieceValues[p.type]!;
          final centerBonus = (3.5 - (r - 3.5).abs()) + (3.5 - (c - 3.5).abs());
          value += (centerBonus * 2).round();
          score += (p.color == aiColor) ? value : -value;
        }
      }
    }
    return score;
  }

  /// Picks the best move for [aiColor] using minimax search.
  Move? findBestMove(ChessEngine engine, PieceColor aiColor) {
    final moves = engine.allLegalMoves(aiColor);
    if (moves.isEmpty) return null;
    moves.shuffle(Random()); // vary play among equally-good moves

    Move? bestMove;
    int bestScore = -1000000;
    for (final move in moves) {
      final newBoard = engine.applyMove(engine.board, move);
      final score = _minimax(
          engine, newBoard, depth - 1, false, aiColor, -1000000, 1000000);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove ?? moves.first;
  }

  int _minimax(ChessEngine engine, Board board, int depthLeft, bool maximizing,
      PieceColor aiColor, int alpha, int beta) {
    final currentColor = maximizing
        ? aiColor
        : (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white);

    if (depthLeft == 0) {
      return evaluateBoard(board, aiColor);
    }

    final moves = engine.allLegalMoves(currentColor, board);
    if (moves.isEmpty) {
      if (engine.isInCheck(currentColor, board)) {
        // Being checkmated is very bad for whoever is "currentColor".
        return maximizing ? -100000 - depthLeft : 100000 + depthLeft;
      }
      return 0; // stalemate
    }

    if (maximizing) {
      int maxEval = -1000000;
      for (final move in moves) {
        final newBoard = engine.applyMove(board, move);
        final eval = _minimax(
            engine, newBoard, depthLeft - 1, false, aiColor, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (final move in moves) {
        final newBoard = engine.applyMove(board, move);
        final eval = _minimax(
            engine, newBoard, depthLeft - 1, true, aiColor, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }
}

/// Core chess rules: board representation, move generation, check/checkmate
/// detection. Deliberately simplified (no castling / en passant) to keep the
/// engine easy to follow, while still enforcing legal, non-self-check moves.
library chess_engine;

enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

class ChessPiece {
  PieceType type;
  PieceColor color;
  bool hasMoved;

  ChessPiece(this.type, this.color, {this.hasMoved = false});

  ChessPiece copy() => ChessPiece(type, color, hasMoved: hasMoved);

  /// Unicode glyph used to render the piece.
  String get symbol {
    const whiteSymbols = {
      PieceType.king: '♔',
      PieceType.queen: '♕',
      PieceType.rook: '♖',
      PieceType.bishop: '♗',
      PieceType.knight: '♘',
      PieceType.pawn: '♙',
    };
    const blackSymbols = {
      PieceType.king: '♚',
      PieceType.queen: '♛',
      PieceType.rook: '♜',
      PieceType.bishop: '♝',
      PieceType.knight: '♞',
      PieceType.pawn: '♟',
    };
    return color == PieceColor.white ? whiteSymbols[type]! : blackSymbols[type]!;
  }
}

class Move {
  final int fromRow, fromCol, toRow, toCol;
  final ChessPiece? captured;
  final bool isPromotion;

  Move(this.fromRow, this.fromCol, this.toRow, this.toCol,
      {this.captured, this.isPromotion = false});
}

typedef Board = List<List<ChessPiece?>>;

Board createInitialBoard() {
  final board = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
  const order = [
    PieceType.rook,
    PieceType.knight,
    PieceType.bishop,
    PieceType.queen,
    PieceType.king,
    PieceType.bishop,
    PieceType.knight,
    PieceType.rook,
  ];
  for (int c = 0; c < 8; c++) {
    board[0][c] = ChessPiece(order[c], PieceColor.black);
    board[1][c] = ChessPiece(PieceType.pawn, PieceColor.black);
    board[6][c] = ChessPiece(PieceType.pawn, PieceColor.white);
    board[7][c] = ChessPiece(order[c], PieceColor.white);
  }
  return board;
}

Board copyBoard(Board board) {
  return board.map((row) => row.map((p) => p?.copy()).toList()).toList();
}

bool inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

class ChessEngine {
  Board board;
  PieceColor turn = PieceColor.white;
  final List<Move> moveHistory = [];

  ChessEngine() : board = createInitialBoard();

  ChessPiece? at(int r, int c) => board[r][c];

  /// Pseudo-legal moves for the piece at (r,c) on [engine.board] — i.e. moves
  /// that follow piece movement rules but may leave the king in check.
  List<Move> pseudoLegalMoves(int r, int c) => _pseudoLegalMovesOnBoard(r, c, board);

  List<Move> _pseudoLegalMovesOnBoard(int r, int c, Board b) {
    final piece = b[r][c];
    if (piece == null) return [];
    final moves = <Move>[];

    void addIfValid(int nr, int nc) {
      if (!inBounds(nr, nc)) return;
      final target = b[nr][nc];
      if (target == null || target.color != piece.color) {
        moves.add(Move(r, c, nr, nc, captured: target));
      }
    }

    switch (piece.type) {
      case PieceType.pawn:
        final dir = piece.color == PieceColor.white ? -1 : 1;
        final startRow = piece.color == PieceColor.white ? 6 : 1;
        if (inBounds(r + dir, c) && b[r + dir][c] == null) {
          final promo = (r + dir == 0 || r + dir == 7);
          moves.add(Move(r, c, r + dir, c, isPromotion: promo));
          if (r == startRow && b[r + 2 * dir][c] == null) {
            moves.add(Move(r, c, r + 2 * dir, c));
          }
        }
        for (final dc in [-1, 1]) {
          final nr = r + dir, nc = c + dc;
          if (inBounds(nr, nc) && b[nr][nc] != null && b[nr][nc]!.color != piece.color) {
            final promo = (nr == 0 || nr == 7);
            moves.add(Move(r, c, nr, nc, captured: b[nr][nc], isPromotion: promo));
          }
        }
        break;
      case PieceType.knight:
        const deltas = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1],
        ];
        for (final d in deltas) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
      case PieceType.bishop:
        _slideMoves(r, c, piece, [[-1, -1], [-1, 1], [1, -1], [1, 1]], moves, b);
        break;
      case PieceType.rook:
        _slideMoves(r, c, piece, [[-1, 0], [1, 0], [0, -1], [0, 1]], moves, b);
        break;
      case PieceType.queen:
        _slideMoves(
            r,
            c,
            piece,
            [[-1, -1], [-1, 1], [1, -1], [1, 1], [-1, 0], [1, 0], [0, -1], [0, 1]],
            moves,
            b);
        break;
      case PieceType.king:
        const deltas = [
          [-1, -1], [-1, 0], [-1, 1], [0, -1],
          [0, 1], [1, -1], [1, 0], [1, 1],
        ];
        for (final d in deltas) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
    }
    return moves;
  }

  void _slideMoves(
      int r, int c, ChessPiece piece, List<List<int>> dirs, List<Move> moves, Board b) {
    for (final d in dirs) {
      int nr = r + d[0], nc = c + d[1];
      while (inBounds(nr, nc)) {
        final target = b[nr][nc];
        if (target == null) {
          moves.add(Move(r, c, nr, nc));
        } else {
          if (target.color != piece.color) {
            moves.add(Move(r, c, nr, nc, captured: target));
          }
          break;
        }
        nr += d[0];
        nc += d[1];
      }
    }
  }

  List<int>? findKing(PieceColor color, Board b) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = b[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          return [r, c];
        }
      }
    }
    return null;
  }

  bool isSquareAttacked(int r, int c, PieceColor byColor, Board b) {
    for (int rr = 0; rr < 8; rr++) {
      for (int cc = 0; cc < 8; cc++) {
        final p = b[rr][cc];
        if (p != null && p.color == byColor) {
          if (_attacksSquare(rr, cc, r, c, p, b)) return true;
        }
      }
    }
    return false;
  }

  bool _attacksSquare(int r, int c, int tr, int tc, ChessPiece piece, Board b) {
    switch (piece.type) {
      case PieceType.pawn:
        final dir = piece.color == PieceColor.white ? -1 : 1;
        return (r + dir == tr) && (c - 1 == tc || c + 1 == tc);
      case PieceType.knight:
        final dr = (r - tr).abs(), dc = (c - tc).abs();
        return (dr == 2 && dc == 1) || (dr == 1 && dc == 2);
      case PieceType.bishop:
        return _slideAttacks(r, c, tr, tc, b, diagonal: true);
      case PieceType.rook:
        return _slideAttacks(r, c, tr, tc, b, straight: true);
      case PieceType.queen:
        return _slideAttacks(r, c, tr, tc, b, diagonal: true, straight: true);
      case PieceType.king:
        return (r - tr).abs() <= 1 && (c - tc).abs() <= 1;
    }
  }

  bool _slideAttacks(int r, int c, int tr, int tc, Board b,
      {bool diagonal = false, bool straight = false}) {
    final dirs = <List<int>>[];
    if (diagonal) dirs.addAll([[-1, -1], [-1, 1], [1, -1], [1, 1]]);
    if (straight) dirs.addAll([[-1, 0], [1, 0], [0, -1], [0, 1]]);
    for (final d in dirs) {
      int nr = r + d[0], nc = c + d[1];
      while (inBounds(nr, nc)) {
        if (nr == tr && nc == tc) return true;
        if (b[nr][nc] != null) break;
        nr += d[0];
        nc += d[1];
      }
    }
    return false;
  }

  bool isInCheck(PieceColor color, Board b) {
    final kingPos = findKing(color, b);
    if (kingPos == null) return false;
    final opponent = color == PieceColor.white ? PieceColor.black : PieceColor.white;
    return isSquareAttacked(kingPos[0], kingPos[1], opponent, b);
  }

  /// Returns a *new* board with [move] applied (does not mutate [b]).
  Board applyMove(Board b, Move move) {
    final newBoard = copyBoard(b);
    final piece = newBoard[move.fromRow][move.fromCol];
    if (piece == null) return newBoard;
    piece.hasMoved = true;
    if (move.isPromotion) {
      newBoard[move.toRow][move.toCol] = ChessPiece(PieceType.queen, piece.color, hasMoved: true);
    } else {
      newBoard[move.toRow][move.toCol] = piece;
    }
    newBoard[move.fromRow][move.fromCol] = null;
    return newBoard;
  }

  /// Legal moves for the piece at (r,c): pseudo-legal moves that don't leave
  /// the mover's own king in check.
  List<Move> legalMovesForPiece(int r, int c) {
    final piece = board[r][c];
    if (piece == null) return [];
    final pseudo = pseudoLegalMoves(r, c);
    return pseudo.where((m) {
      final newBoard = applyMove(board, m);
      return !isInCheck(piece.color, newBoard);
    }).toList();
  }

  /// All legal moves for [color] on [b] (defaults to the live board). Used by
  /// both the UI (via legalMovesForPiece) and the AI's search.
  List<Move> allLegalMoves(PieceColor color, [Board? b]) {
    final useBoard = b ?? board;
    final all = <Move>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = useBoard[r][c];
        if (piece != null && piece.color == color) {
          final pseudo = _pseudoLegalMovesOnBoard(r, c, useBoard);
          for (final m in pseudo) {
            final newBoard = applyMove(useBoard, m);
            if (!isInCheck(color, newBoard)) {
              all.add(m);
            }
          }
        }
      }
    }
    return all;
  }

  bool get isCheckmate => isInCheck(turn, board) && allLegalMoves(turn).isEmpty;

  bool get isStalemate => !isInCheck(turn, board) && allLegalMoves(turn).isEmpty;

  void makeMove(Move move) {
    board = applyMove(board, move);
    moveHistory.add(move);
    turn = turn == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}

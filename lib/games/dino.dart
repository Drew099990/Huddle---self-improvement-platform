import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DinoJumpApp extends StatelessWidget {
  const DinoJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Jump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
      ),
      home: const GameScreen(),
    );
  }
}

enum GameStatus { ready, playing, gameOver }

enum ObstacleType { cactusSmall, cactusTall, cactusCluster }

class Obstacle {
  double x;
  final double width;
  final double height;
  final ObstacleType type;
  Obstacle({
    required this.x,
    required this.width,
    required this.height,
    required this.type,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  GameStatus _status = GameStatus.ready;

  // Player physics
  static const double groundHeight = 60;
  static const double dinoWidth = 44;
  static const double dinoHeight = 46;
  static const double dinoX = 50;
  static const double gravity = -2900; // px/s^2
  static const double jumpSpeed = 980; // px/s

  double _dinoBottom = 0; // distance above ground
  double _velocityY = 0;
  bool get _onGround => _dinoBottom <= 0;

  // Running animation
  double _legTimer = 0;
  bool _legFrameA = true;

  // World
  double _speed = 320; // px/s, obstacle scroll speed
  final List<Obstacle> _obstacles = [];
  final Random _random = Random();
  double _distanceSinceSpawn = 0;
  double _nextSpawnDistance = 0;
  double _groundScroll = 0;

  double _score = 0;
  double _bestScore = 0;
  bool _nightMode = false;
  double _lastNightToggleScore = 0;

  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _rollNextSpawnDistance();
  }

  void _rollNextSpawnDistance() {
    _nextSpawnDistance = 220 + _random.nextDouble() * 220;
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (_status != GameStatus.playing) return;
    if (dt <= 0 || dt > 0.05) {
      // Skip huge jumps (e.g. after a pause) to avoid tunneling.
      setState(() {});
      return;
    }

    setState(() {
      // Dino physics
      _velocityY += gravity * dt;
      _dinoBottom += _velocityY * dt;
      if (_dinoBottom <= 0) {
        _dinoBottom = 0;
        _velocityY = 0;
      }

      // Difficulty ramps up slowly with score
      _speed = 320 + min(_score, 420);

      // Running leg animation (only while grounded)
      if (_onGround) {
        _legTimer += dt;
        if (_legTimer > 0.14) {
          _legTimer = 0;
          _legFrameA = !_legFrameA;
        }
      }

      // Scroll ground dashes
      _groundScroll = (_groundScroll + _speed * dt) % 60;

      // Move obstacles
      for (final o in _obstacles) {
        o.x -= _speed * dt;
      }
      _obstacles.removeWhere((o) => o.x + o.width < 0);

      // Spawn obstacles
      _distanceSinceSpawn += _speed * dt;
      if (_distanceSinceSpawn >= _nextSpawnDistance) {
        _distanceSinceSpawn = 0;
        _rollNextSpawnDistance();
        _obstacles.add(_spawnObstacle());
      }

      // Score by distance travelled
      _score += _speed * dt * 0.01;

      // Toggle night mode every ~300 points, like the classic game
      if (_score - _lastNightToggleScore > 300) {
        _lastNightToggleScore = _score;
        _nightMode = !_nightMode;
      }

      // Collision detection (slightly inset hitbox feels fairer)
      final dinoRect = Rect.fromLTWH(
        dinoX + 6,
        _size.height - groundHeight - dinoHeight - _dinoBottom + 4,
        dinoWidth - 12,
        dinoHeight - 8,
      );
      for (final o in _obstacles) {
        final obstacleRect = Rect.fromLTWH(
          o.x + 3,
          _size.height - groundHeight - o.height,
          o.width - 6,
          o.height,
        );
        if (dinoRect.overlaps(obstacleRect)) {
          _endGame();
          break;
        }
      }
    });
  }

  Obstacle _spawnObstacle() {
    final roll = _random.nextDouble();
    ObstacleType type;
    double w, h;
    if (roll < 0.4) {
      type = ObstacleType.cactusSmall;
      w = 20;
      h = 34;
    } else if (roll < 0.75) {
      type = ObstacleType.cactusTall;
      w = 24;
      h = 50;
    } else {
      type = ObstacleType.cactusCluster;
      w = 46;
      h = 38;
    }
    return Obstacle(x: _size.width + w, width: w, height: h, type: type);
  }

  void _endGame() {
    _status = GameStatus.gameOver;
    _ticker.stop();
    if (_score > _bestScore) _bestScore = _score;
  }

  void _startGame() {
    setState(() {
      _status = GameStatus.playing;
      _obstacles.clear();
      _dinoBottom = 0;
      _velocityY = 0;
      _speed = 320;
      _score = 0;
      _distanceSinceSpawn = 0;
      _legTimer = 0;
      _legFrameA = true;
      _nightMode = false;
      _lastNightToggleScore = 0;
      _rollNextSpawnDistance();
    });
    _lastElapsed = Duration.zero;
    _ticker.stop();
    _ticker.start();
  }

  void _jump() {
    if (_status == GameStatus.playing && _onGround) {
      _velocityY = jumpSpeed;
    }
  }

  void _handleTap() {
    switch (_status) {
      case GameStatus.ready:
        _startGame();
        break;
      case GameStatus.playing:
        _jump();
        break;
      case GameStatus.gameOver:
        _startGame();
        break;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _nightMode ? const Color(0xFF222226) : const Color(0xFFF7F7F7);
    final fg = _nightMode ? const Color(0xFFF7F7F7) : const Color(0xFF535353);
    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: Stack(
              children: [
                CustomPaint(
                  size: _size,
                  painter: _GamePainter(
                    dinoBottom: _dinoBottom,
                    dinoWidth: dinoWidth,
                    dinoHeight: dinoHeight,
                    dinoX: dinoX,
                    groundHeight: groundHeight,
                    groundScroll: _groundScroll,
                    obstacles: _obstacles,
                    legFrameA: _legFrameA,
                    onGround: _onGround,
                    foreground: fg,
                    background: bg,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'HI ${_bestScore.toInt().toString().padLeft(5, '0')}',
                        style: TextStyle(
                          color: fg.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _score.toInt().toString().padLeft(5, '0'),
                        style: TextStyle(
                          color: fg,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                if (_status == GameStatus.ready)
                  _buildOverlay(
                    fg: fg,
                    title: 'DINO JUMP',
                    subtitle: 'Tap to start\nTap to jump over the cacti',
                  ),
                if (_status == GameStatus.gameOver)
                  _buildOverlay(
                    fg: fg,
                    title: 'G A M E   O V E R',
                    subtitle: 'Score: ${_score.toInt()}\nTap to play again',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlay({
    required Color fg,
    required String title,
    required String subtitle,
  }) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: fg,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                color: fg.withOpacity(0.8),
                fontSize: 15,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final double dinoBottom;
  final double dinoWidth;
  final double dinoHeight;
  final double dinoX;
  final double groundHeight;
  final double groundScroll;
  final List<Obstacle> obstacles;
  final bool legFrameA;
  final bool onGround;
  final Color foreground;
  final Color background;

  _GamePainter({
    required this.dinoBottom,
    required this.dinoWidth,
    required this.dinoHeight,
    required this.dinoX,
    required this.groundHeight,
    required this.groundScroll,
    required this.obstacles,
    required this.legFrameA,
    required this.onGround,
    required this.foreground,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final groundY = size.height - groundHeight;
    final fgPaint = Paint()..color = foreground;

    // Ground line
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      fgPaint..strokeWidth = 2.5,
    );

    // Scrolling dashes below the line for a sense of motion
    final dashPaint = Paint()
      ..color = foreground.withOpacity(0.6)
      ..strokeWidth = 2;
    for (double x = -groundScroll; x < size.width; x += 60) {
      canvas.drawLine(
        Offset(x, groundY + 8),
        Offset(x + 24, groundY + 8),
        dashPaint,
      );
    }
    for (double x = -groundScroll + 30; x < size.width; x += 90) {
      canvas.drawCircle(Offset(x, groundY + 16), 1.6, dashPaint);
    }

    // Dino
    _drawDino(canvas, groundY);

    // Obstacles (cacti)
    for (final o in obstacles) {
      _drawCactus(canvas, o, groundY);
    }
  }

  void _drawDino(Canvas canvas, double groundY) {
    final paint = Paint()..color = foreground;
    final baseTop = groundY - dinoHeight - dinoBottom;

    final body = Path();
    // Simple blocky dino silhouette (body + head + tail), pixel-art style.
    body.addRect(
      Rect.fromLTWH(dinoX + 8, baseTop, dinoWidth - 14, dinoHeight - 14),
    );
    // Head
    body.addRect(Rect.fromLTWH(dinoX + dinoWidth - 20, baseTop - 10, 20, 16));
    // Snout bump
    body.addRect(Rect.fromLTWH(dinoX + dinoWidth - 6, baseTop - 4, 8, 8));
    // Tail
    body.addRect(Rect.fromLTWH(dinoX, baseTop + 4, 10, 10));
    canvas.drawPath(body, paint);

    // Eye (background-colored dot to punch through)
    final eyePaint = Paint()..color = background;
    canvas.drawRect(
      Rect.fromLTWH(dinoX + dinoWidth - 10, baseTop - 6, 4, 4),
      eyePaint,
    );

    // Legs: alternate frames while grounded, tucked while airborne
    final legY = baseTop + dinoHeight - 14;
    if (!onGround) {
      // tucked single leg while jumping
      canvas.drawRect(Rect.fromLTWH(dinoX + 16, legY, 8, 14), paint);
    } else if (legFrameA) {
      canvas.drawRect(Rect.fromLTWH(dinoX + 10, legY, 7, 14), paint);
      canvas.drawRect(Rect.fromLTWH(dinoX + 24, legY, 7, 10), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(dinoX + 10, legY, 7, 10), paint);
      canvas.drawRect(Rect.fromLTWH(dinoX + 24, legY, 7, 14), paint);
    }
  }

  void _drawCactus(Canvas canvas, Obstacle o, double groundY) {
    final paint = Paint()..color = foreground;
    final top = groundY - o.height;

    switch (o.type) {
      case ObstacleType.cactusSmall:
      case ObstacleType.cactusTall:
        final stalkWidth = o.width * 0.4;
        final stalkX = o.x + (o.width - stalkWidth) / 2;
        canvas.drawRect(
          Rect.fromLTWH(stalkX, top, stalkWidth, o.height),
          paint,
        );
        // arms
        canvas.drawRect(
          Rect.fromLTWH(
            o.x,
            top + o.height * 0.3,
            stalkWidth * 0.8,
            stalkWidth,
          ),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            o.x + o.width - stalkWidth * 0.8,
            top + o.height * 0.5,
            stalkWidth * 0.8,
            stalkWidth,
          ),
          paint,
        );
        break;
      case ObstacleType.cactusCluster:
        final segWidth = o.width / 3;
        for (int i = 0; i < 3; i++) {
          final h = o.height * (i == 1 ? 1.0 : 0.7);
          canvas.drawRect(
            Rect.fromLTWH(
              o.x + i * segWidth + segWidth * 0.15,
              groundY - h,
              segWidth * 0.7,
              h,
            ),
            paint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}

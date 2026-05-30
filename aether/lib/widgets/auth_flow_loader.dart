// Small utility that displays an ultra-mini 5x5 pixel snake loader used during
// auth or background flows. Exported helper `runWithAuthFlowLoader` wraps an
// action and shows a blocking dialog while the action completes.
import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// ===============================
/// 🔥 WRAPPER
/// ===============================
Future<T> runWithAuthFlowLoader<T>({
  required BuildContext context,
  required String message,
  required Future<T> Function() action,
}) async {
  BuildContext? dialogContext;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.12),
    pageBuilder: (ctx, _, __) {
      dialogContext = ctx;
      return _SnakeLoader(message: message);
    },
  );

  try {
    final result = await action();
    // Maintain a minimum display time for visual weight
    await Future.delayed(const Duration(milliseconds: 1000)); 
    return result;
  } finally {
    if (dialogContext != null) {
      Navigator.of(dialogContext!, rootNavigator: true).pop();
    }
  }
}

Future<void> pushWithSnakeLoader(
  BuildContext context,
  Widget page, {
  Duration displayDuration = const Duration(milliseconds: 450),
}) async {
  if (!context.mounted) {
    return;
  }

  final navigator = Navigator.of(context);
  BuildContext? dialogContext;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.08),
    pageBuilder: (ctx, _, __) {
      dialogContext = ctx;
      return const _SnakeLoader(message: 'Loading');
    },
  );

  await Future.delayed(displayDuration);

  if (dialogContext != null) {
    final rootNavigator = Navigator.of(dialogContext!, rootNavigator: true);
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }
  }

  if (!context.mounted) {
    return;
  }

  await navigator.push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}

class SnakeLoadingIndicator extends StatefulWidget {
  const SnakeLoadingIndicator({super.key});

  @override
  State<SnakeLoadingIndicator> createState() => _SnakeLoadingIndicatorState();
}

class _SnakeLoadingIndicatorState extends State<SnakeLoadingIndicator> {
  static const int gridSize = 5;
  late Point<int> food;
  late List<Point<int>> snake;
  late Timer timer;
  final random = Random();

  @override
  void initState() {
    super.initState();
    snake = [const Point(2, 2)];
    food = _generateFood();

    timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      setState(_moveSnake);
    });
  }

  Point<int> _generateFood() {
    while (true) {
      final p = Point(random.nextInt(gridSize), random.nextInt(gridSize));
      bool onSnake = false;
      for (var s in snake) {
        if (s.x == p.x && s.y == p.y) onSnake = true;
      }
      if (!onSnake) return p;
    }
  }

  void _moveSnake() {
    final head = snake.first;
    int dx = 0;
    int dy = 0;

    if (food.x > head.x) dx = 1;
    else if (food.x < head.x) dx = -1;
    else if (food.y > head.y) dy = 1;
    else if (food.y < head.y) dy = -1;

    if (dx != 0 && dy != 0) {
      if (random.nextBool()) dx = 0; else dy = 0;
    }

    final newHead = Point(
      (head.x + dx).clamp(0, gridSize - 1),
      (head.y + dy).clamp(0, gridSize - 1),
    );

    bool collision = false;
    for (var s in snake) {
      if (s.x == newHead.x && s.y == newHead.y) collision = true;
    }
    if (collision) return;

    snake.insert(0, newHead);
    if (newHead.x == food.x && newHead.y == food.y) {
      food = _generateFood();
      if (snake.length > 3) snake.removeLast();
    } else {
      snake.removeLast();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelSnakePainter(
        snake: snake,
        food: food,
        gridSize: gridSize,
      ),
    );
  }
}

/// ===============================
/// 🐍 ULTRA-MINI PIXEL LOADER
/// ===============================
class _SnakeLoader extends StatefulWidget {
  const _SnakeLoader({required this.message});
  final String message;

  @override
  State<_SnakeLoader> createState() => _SnakeLoaderState();
}

class _SnakeLoaderState extends State<_SnakeLoader> {
  static const int gridSize = 5;
  late Point<int> food;
  late List<Point<int>> snake;
  late Timer timer;
  final random = Random();

  @override
  void initState() {
    super.initState();
    snake = [const Point(2, 2)];
    food = _generateFood();
    
    // Classic discrete movement (350ms for a 'pixel game' feel)
    timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      setState(_moveSnake);
    });
  }

  Point<int> _generateFood() {
    while (true) {
      final p = Point(random.nextInt(gridSize), random.nextInt(gridSize));
      bool onSnake = false;
      for (var s in snake) {
        if (s.x == p.x && s.y == p.y) onSnake = true;
      }
      if (!onSnake) return p;
    }
  }

  void _moveSnake() {
    final head = snake.first;
    int dx = 0;
    int dy = 0;

    // Direct movement towards food
    if (food.x > head.x) dx = 1;
    else if (food.x < head.x) dx = -1;
    else if (food.y > head.y) dy = 1;
    else if (food.y < head.y) dy = -1;

    // Stochastic choice for multi-axis movement
    if (dx != 0 && dy != 0) {
      if (random.nextBool()) dx = 0; else dy = 0;
    }

    final newHead = Point(
      (head.x + dx).clamp(0, gridSize - 1),
      (head.y + dy).clamp(0, gridSize - 1),
    );

    // Collision check
    bool collision = false;
    for (var s in snake) {
      if (s.x == newHead.x && s.y == newHead.y) collision = true;
    }
    if (collision) return;

    snake.insert(0, newHead);
    if (newHead.x == food.x && newHead.y == food.y) {
      food = _generateFood();
      if (snake.length > 3) snake.removeLast(); // Maintain mini length
    } else {
      snake.removeLast();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Glass Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withValues(alpha: 0.05)),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ultra-mini pixel grid container (~48x48)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _PixelSnakePainter(
                            snake: snake,
                            food: food,
                            gridSize: gridSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PixelSnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;

  _PixelSnakePainter({
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridSize;
    final cellH = size.height / gridSize;
    final paint = Paint();

    // 1. Draw empty pixel grid slots
    paint.color = Colors.white.withValues(alpha: 0.06);
    paint.style = PaintingStyle.fill;
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * cellW + 1, y * cellH + 1, cellW - 2, cellH - 2),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }

    // 2. Draw Food Pixel
    paint.color = const Color(0xFFB2DFDB).withValues(alpha: 0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(food.x * cellW + 1.5, food.y * cellH + 1.5, cellW - 3, cellH - 3),
        const Radius.circular(2),
      ),
      paint,
    );

    // 3. Draw Snake Pixels (Green)
    for (int i = 0; i < snake.length; i++) {
      final p = snake[i];
      final isHead = i == 0;
      
      paint.color = const Color(0xFF4D9489).withValues(alpha: 0.92);
      if (isHead) {
        paint.color = const Color(0xFF3B7F75).withValues(alpha: 0.96);
      }
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.x * cellW + 1, p.y * cellH + 1, cellW - 2, cellH - 2),
          const Radius.circular(2), // Subtle rounded corners for 'cute' factor
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelSnakePainter oldDelegate) => true;
}
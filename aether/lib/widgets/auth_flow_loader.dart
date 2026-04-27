// Small utility that displays a playful snake loader used during auth or
// background flows. Exported helper `runWithAuthFlowLoader` wraps an async
// action and shows a blocking dialog while the action completes.
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    barrierColor: Colors.black.withOpacity(0.25),
    pageBuilder: (ctx, _, _) {
      dialogContext = ctx;
      return _SnakeLoader(message: message);
    },
  );

  try {
    final result = await action();
    await Future.delayed(const Duration(milliseconds: 600)); // smooth exit
    return result;
  } finally {
    if (dialogContext != null) {
      Navigator.of(dialogContext!, rootNavigator: true).pop();
    }
  }
}

/// ===============================
/// 🐍 LOADER UI
/// ===============================
class _SnakeLoader extends StatefulWidget {
  const _SnakeLoader({required this.message});
  final String message;

  @override
  State<_SnakeLoader> createState() => _SnakeLoaderState();
}

class _SnakeLoaderState extends State<_SnakeLoader> {
  static const gridSize = 8;
  static const pixel = 8.0;

  late List<Point<int>> snake;
  late Point<int> food;
  late Timer timer;
  final random = Random();

  @override
  void initState() {
    super.initState();

    snake = [const Point(3, 3)];
    food = _randomFood();

    /// 🐢 slower movement
    timer = Timer.periodic(const Duration(milliseconds: 260), (_) {
      setState(_moveSnake);
    });
  }

  Point<int> _randomFood() {
    while (true) {
      final p = Point(random.nextInt(gridSize), random.nextInt(gridSize));
      if (!snake.contains(p)) return p;
    }
  }

  void _moveSnake() {
    final head = snake.first;

    /// 🎯 simple AI movement (towards food)
    int dx = 0;
    int dy = 0;

    if (food.x > head.x) dx = 1;
    if (food.x < head.x) dx = -1;
    if (food.y > head.y) dy = 1;
    if (food.y < head.y) dy = -1;

    /// randomize slight movement to feel natural
    if (random.nextBool()) {
      final tmp = dx;
      dx = dy;
      dy = tmp;
    }

    final newHead = Point(
      (head.x + dx).clamp(0, gridSize - 1),
      (head.y + dy).clamp(0, gridSize - 1),
    );

    if (snake.contains(newHead)) return;

    snake.insert(0, newHead);

    if (newHead == food) {
      food = _randomFood(); // grow
    } else {
      snake.removeLast(); // move
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
      color: Colors.black.withOpacity(0.25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🟩 GRID BOX
            Container(
              width: gridSize * pixel,
              height: gridSize * pixel,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(
                painter: _SnakePainter(
                  snake: snake,
                  food: food,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              widget.message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEAFDFC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// 🎨 PAINTER
/// ===============================
class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;

  static const pixel = 8.0;

  _SnakePainter({required this.snake, required this.food});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;

    /// 🐍 draw snake
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];

      final color = Color.lerp(
        const Color(0xFF5CB6A5),
        const Color(0xFF2D726B),
        i / snake.length,
      )!;

      paint.color = color;

      canvas.drawRect(
        Rect.fromLTWH(
          segment.x * pixel,
          segment.y * pixel,
          pixel,
          pixel,
        ),
        paint,
      );
    }

    /// 🍏 food
    paint.color = const Color(0xFF8BE3C8);

    canvas.drawRect(
      Rect.fromLTWH(
        food.x * pixel,
        food.y * pixel,
        pixel,
        pixel,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) {
    return true;
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';

Future<T> runWithAuthFlowLoader<T>({
  required BuildContext context,
  required String message,
  required Future<T> Function() action,
  Duration entryDelay = const Duration(milliseconds: 120),
  Duration settleDelay = const Duration(milliseconds: 340),
}) async {
  BuildContext? dialogContext;

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Auth loader',
    barrierColor: const Color(0x66102D34),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      dialogContext = ctx;
      return _AuthFlowLoader(message: message);
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );

  await Future<void>.delayed(entryDelay);
  try {
    final result = await action();
    await Future<void>.delayed(settleDelay);
    return result;
  } finally {
    final ctx = dialogContext;
    if (ctx != null) {
      final nav = Navigator.of(ctx, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      }
    }
  }
}

class _AuthFlowLoader extends StatefulWidget {
  const _AuthFlowLoader({required this.message});

  final String message;

  @override
  State<_AuthFlowLoader> createState() => _AuthFlowLoaderState();
}

class _AuthFlowLoaderState extends State<_AuthFlowLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _PixelOrbitPainter(progress: _controller.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEAFDFC),
                height: 1.25,
                shadows: [
                  Shadow(
                    color: Color(0x66102D34),
                    offset: Offset(0, 1),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelOrbitPainter extends CustomPainter {
  _PixelOrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final t = progress * 2 * math.pi;

    final softGlow = Paint()
      ..color = const Color(0xFF5CB6A5).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, 27, softGlow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF5CB6A5).withValues(alpha: 0.24);
    canvas.drawCircle(center, 30, ringPaint);
    canvas.drawCircle(
      center,
      42,
      ringPaint..color = const Color(0xFF2D726B).withValues(alpha: 0.22),
    );

    final pixelPaint = Paint()..isAntiAlias = false;
    const outerCount = 18;
    const innerCount = 12;

    for (var i = 0; i < outerCount; i++) {
      final p = i / outerCount;
      final angle = (p * 2 * math.pi) + t;
      final wobble = 1.0 + 0.09 * math.sin((t * 2.4) + (i * 0.55));
      final radius = 42 * wobble;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      final alpha = (0.25 + 0.75 * (0.5 + 0.5 * math.sin(t + (i * 0.5))))
          .clamp(0.0, 1.0);
      final px = 2.6 + (1.6 * (0.5 + 0.5 * math.sin((t * 1.8) + i)));

      pixelPaint.color = Color.lerp(
        const Color(0xFF2D726B),
        const Color(0xFF5CB6A5),
        p,
      )!
          .withValues(alpha: alpha);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: px, height: px),
        pixelPaint,
      );
    }

    for (var i = 0; i < innerCount; i++) {
      final p = i / innerCount;
      final angle = (p * 2 * math.pi) - (t * 0.74);
      final wobble = 1.0 + 0.07 * math.cos((t * 2.1) + (i * 0.62));
      final radius = 30 * wobble;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      final alpha = (0.22 + 0.68 * (0.5 + 0.5 * math.cos((t * 1.2) + i)))
          .clamp(0.0, 1.0);
      final px = 2.2 + (1.1 * (0.5 + 0.5 * math.cos((t * 1.5) + i)));

      pixelPaint.color = Color.lerp(
        const Color(0xFF5CB6A5),
        const Color(0xFFEAFDFC),
        p,
      )!
          .withValues(alpha: alpha);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: px, height: px),
        pixelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

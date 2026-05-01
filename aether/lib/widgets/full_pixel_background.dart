import 'dart:math' as math;
import 'package:flutter/material.dart';

class FullPixelBackground extends StatefulWidget {
  const FullPixelBackground({
    super.key,
    this.gridColumns,
    this.colorIntensity = 0.75, // Slightly muted for onboarding
    this.animationSpeed = 1.0,
  });

  final int? gridColumns;
  final double animationSpeed;
  final double colorIntensity;

  @override
  State<FullPixelBackground> createState() => _FullPixelBackgroundState();
}

class _FullPixelBackgroundState extends State<FullPixelBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration _durationForSpeed(double speed) {
    final clamped = speed.clamp(0.5, 3.0);
    return Duration(milliseconds: (12000 / clamped).round());
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationForSpeed(widget.animationSpeed),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant FullPixelBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationSpeed != widget.animationSpeed) {
      _controller.duration = _durationForSpeed(widget.animationSpeed);
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _FullPixelPainter(
          progress: _controller,
          gridColumns: widget.gridColumns,
          animationSpeed: widget.animationSpeed,
          colorIntensity: widget.colorIntensity,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FullPixelPainter extends CustomPainter {
  _FullPixelPainter({
    required this.progress,
    required this.gridColumns,
    required this.animationSpeed,
    required this.colorIntensity,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final int? gridColumns;
  final double animationSpeed;
  final double colorIntensity;
  final Map<int, _CellMeta> _cellMetaCache = <int, _CellMeta>{};

  static final Color _tealA = const Color.fromRGBO(45, 114, 107, 1).withValues(alpha: 0.95);
  static final Color _tealB = const Color.fromRGBO(24, 79, 75, 1).withValues(alpha: 0.95);
  static final Color _darkA = const Color.fromRGBO(16, 45, 52, 1).withValues(alpha: 0.90);
  static final Color _darkB = const Color.fromRGBO(7, 28, 34, 1).withValues(alpha: 0.90);

  double _hash01(int x, int y, [int salt = 0]) {
    final n = math.sin((x * 127.1 + y * 311.7 + salt * 74.7).toDouble()) * 43758.5453123;
    return n - n.floorToDouble();
  }

  _CellMeta _cellMeta(int col, int row) {
    final key = (row * 4096) + col;
    final cached = _cellMetaCache[key];
    if (cached != null) return cached;

    final meta = _CellMeta(
      phase: _hash01(col, row, 11) * 2 * math.pi,
      intensityVar: 0.10 + (_hash01(col, row, 12) * 0.20),
      colorVar: (_hash01(col, row, 13) - 0.5) * 0.12,
      darkVar: _hash01(col, row, 14),
    );
    _cellMetaCache[key] = meta;
    return meta;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress.value;
    final t = time * 2 * math.pi;
    final cols = gridColumns?.clamp(40, 80) ?? ((size.width / 18).round().clamp(40, 80));
    final cellW = size.width / cols;
    final cellH = cellW;
    final rows = (size.height / cellH).ceil() + 1;

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final focusX = size.width * (0.20 + (0.60 * (0.5 + (0.5 * math.sin(t)))));
    final focusY = size.height * (0.22 + (0.56 * (0.5 + (0.5 * math.cos(t + 0.9)))));
    final driftAngle = t + (math.sin((t * 2) + 0.7) * 0.16);
    final driftX = math.cos(driftAngle);
    final driftY = math.sin(driftAngle);
    final lightX = math.cos(driftAngle - 0.7);
    final lightY = math.sin(driftAngle - 0.7);

    final pixelPaint = Paint()..isAntiAlias = false;
    final invWidth = 1.0 / size.width;
    final invHeight = 1.0 / size.height;
    final halfCellW = cellW * 0.5;
    final halfCellH = cellH * 0.5;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final left = (col * cellW).roundToDouble();
        final top = (row * cellH).roundToDouble();
        final right = ((col + 1) * cellW).roundToDouble();
        final bottom = ((row + 1) * cellH).roundToDouble();

        final cx = left + halfCellW;
        final cy = top + halfCellH;

        final vx = (cx - focusX) * invWidth;
        final vy = (cy - focusY) * invHeight;
        final dist = math.sqrt((vx * vx) + (vy * vy));

        final core = math.exp(-math.pow(dist / 0.18, 2));
        final trailAxis = (vx * driftX) + (vy * driftY);
        final trail = math.exp(-math.pow((trailAxis + 0.10) / 0.25, 2)) * math.exp(-math.pow(dist / 0.42, 2));
        final moverInfluence = (0.72 * core + 0.28 * trail).clamp(0.0, 1.0);

        final meta = _cellMeta(col, row);
        final cellWave = 0.5 + 0.5 * math.sin(t + meta.phase);
        final cellBreath = Curves.easeInOut.transform(cellWave);

        final noise = meta.colorVar;
        final depth = (cy * invHeight).clamp(0.0, 1.0);
        final depthEase = Curves.easeInOut.transform(depth);
        
        final colorMix = (0.30 + (0.38 * depthEase) + (0.28 * moverInfluence) + noise).clamp(0.0, 1.0);

        final cloudWave = 0.5 + 0.5 * math.sin(t + (vx * 6.4) - (vy * 4.7) + meta.phase);
        final darkStrength = (cloudWave * (0.12 + (0.26 * meta.darkVar)) * (1.0 - cellBreath * 0.25)).clamp(0.0, 0.38);

        final directional = (((vx * lightX) + (vy * lightY)) * 0.5 + 0.5).clamp(0.0, 1.0);
        final depth3D = (directional - 0.5) * 0.22;

        var intensity = (0.40 + depthEase * 0.52) * (0.86 + (0.12 * moverInfluence) + depth3D) * (0.86 + (0.20 * cellBreath)) * (0.92 + meta.intensityVar) * colorIntensity;
        intensity = intensity.clamp(0.0, 1.0);

        final baseColor = Color.lerp(_tealA, _tealB, colorMix)!;
        final darkColor = Color.lerp(_darkA, _darkB, colorMix)!;
        final enrichedColor = Color.lerp(baseColor, darkColor, darkStrength)!;
        final cellColor = enrichedColor.withValues(alpha: (0.90 * intensity * (0.90 - (darkStrength * 0.20))).clamp(0.0, 0.95));
        
        pixelPaint.color = cellColor;
        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), pixelPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FullPixelPainter oldDelegate) {
    return oldDelegate.gridColumns != gridColumns || oldDelegate.animationSpeed != animationSpeed || oldDelegate.colorIntensity != colorIntensity || oldDelegate.progress.value != progress.value;
  }
}

class _CellMeta {
  const _CellMeta({
    required this.phase,
    required this.intensityVar,
    required this.colorVar,
    required this.darkVar,
  });

  final double phase;
  final double intensityVar;
  final double colorVar;
  final double darkVar;
}

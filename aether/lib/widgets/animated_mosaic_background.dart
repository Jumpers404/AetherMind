import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class AnimatedMosaicBackground extends StatefulWidget {
  const AnimatedMosaicBackground({
    super.key,
    this.gridColumns,
    this.colorIntensity = 1.0,
    this.animationSpeed = 1.0,
  });

  final int? gridColumns;
  final double animationSpeed;
  final double colorIntensity;

  @override
  State<AnimatedMosaicBackground> createState() => _AnimatedMosaicBackgroundState();
}

class _AnimatedMosaicBackgroundState extends State<AnimatedMosaicBackground>
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
  void didUpdateWidget(covariant AnimatedMosaicBackground oldWidget) {
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
        painter: _PixelMosaicBackgroundPainter(
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

class _PixelMosaicBackgroundPainter extends CustomPainter {
  _PixelMosaicBackgroundPainter({
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
  static final Color _tealAccentA = const Color.fromRGBO(92, 182, 165, 1).withValues(alpha: 0.92);
  static final Color _tealAccentB = const Color.fromRGBO(66, 153, 142, 1).withValues(alpha: 0.92);
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
      starSeed: _hash01(col, row, 15),
      starPhase: _hash01(col, row, 16),
      starRate: 0.55 + (_hash01(col, row, 17) * 0.95),
      starPower: 0.65 + (_hash01(col, row, 18) * 0.35),
    );
    _cellMetaCache[key] = meta;
    return meta;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress.value;
    final t = time * 2 * math.pi;
    final cols = gridColumns?.clamp(26, 48) ?? ((size.width / 24).round().clamp(26, 48));
    final cellW = size.width / cols;
    final cellH = cellW;
    final rows = (size.height / cellH).ceil() + 1;

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final topStart = size.height * 0.13;
    final topCenterDip = size.height * 0.10;
    final feather = size.height * 0.085;
    final basinY = size.height * 0.60;

    final focusX = size.width * (0.20 + (0.60 * (0.5 + (0.5 * math.sin(t)))));
    final focusY = topStart + ((size.height - topStart) * (0.22 + (0.56 * (0.5 + (0.5 * math.cos(t + 0.9))))));
    final driftAngle = t + (math.sin((t * 2) + 0.7) * 0.16);
    final driftX = math.cos(driftAngle);
    final driftY = math.sin(driftAngle);
    final lightX = math.cos(driftAngle - 0.7);
    final lightY = math.sin(driftAngle - 0.7);
    final depthSpan = (size.height - topStart).clamp(1.0, double.infinity);

    final pixelPaint = Paint()..isAntiAlias = false;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final left = (col * cellW).roundToDouble();
        final top = (row * cellH).roundToDouble();
        final right = ((col + 1) * cellW).roundToDouble();
        final bottom = ((row + 1) * cellH).roundToDouble();

        final cx = (left + right) * 0.5;
        final cy = (top + bottom) * 0.5;

        final x01 = (cx / size.width).clamp(0.0, 1.0);
        final distFromCenter = ((x01 - 0.5).abs() * 2).clamp(0.0, 1.0);
        final centerDipFactor = 1.0 - Curves.easeInOut.transform(distFromCenter);
        final topEdgeY = topStart + (topCenterDip * centerDipFactor);

        if (cy < topEdgeY - feather) continue;

        final blendIn = ((cy - (topEdgeY - feather)) / (feather * 2)).clamp(0.0, 1.0);
        final topBlend = Curves.easeInOut.transform(blendIn);

        final nx = (cx / size.width) - 0.5;
        final uCurveY = basinY + math.pow(nx.abs() * 1.9, 1.6) * size.height * 0.13;
        final uDist = ((cy - uCurveY).abs() / (size.height * 0.22)).clamp(0.0, 1.0);
        final uBand = 1.0 - Curves.easeInOut.transform(uDist);
        final centerMask = math.exp(-math.pow(nx / 0.34, 2));
        final hollow = (uBand * centerMask * 0.55).clamp(0.0, 0.55);
        final edgeBoost = ((nx.abs() - 0.22) / 0.38).clamp(0.0, 1.0) * 0.18;

        final depth = ((cy - topEdgeY) / (size.height - topEdgeY)).clamp(0.0, 1.0);
        final depthEase = Curves.easeInOut.transform(depth);

        final vx = (cx - focusX) / size.width;
        final vy = (cy - focusY) / depthSpan;
        final dist = math.sqrt((vx * vx) + (vy * vy));

        final core = math.exp(-math.pow(dist / 0.18, 2));
        final trailAxis = (vx * driftX) + (vy * driftY);
        final trail = math.exp(-math.pow((trailAxis + 0.10) / 0.25, 2)) * math.exp(-math.pow(dist / 0.42, 2));
        final moverInfluence = (0.72 * core + 0.28 * trail).clamp(0.0, 1.0);

        final meta = _cellMeta(col, row);
        final cellWave = 0.5 + 0.5 * math.sin(t + meta.phase);
        final cellBreath = Curves.easeInOut.transform(cellWave);

        final noise = meta.colorVar;
        final colorMix = (0.30 + (0.38 * depthEase) + (0.28 * moverInfluence) + noise).clamp(0.0, 1.0);

        final cloudWave = 0.5 + 0.5 * math.sin(t + (vx * 6.4) - (vy * 4.7) + meta.phase);
        final darkStrength = (cloudWave * (0.12 + (0.26 * meta.darkVar)) * (1.0 - cellBreath * 0.25)).clamp(0.0, 0.38);

        final directional = (((vx * lightX) + (vy * lightY)) * 0.5 + 0.5).clamp(0.0, 1.0);
        final depth3D = (directional - 0.5) * 0.22;

        var intensity = (0.40 + depthEase * 0.52) * (0.86 + (0.12 * moverInfluence) + depth3D) * (0.86 + (0.20 * cellBreath)) * (0.92 + meta.intensityVar) * topBlend * (1.0 - hollow) * (1.0 + edgeBoost) * colorIntensity;
        intensity = intensity.clamp(0.0, 1.0);

        final baseColor = Color.lerp(_tealA, _tealB, colorMix)!;
        final darkColor = Color.lerp(_darkA, _darkB, colorMix)!;
        final enrichedColor = Color.lerp(baseColor, darkColor, darkStrength)!;
        final cellColor = enrichedColor.withValues(alpha: (0.90 * intensity * (0.90 - (darkStrength * 0.20))).clamp(0.0, 0.95));
        pixelPaint.color = cellColor;
        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), pixelPaint);

        if (meta.starSeed > 0.986 && topBlend > 0.30) {
          final starPhase = meta.starPhase * 2 * math.pi;
          final starBase = 0.5 + 0.5 * math.sin((t * 2) + starPhase);
          final starTwinkle = 0.5 + 0.5 * math.sin((t * 3) + (meta.phase * 1.3));
          final starPulse = math.pow(((starBase * 0.72) + (starTwinkle * 0.28)).clamp(0.0, 1.0), 3.4).toDouble();
          final starStrength = (starPulse * meta.starPower * (1.0 - hollow) * (0.35 + topBlend * 0.65)).clamp(0.0, 1.0);
          if (starStrength > 0.001) {
            final starTint = Color.lerp(_tealAccentA, Colors.white, starStrength)!;
            pixelPaint.color = starTint.withValues(alpha: (0.015 + (0.11 * starStrength)).clamp(0.0, 0.12));
            canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), pixelPaint);
          }
        }
      }
    }

    final featherRect = Rect.fromLTWH(0, topStart - feather * 1.2, size.width, feather * 2.4);
    final featherPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0.0)],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(featherRect);
    canvas.drawRect(featherRect, featherPaint);
  }

  @override
  bool shouldRepaint(covariant _PixelMosaicBackgroundPainter oldDelegate) {
    return oldDelegate.gridColumns != gridColumns || oldDelegate.animationSpeed != animationSpeed || oldDelegate.colorIntensity != colorIntensity || oldDelegate.progress.value != progress.value;
  }
}

class _CellMeta {
  const _CellMeta({
    required this.phase,
    required this.intensityVar,
    required this.colorVar,
    required this.darkVar,
    required this.starSeed,
    required this.starPhase,
    required this.starRate,
    required this.starPower,
  });

  final double phase;
  final double intensityVar;
  final double colorVar;
  final double darkVar;
  final double starSeed;
  final double starPhase;
  final double starRate;
  final double starPower;
}

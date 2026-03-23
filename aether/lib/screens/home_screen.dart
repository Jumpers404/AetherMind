import 'dart:ui' show ImageFilter, PointerDeviceKind;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'journal_test_screen.dart';
import 'report_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../services/report_controller.dart';
import '../widgets/auth_flow_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
  with TickerProviderStateMixin {
  static const _horizontalPadding = 20.0;
  static const _sectionSpacing = 24.0;
  static const _internalSpacing = 14.0;

  bool _isLoading = false;
  late final AnimationController _shimmerController;
  final ReportController _reportController = ReportController();

  String get _greetingName {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) {
        final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ');
        return normalized
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join(' ');
      }
    }

    return 'there';
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF9FBFA),
                    Color(0xFFF3F7F5),
                    Color(0xFFEAF3EF),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: ScrollConfiguration(
                behavior: const _NoScrollbarBehavior(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(
                        userName: _greetingName,
                        onSignOut: _handleSignOut,
                      ),
                      const SizedBox(height: 14),
                      const _MoodInputBar(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _TodayVibeCard(
                          shimmer: _shimmerController,
                          isLoading: _isLoading,
                          onTapCheckIn: _handleCheckInNow,
                        ),
                      ),
                      const SizedBox(height: _sectionSpacing),
                      const _ProgressSection(),
                      const SizedBox(height: _sectionSpacing),
                      _DailyJournalCard(
                        onTapWrite: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const JournalTestScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: _sectionSpacing),
                      const _SectionTitle(text: 'Quick Actions'),
                      const SizedBox(height: _internalSpacing),
                      const _QuickActionsRow(),
                      const SizedBox(height: _sectionSpacing),
                      const _SectionTitle(text: 'Suggested for You'),
                      const SizedBox(height: _internalSpacing),
                      const _SuggestedRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckInNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }
  final currentUserId = user.uid;

    setState(() => _isLoading = true);

    try {
  final report = await _reportController.getWeeklyReport(currentUserId);

      if (!mounted) {
        return;
      }

      if (report.totalEntries == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No journal data for this week')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(report: report),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load weekly report')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await runWithAuthFlowLoader<void>(
        context: context,
        message: 'Signing you out...',
        action: () => FirebaseAuth.instance.signOut(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out right now.')),
      );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.userName,
    required this.onSignOut,
  });

  final String userName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $userName ',
                style: TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 27,
                  fontWeight: FontWeight.lerp(FontWeight.w800, FontWeight.w900, 0.4),
                  color: const Color(0xFF1E3A45),
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome to Aether',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5F7380).withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _RoundActionIcon(
              icon: Icons.notifications_none_rounded,
              showDot: true,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
            ),
            const SizedBox(width: 12),
            _OptionsMenuButton(onSignOut: onSignOut),
          ],
        ),
      ],
    );
  }
}

class _OptionsMenuButton extends StatelessWidget {
  const _OptionsMenuButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
                  child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.82),
                      Colors.white.withValues(alpha: 0.46),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.68),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C333B).withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF4FB894).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(onSignOut: onSignOut),
                      ),
                    );
                  },
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2FB07E),
                      size: 22,
                    ),
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}

class _RoundActionIcon extends StatelessWidget {
  const _RoundActionIcon({required this.icon, this.showDot = false, this.onTap});

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.82),
                    Colors.white.withValues(alpha: 0.46),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.68),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C333B).withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF4FB894).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.34),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        color: const Color(0xFF2FB07E),
                        size: 22,
                      ),
                    ),
                    if (showDot)
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3BC497),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3BC497).withValues(alpha: 0.45),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayVibeCard extends StatelessWidget {
  const _TodayVibeCard({
    required this.shimmer,
    required this.isLoading,
    required this.onTapCheckIn,
  });

  final Animation<double> shimmer;
  final bool isLoading;
  final VoidCallback onTapCheckIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF7F1), Color(0xFFD2EBDD), Color(0xFFC4E3D3)],
            ),
            border: Border.all(
              color: const Color(0xFF8CBFA8).withValues(alpha: 0.55),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B7B62).withValues(alpha: 0.24),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF77B49E).withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.all(0.8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(23.2)),
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: Color(0xFF79B299),
                            width: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.35, -0.6),
                        radius: 1.15,
                        colors: [
                          Colors.white.withValues(alpha: 0.34),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _CardPixelPanelPainter(progress: shimmer),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                  Expanded(
                    flex: 58,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Happy to see you...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Doto',
                              fontSize: 17,
                              fontWeight: FontWeight.lerp(FontWeight.w800, FontWeight.w900, 0.4),
                              color: const Color(0xFF2F9E6F),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Be calm - Stay consistent -\nYou\'re doing great',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.4,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const Spacer(),
                          _HeroCheckInButton(
                            isLoading: isLoading,
                            onTap: onTapCheckIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 42,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        AnimatedBuilder(
                          animation: shimmer,
                          builder: (context, child) {
                            final y = math.sin(shimmer.value * 2 * math.pi) * 2.8;
                            return Transform.translate(
                              offset: Offset(0, y),
                              child: Transform.scale(
                                scale: 1.55,
                                child: child,
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Opacity(
                              opacity: 0.88,
                              child: SizedBox(
                                width: 210,
                                height: 210,
                                child: Image.asset(
                                  'assets/imgs/new-pet.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPixelPanelPainter extends CustomPainter {
  _CardPixelPanelPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  double _hash01(int x, int y, [int salt = 0]) {
    final n = math.sin((x * 127.1 + y * 311.7 + salt * 74.7).toDouble()) *
        43758.5453123;
    return n - n.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    const intensityBoost = 1.8;
    final cols = (size.width / 8.4).round().clamp(16, 34);
    final cell = size.width / cols;
    final rows = (size.height / cell).ceil() + 1;
    final paint = Paint()..isAntiAlias = false;

    final t = progress.value * 2 * math.pi;
    final focusX = size.width * (0.22 + (0.58 * (0.5 + (0.5 * math.sin(t)))));
    final focusY = size.height * (0.30 + (0.40 * (0.5 + (0.5 * math.cos(t + 0.8)))));
    final spanY = size.height.clamp(1.0, double.infinity);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final left = (col * cell).roundToDouble();
        final top = (row * cell).roundToDouble();
        final right = ((col + 1) * cell).roundToDouble();
        final bottom = ((row + 1) * cell).roundToDouble();

        final cx = (left + right) * 0.5;
        final cy = (top + bottom) * 0.5;
        final nx = col / cols;
        final ny = row / rows;

        final phase = _hash01(col, row, 1) * 2 * math.pi;
        final phase2 = _hash01(col, row, 2) * 2 * math.pi;
        final wave = 0.5 + 0.5 * math.sin((nx * 4.8) + (ny * 3.7) + phase + t);
        final sweep = 0.5 + 0.5 * math.cos((nx * 6.9) - (ny * 2.9) - phase2 + (t * 2));
        final blend = (0.58 * wave) + (0.42 * sweep);

        final vx = (cx - focusX) / size.width;
        final vy = (cy - focusY) / spanY;
        final dist = math.sqrt((vx * vx) + (vy * vy));
        final focusInfluence = math.exp(-math.pow(dist / 0.33, 2));

        final pulseBase = 0.5 + 0.5 * math.sin(t + phase);
        final pulse = Curves.easeInOut.transform(pulseBase);
        final burstBase = 0.5 + 0.5 * math.sin((t * 2) + phase2);
        final burst = math.pow(burstBase, 3.6).toDouble();
        final visibility =
            (0.22 + (0.48 * pulse) + (0.35 * burst) + (0.20 * focusInfluence))
                .clamp(0.0, 1.0);

        final depth = (0.72 + (0.28 * ny)).clamp(0.0, 1.0);
        final alpha =
          (((0.045 + (0.18 * blend)) * visibility * depth) * intensityBoost)
            .clamp(0.0, 0.45);

        paint.color = Color.lerp(
          const Color(0xFF6FB09A),
          const Color(0xFF3D7F6A),
          blend,
        )!.withValues(alpha: alpha);

        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

        // Independent spark cells to create clear pop-in / pop-out timing.
        final starSeed = _hash01(col, row, 3);
        if (starSeed > 0.982) {
          final starPhase = _hash01(col, row, 4) * 2 * math.pi;
          final starBase = 0.5 + 0.5 * math.sin((t * 2) + starPhase);
          final starTwinkle = 0.5 + 0.5 * math.sin((t * 3) + (phase * 1.2));
          final starPulse = math.pow(((starBase * 0.7) + (starTwinkle * 0.3)).clamp(0.0, 1.0), 4.0).toDouble();

          final starStrength =
              (starPulse * (0.55 + (0.45 * _hash01(col, row, 5))) * visibility)
                  .clamp(0.0, 1.0);
          if (starStrength > 0.07) {
            final starTint = Color.lerp(const Color(0xFFA1E0C6), Colors.white, starStrength)!;
            paint.color = starTint.withValues(
              alpha: ((0.03 + (0.16 * starStrength)) * intensityBoost)
                  .clamp(0.0, 0.225),
            );
            canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CardPixelPanelPainter oldDelegate) {
    return false;
  }
}

class _HeroCheckInButton extends StatelessWidget {
  const _HeroCheckInButton({required this.onTap, required this.isLoading});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF36B37E), Color(0xFF2F9E6F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F9E6F).withValues(alpha: 0.24),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Check In Now',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(text: 'Your Progress'),
            Row(
              children: [
                Text(
                  'View All',
                  style: const TextStyle(
                    fontFamily: 'Doto',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF33B286),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final card1 = _ProgressStatCard(
              title: 'Current Streak',
              valueText: '12 days',
              subtitle: 'Consistency',
              progress: 0.76,
              icon: Icons.local_fire_department_rounded,
              ringColor: const Color(0xFF2FB07E),
              iconBg: const Color(0xFFD9F1E7),
            );
            final card2 = _ProgressStatCard(
              title: 'Weekly Goals',
              valueText: '4 / 5',
              subtitle: 'Entries',
              progress: 0.80,
              icon: Icons.track_changes_rounded,
              ringColor: const Color(0xFF3AA9DE),
              iconBg: const Color(0xFFD9EEFA),
            );

            if (isNarrow) {
              return Column(
                children: [
                  card1,
                  const SizedBox(height: 12),
                  card2,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  const _ProgressStatCard({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.ringColor,
    required this.iconBg,
  });

  final String title;
  final String valueText;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color ringColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final hasSuffix = valueText.contains(' ');
    final valueParts = hasSuffix ? valueText.split(' ') : <String>[valueText];
    final valueMain = valueParts.first;
    final valueSuffix = hasSuffix ? valueParts.sublist(1).join(' ') : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFFF4F9F7),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3D47).withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              SizedBox(
                  width: 54,
                  height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                          backgroundColor: const Color(0xFFE3ECE8),
                          valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: ringColor, size: 18),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4D6A72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasSuffix)
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            color: ringColor,
                            height: 1.0,
                          ),
                          children: [
                            TextSpan(
                              text: valueMain,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' $valueSuffix',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        valueText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: ringColor,
                          height: 1.0,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6A7E86),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    const cardSize = 168.0;
    return SizedBox(
      height: cardSize,
      child: ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: const [
            _QuickActionCard(
              size: cardSize,
              title: 'Breathwork',
              subtitle: '2 min • Calm',
              icon: Icons.air_rounded,
              gradient: [Color(0xFFF8B270), Color(0xFFF49A5A)],
              buttonText: 'Start',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFFF1914E),
            ),
            SizedBox(width: 14),
            _QuickActionCard(
              size: cardSize,
              title: 'Positive Energy',
              subtitle: '5 min • Uplift',
              icon: Icons.favorite_rounded,
              gradient: [Color(0xFF5BC79C), Color(0xFF2EA985)],
              buttonText: '15 min',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFF2EA985),
            ),
            SizedBox(width: 14),
            _QuickActionCard(
              size: cardSize,
              title: 'Sleep',
              subtitle: '7 min • Relax',
              icon: Icons.nightlight_round,
              gradient: [Color(0xFF78A8E6), Color(0xFF4A86D7)],
              buttonText: 'Start',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFF4A86D7),
            ),
            SizedBox(width: 14),
            _QuickActionCard(
              size: cardSize,
              title: 'Psychology Facts',
              subtitle: 'Learn & Grow',
              icon: Icons.psychology_rounded,
              gradient: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
              buttonText: 'Fact',
              buttonIcon: Icons.lightbulb_rounded,
              buttonTextColor: Color(0xFF7C4DFF),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.size,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.buttonIcon,
    required this.buttonTextColor,
  });

  final double size;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String buttonText;
  final IconData buttonIcon;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return _InteractiveScaleCard(
      borderRadius: 22,
      child: SizedBox(
        width: size,
        height: size,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardW = constraints.maxWidth;
            final cardH = constraints.maxHeight;

            final pad = (cardW * 0.075).clamp(12.0, 16.0);
            final iconBox = (cardW * 0.25).clamp(42.0, 52.0);
            final iconGlyph = (iconBox * 0.58).clamp(24.0, 30.0);
            final sparkleSize = (cardW * 0.075).clamp(12.0, 16.0);
            final titleSize = (cardW * 0.078).clamp(13.0, 15.0);
            final subtitleSize = (cardW * 0.072).clamp(12.0, 14.0);
            final buttonHeight = (cardH * 0.235).clamp(40.0, 48.0);
            final buttonRadius = buttonHeight / 2;
            final buttonIconSize = (buttonHeight * 0.5).clamp(20.0, 24.0);
            final buttonTextSize = (cardW * 0.082).clamp(13.0, 15.5);
            final topIconOffset = (cardH * 0.04).clamp(4.0, 8.0);

            return Container(
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.32),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: topIconOffset,
                    child: Icon(
                      Icons.auto_awesome,
                      size: sparkleSize,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: iconBox,
                        height: iconBox,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Icon(icon, color: Colors.white, size: iconGlyph),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.12,
                        ),
                      ),
                      SizedBox(height: (cardH * 0.02).clamp(2.0, 4.0)),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                      SizedBox(height: (cardH * 0.06).clamp(8.0, 12.0)),
                      Container(
                        height: buttonHeight,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  buttonIcon,
                                  size: buttonIconSize,
                                  color: buttonTextColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  buttonText,
                                  style: GoogleFonts.poppins(
                                    fontSize: buttonTextSize,
                                    fontWeight: FontWeight.w700,
                                    color: buttonTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InteractiveScaleCard extends StatefulWidget {
  const _InteractiveScaleCard({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  State<_InteractiveScaleCard> createState() => _InteractiveScaleCardState();
}

class _InteractiveScaleCardState extends State<_InteractiveScaleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.97
        : _isHovered
            ? 1.01
            : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: () {},
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.23),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _DailyJournalCard extends StatelessWidget {
  const _DailyJournalCard({required this.onTapWrite});

  final VoidCallback onTapWrite;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.86),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203D48).withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFD1EFE4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF1D8968),
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Journal',
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF223F4A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Reflect & grow peace',
                    style: GoogleFonts.poppins(
                      fontSize: 12.6,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C808C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTapWrite,
                child: Ink(
                  height: 46,
                  width: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFC8DDD5),
                      width: 1.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Write',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F9873),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedRow extends StatelessWidget {
  const _SuggestedRow();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SuggestedCard(
          icon: Icons.headphones_rounded,
          iconBg: Color(0xFFD5EDE4),
          iconColor: Color(0xFF217F66),
          title: 'Morning Peace',
          subtitle: '8 min • Audio',
        ),
        SizedBox(height: 14),
        _SuggestedCard(
          icon: Icons.nightlight_round,
          iconBg: Color(0xFFE1D8F7),
          iconColor: Color(0xFF6750C7),
          title: 'Gratitude',
          subtitle: '3 min • Guide',
        ),
      ],
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 170;
        final dense = constraints.maxWidth < 150;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.09),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              dense ? 8 : 12,
              dense ? 10 : 12,
              dense ? 8 : 12,
              dense ? 10 : 12,
            ),
            child: Row(
              children: [
                Container(
                  width: dense ? 40 : (compact ? 44 : 52),
                  height: dense ? 40 : (compact ? 44 : 52),
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(
                    icon,
                    size: dense ? 23 : (compact ? 25 : 30),
                    color: iconColor,
                  ),
                ),
                SizedBox(width: dense ? 7 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: dense ? 11.8 : (compact ? 13 : 15.5),
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: dense ? 10.4 : (compact ? 11.3 : 14.5),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6E818D),
                        ),
                      ),
                    ],
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

class _MoodInputBar extends StatelessWidget {
  const _MoodInputBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.42),
                Colors.white.withValues(alpha: 0.22),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.48),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF28A67A).withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F7380),
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 0.9,
                  ),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Color(0xFF22A178),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Doto',
        fontSize: 19,
        fontWeight: FontWeight.lerp(FontWeight.w800, FontWeight.w900, 0.4),
        color: const Color(0xFF1E3A46),
      ),
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}


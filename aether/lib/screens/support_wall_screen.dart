// Support wall and community features.
// In-memory demo implementation providing anonymous posts and replies.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../models/reply_model.dart';
import 'create_post_screen.dart';
import 'reply_screen.dart';

class SupportWallScreen extends StatefulWidget {
  const SupportWallScreen({super.key});

  @override
  State<SupportWallScreen> createState() => _SupportWallScreenState();
}

class _SupportWallScreenState extends State<SupportWallScreen> {
  static const _backgroundTop = Color(0xFFFDFEFE);
  static const _backgroundMid = Color(0xFFF4FAF6);
  static const _backgroundBottom = Color(0xFFE9F2EC);
  static const _buttonStart = Color(0xFF4D9489);
  static const _buttonEnd = Color(0xFF3B7F75);
  static const _softWhite = Color(0xFFE8F4F1);
  static const _avatarPath = 'assets/imgs/AppIcons/appstore.png';

  // In-memory local state simulation
  final List<SupportPost> _posts = [];
  final Map<String, List<SupportReply>> _replies = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate with some supportive anonymous examples
    _posts.add(
      SupportPost(
        id: '1',
        anonymousId: 'Anon #X8T1',
        text:
            "I've been feeling really overwhelmed with work lately. It feels like no matter how much I do, I'm never catching up.",
        mood: 'Tired',
        tags: const ['Work', 'Burnout', 'Overwhelm'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      ),
    );

    _posts.add(
      SupportPost(
        id: '2',
        anonymousId: 'Anon #P2L9',
        text:
            "Just wanted to say I finally got out of bed and made tea today. A small win, but it feels big.",
        mood: 'Hopeful',
        tags: const ['Small Wins', 'Self-care'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );

    _replies['1'] = [
      SupportReply(
        id: 'r1',
        postId: '1',
        anonymousId: 'Anon #M9K4',
        text:
            "I hear you. Work can definitely feel like a treadmill sometimes. Remember to take small breaks.",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void _handleSupport(SupportPost post) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Support sent anonymously'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReport(SupportPost post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Report Post',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                title: const Text('Harmful Content'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportAck();
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded, color: Colors.orange),
                title: const Text('Abuse or Harassment'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportAck();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_rounded, color: Colors.grey),
                title: const Text('Spam'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportAck();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  void _showReportAck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post reported and sent for review.')),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    _posts.removeWhere((post) => post.expiresAt.isBefore(now));
    final visiblePosts = _posts.toList();

    return Scaffold(
      backgroundColor: _backgroundTop,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.62),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _buttonEnd),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Safe Space',
          style: const TextStyle(
            fontFamily: 'Doto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _buttonEnd,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _backgroundTop,
                    _backgroundMid,
                    _backgroundBottom,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -50,
            child: _ambientBlob(const Color(0x332D726B), 180),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: _ambientBlob(const Color(0x26A8D8C7), 140),
          ),
          SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 92),
              physics: const BouncingScrollPhysics(),
              itemCount: visiblePosts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final post = visiblePosts[idx];
                return _buildPostCard(post);
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(
                          onSubmit: (post) async {
                            setState(() {
                              _posts.insert(0, post);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_buttonStart, _buttonEnd],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x243B7F75),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Write anonymously',
                        style: const TextStyle(
                          fontFamily: 'Doto',
                          fontSize: 13.3,
                          fontWeight: FontWeight.w600,
                          color: _softWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(SupportPost post) {
    final expiresIn = post.expiresAt.difference(DateTime.now());
    final expiresLabel = expiresIn.isNegative
        ? 'Expired'
        : expiresIn.inHours >= 1
            ? 'Auto-deletes in ${expiresIn.inHours}h'
            : 'Auto-deletes in ${expiresIn.inMinutes}m';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0x142D726B)),
          bottom: BorderSide(color: Color(0x142D726B)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _avatarPath,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: Color(0xFF2D726B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted by ${post.anonymousId}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatTime(post.createdAt)} • $expiresLabel',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _handleReport(post),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBF9),
                border: Border.all(
                  color: const Color(0x1A2D726B),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    post.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      height: 1.55,
                      fontSize: 14.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _TagChip(label: post.mood, isPrimary: true),
                      ...post.tags.map((tag) => _TagChip(label: tag)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GradientActionButton(
                    icon: Icons.favorite_rounded,
                    label: 'Send empathy',
                    gradientColors: const [_buttonStart, _buttonEnd],
                    onTap: () => _handleSupport(post),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GradientActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Reply kindly',
                    gradientColors: const [_buttonStart, _buttonEnd],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReplyScreen(
                            post: post,
                            replies: _replies[post.id] ?? [],
                            onReply: (r) async {
                              setState(() {
                                _replies.putIfAbsent(post.id, () => []);
                                _replies[post.id]!.add(r);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _ambientBlob(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x243B7F75),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: _SupportWallScreenState._softWhite),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      color: _SupportWallScreenState._softWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.isPrimary = false});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFF2D726B).withValues(alpha: 0.18)
            : const Color(0xFFEAF3EF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF2D726B).withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11.2,
          fontWeight: FontWeight.w600,
          color: isPrimary ? const Color(0xFF2D726B) : const Color(0xFF2D726B),
        ),
      ),
    );
  }
}

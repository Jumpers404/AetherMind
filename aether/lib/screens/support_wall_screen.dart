import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../models/reply_model.dart';
import '../widgets/app_card.dart';
import 'create_post_screen.dart';
import 'reply_screen.dart';

class SupportWallScreen extends StatefulWidget {
  const SupportWallScreen({super.key});

  @override
  State<SupportWallScreen> createState() => _SupportWallScreenState();
}

class _SupportWallScreenState extends State<SupportWallScreen> {
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
        emoji: '🍂',
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
        emoji: '🌱',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Support Wall',
                        style: TextStyle(
                          fontFamily: 'Doto',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A safe, anonymous space. No likes, no judgments—only empathy.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(
                        Icons.mode_edit_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Write Something',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _posts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, idx) {
                  final post = _posts[idx];
                  return _buildPostCard(post);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(SupportPost post) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                post.anonymousId,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatTime(post.createdAt),
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            post.text,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  post.mood,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (post.emoji != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEAF3EF)),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    post.emoji!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: Color(0xFFEAF3EF)),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _handleSupport(post),
                icon: const Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: Color(0xFFE57373),
                ),
                label: const Text(
                  'Support',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReplyScreen(
                        post: post,
                        replies: _replies[post.id] ?? [],
                        onReply: (r) async {
                          setState(() {
                            if (_replies[post.id] == null)
                              _replies[post.id] = [];
                            _replies[post.id]!.add(r);
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Reply',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
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
        ],
      ),
    );
  }
}

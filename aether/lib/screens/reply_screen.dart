import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../models/reply_model.dart';
import '../widgets/app_card.dart';

class ReplyScreen extends StatefulWidget {
  final SupportPost post;
  final Future<void> Function(SupportReply reply) onReply;
  final List<SupportReply> replies;

  const ReplyScreen({
    super.key,
    required this.post,
    required this.onReply,
    required this.replies,
  });

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _empathyChips = [
    'I hear you',
    'You\'re not alone',
    'That sounds tough',
    'Stay strong',
    'Sending hugs',
  ];

  String _generateAnonId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final randomStr = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return 'Anon #$randomStr';
  }

  Future<void> _submitReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    // Minor delay
    await Future.delayed(const Duration(milliseconds: 300));

    final reply = SupportReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      anonymousId: _generateAnonId(),
      text: text,
      createdAt: DateTime.now(),
    );

    await widget.onReply(reply);

    if (!mounted) return;
    setState(() {
      _controller.clear();
      _isSubmitting = false;
    });
    FocusScope.of(context).unfocus();
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        title: const Text(
          'Replies',
          style: TextStyle(fontFamily: 'Doto', color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Original Post
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.post.anonymousId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _formatTime(widget.post.createdAt),
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            widget.post.text,
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
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  widget.post.mood,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (widget.post.emoji != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFEAF3EF),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    widget.post.emoji!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Replies',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.replies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No replies yet. Be the first to offer support.',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.replies.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, idx) {
                          final reply = widget.replies[idx];
                          return AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      reply.anonymousId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(reply.createdAt),
                                      style: TextStyle(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  reply.text,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Reply Input Area
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [AppShadows.soft],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _empathyChips.map((chip) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              bottom: 8.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                final text = _controller.text;
                                _controller.text = text.isEmpty
                                    ? chip
                                    : '$text $chip';
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBFA),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: const Color(0xFFEAF3EF),
                              ),
                            ),
                            child: TextField(
                              controller: _controller,
                              cursorColor: AppColors.primary,
                              maxLines: 3,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Offer support...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: _isSubmitting ? null : _submitReply,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

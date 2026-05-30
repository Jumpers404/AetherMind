// Reply screen for community support posts. Contains helper UI for
// selecting empathy chips and composing anonymous replies.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../models/reply_model.dart';

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
  static const _backgroundTop = Color(0xFFFDFEFE);
  static const _backgroundMid = Color(0xFFF4FAF6);
  static const _backgroundBottom = Color(0xFFE9F2EC);
  static const _buttonStart = Color(0xFF4D9489);
  static const _buttonEnd = Color(0xFF3B7F75);
  static const _avatarPath = 'assets/imgs/AppIcons/appstore.png';

  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _empathyChips = [
    'I hear you',
    'You\'re not alone',
    'That sounds tough',
    'Stay strong',
    'Sending hugs',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generateAnonId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < 4; i++) {
      buffer.write(chars[(rnd + i * 13) % chars.length]);
    }
    return 'Anon #${buffer.toString()}';
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _submitReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundTop,
      appBar: AppBar(
        title: const Text(
          'Replies',
          style: TextStyle(fontFamily: 'Doto', color: Color(0xFF184F4B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withValues(alpha: 0.62),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF184F4B)),
      ),
      body: SafeArea(
        child: Stack(
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
              top: -60,
              right: -40,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x332D726B),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GlassPanel(
                          borderRadius: 0,
                          padding: EdgeInsets.zero,
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
                                            'Posted by ${widget.post.anonymousId}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.2,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_formatTime(widget.post.createdAt)} • ${widget.post.expiresAt.difference(DateTime.now()).inHours}h left',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                        widget.post.text,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textPrimary,
                                          height: 1.55,
                                          fontSize: 14.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    _TagChip(label: widget.post.mood, isPrimary: true),
                                    ...widget.post.tags.map((tag) => _TagChip(label: tag)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Text(
                            'Replies',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, idx) {
                              final reply = widget.replies[idx];
                              return Padding(
                                padding: const EdgeInsets.only(left: 12, right: 16),
                                child: _GlassPanel(
                                  borderRadius: 22,
                                  padding: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              reply.anonymousId,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.2,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              _formatTime(reply.createdAt),
                                              style: GoogleFonts.poppins(
                                                color: AppColors.textSecondary,
                                                fontSize: 11.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                          child: Text(
                                            reply.text,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              height: 1.45,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                _buildReplyComposer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        border: Border.all(
          color: const Color(0x66FFFFFF),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final chip in _empathyChips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          final text = _controller.text;
                          _controller.text = text.isEmpty ? chip : '$text $chip';
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: const Color(0x1A2D726B),
                            ),
                          ),
                          child: Text(
                            chip,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: const Color(0x1A2D726B),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      cursorColor: _buttonEnd,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Offer support...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_buttonStart, _buttonEnd],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF7FFFB),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Color(0xFFF7FFFB),
                                size: 20,
                              ),
                      ),
                    ),
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
          color: const Color(0xFF2D726B),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.borderRadius = 24,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

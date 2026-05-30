// Create post screen used for community support posts.
// Applies a local moderation check before forwarding the post to the caller.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../utils/moderation_utils.dart';
import '../widgets/app_chip.dart';

class CreatePostScreen extends StatefulWidget {
  final Future<void> Function(SupportPost post) onSubmit;

  const CreatePostScreen({super.key, required this.onSubmit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const _backgroundTop = Color(0xFFFBFAF6);
  static const _backgroundMid = Color(0xFFF5F0E8);
  static const _backgroundBottom = Color(0xFFE9E1D3);
  static const _buttonStart = Color(0xFF4D9489);
  static const _buttonEnd = Color(0xFF3B7F75);
  static const _softWhite = Color(0xFFF7FFFB);
  static const _sectionSurface = Colors.white;
  static const _sectionBorder = Color(0x664D9489);
  static const _sectionShadow = Color(0x164D9489);

  final TextEditingController _controller = TextEditingController();
  final List<String> _moods = [
    'Struggling',
    'Lonely',
    'Anxious',
    'Tired',
    'Hopeful',
  ];
  final List<String> _tags = [
    'Work',
    'Family',
    'Sleep',
    'Anxiety',
    'Burnout',
    'Self-worth',
    'Grief',
    'Recovery',
  ];

  String _selectedMood = 'Struggling';
  final Set<String> _selectedTags = {'Work'};
  int _expireDays = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generateAnonId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final randomStr = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return 'Anon #$randomStr';
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (text.split(' ').length > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please keep it under 250 words.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final modResult = await ModerationService.analyzeText(text);
    if (!mounted) return;

    if (modResult == ModerationResult.mildToxicity) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Let's keep this space supportive. Please soften your language.",
          ),
        ),
      );
      return;
    } else if (modResult == ModerationResult.harmful) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This content violates our safety guidelines. Please rewrite it.",
          ),
        ),
      );
      return;
    } else if (modResult == ModerationResult.selfHarm) {
      setState(() => _isSubmitting = false);
      _showCrisisDialog();
      return;
    }

    final post = SupportPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      anonymousId: _generateAnonId(),
      text: text,
      mood: _selectedMood,
      tags: _selectedTags.toList(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: _expireDays)),
    );

    await widget.onSubmit(post);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showCrisisDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'We\'re really sorry you\'re feeling this way.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'You\'re not alone. There are people who want to support you through this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Continue anyway',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening crisis support... (Placeholder)'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Talk to someone',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundTop,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.76),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF184F4B)),
        title: const Text(
          'Share anonymously',
          style: TextStyle(fontFamily: 'Doto', color: Color(0xFF184F4B)),
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
            top: -60,
            right: -40,
            child: _ambientBlob(const Color(0x332D726B), 170),
          ),
          Positioned(
            top: 120,
            left: -50,
            child: _ambientBlob(const Color(0x26A8D8C7), 130),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Say what you need to say.',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 24,
                      color: Color(0xFF184F4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your post stays anonymous and uses the same calm green palette as Safe Space.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8FEFC),
                          Color(0xFFE9F5F1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _sectionBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: _sectionShadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 8,
                      maxLines: 12,
                      cursorColor: _buttonEnd,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 14.2,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind? (max 250 words)',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary.withValues(alpha: 0.75),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Mood',
                    surfaceColor: _sectionSurface,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _moods.map((mood) {
                        return AppChip(
                          label: mood,
                          isSelected: _selectedMood == mood,
                          onTap: () => setState(() => _selectedMood = mood),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Tags',
                    surfaceColor: _sectionSurface,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _tags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.86)
                                  : Colors.white.withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? _buttonStart.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.75),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.poppins(
                                fontSize: 12.2,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Auto delete',
                    surfaceColor: _sectionSurface,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [1, 3, 7].map((days) {
                        return AppChip(
                          label: days == 1 ? '24 Hours' : '$days Days',
                          isSelected: _expireDays == days,
                          onTap: () => setState(() => _expireDays = days),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_buttonStart, _buttonEnd],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2D184F4B),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF7FFFB),
                        ),
                      )
                    : Text(
                        'Write anonymously',
                        style: const TextStyle(
                          fontFamily: 'Doto',
                          color: _softWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.surfaceColor,
  });

  final String title;
  final Widget child;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x7A3B7F75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x173B7F75),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
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

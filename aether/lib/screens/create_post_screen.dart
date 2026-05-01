// Create post screen used for community support posts. Applies a
// local moderation check before forwarding the post to the caller.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/post_model.dart';
import '../utils/moderation_utils.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';

class CreatePostScreen extends StatefulWidget {
  final Future<void> Function(SupportPost post) onSubmit;

  const CreatePostScreen({super.key, required this.onSubmit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _moods = [
    'Struggling',
    'Lonely',
    'Anxious',
    'Tired',
    'Hopeful',
  ];
  final List<String> _emojis = ['🌧️', '🫂', '💔', '🍂', '🌱'];

  String _selectedMood = 'Struggling';
  String _selectedEmoji = '🌧️';
  int _expireDays = 1;

  bool _isSubmitting = false;

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

    // AI Filter
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
      emoji: _selectedEmoji,
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
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Share Anonymously',
          style: TextStyle(fontFamily: 'Doto', color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This is a safe space. No likes, no judgements. Just support.',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: 12,
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind? (max 250 words)',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'How are you feeling?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _moods.map((m) {
                  return AppChip(
                    label: m,
                    isSelected: _selectedMood == m,
                    onTap: () => setState(() => _selectedMood = m),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Choose an icon',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: _emojis.map((e) {
                  final isSelected = _selectedEmoji == e;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFEAF3EF),
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Auto Delete',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [1, 3, 7].map((days) {
                  return AppChip(
                    label: days == 1 ? '24 Hours' : '$days Days',
                    isSelected: _expireDays == days,
                    onTap: () => setState(() => _expireDays = days),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Post Anonymously',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// Card UI used to present a single 'fact' with actions (save/reflect/next).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fact_model.dart';
import '../app_theme.dart';
import '../widgets/app_chip.dart';

class FactCard extends StatelessWidget {
  final Fact fact;
  final VoidCallback onSave;
  final VoidCallback onReflect;
  final VoidCallback onNext;

  const FactCard({
    super.key,
    required this.fact,
    required this.onSave,
    required this.onReflect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fact.background.withOpacity(0.85),
            fact.background.withOpacity(0.5),
            fact.background.withOpacity(0.15),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 3),

            // Category Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                fact.category.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // The Fact
            Text(
              fact.text,
              style: GoogleFonts.poppins(
                fontSize: 28,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Tone indicator
            Text(
              'Tone: ${fact.tone}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),

            const Spacer(flex: 4),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Save',
                  onTap: onSave,
                ),
                _ActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Reflect',
                  isPrimary: true,
                  onTap: onReflect,
                ),
                _ActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Next',
                  onTap: onNext,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: isPrimary ? const [AppShadows.soft] : [],
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

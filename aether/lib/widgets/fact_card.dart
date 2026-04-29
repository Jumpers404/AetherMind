import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fact_model.dart';
import '../app_theme.dart';
import 'animated_mosaic_background.dart';

class FactCard extends StatefulWidget {
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
  State<FactCard> createState() => _FactCardState();
}

class _FactCardState extends State<FactCard> {
  bool _isSaved = false;

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Immersive Animated Background
        Positioned.fill(
          child: AnimatedMosaicBackground(
            animationSpeed: 1.5,
            colorIntensity: 0.85,
          ),
        ),

        // Transparent dark overlay for contrast on white text
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ),

        // Main Content (Fact Text)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              widget.fact.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Action Bar (Instagram Reels style)
        Positioned(
          right: 16,
          bottom: 110,
          child: Column(
            children: [
              _ReelAction(
                icon: _isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                iconColor: _isSaved ? const Color(0xFF4CAF50) : Colors.white,
                label: 'Save',
                onTap: _handleSave,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.edit_note_rounded,
                label: 'Reflect',
                onTap: widget.onReflect,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                onTap: () {}, // Future feature
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.more_horiz_rounded,
                label: '',
                onTap: () {},
              ),
            ],
          ),
        ),

        // Bottom Left Metadata
        Positioned(
          left: 20,
          bottom: 45,
          right: 100, // Leave space for action bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D726B), Color(0xFF5CB6A5)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.psychology_outlined, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AetherMind',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF4DAA9B), size: 16),
                        ],
                      ),
                      Text(
                        'Psychology Insights',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.fact.category} • ${widget.fact.tone}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deep Focus • Mental Awareness Audio',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  const _ReelAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 34,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 15,
              ),
            ],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../models/fact_model.dart';
import '../app_theme.dart';

class FactCard extends StatefulWidget {
  final Fact fact;
  final int index;
  final ValueChanged<bool> onSave;
  final VoidCallback onReflect;
  final VoidCallback onNext;

  const FactCard({
    super.key,
    required this.fact,
    required this.index,
    required this.onSave,
    required this.onReflect,
    required this.onNext,
  });

  @override
  State<FactCard> createState() => _FactCardState();
}

class _FactCardState extends State<FactCard> {
  bool _isSaved = false;

  Color _glassBaseColor() {
    return Colors.black.withValues(alpha: 0.2);
  }

  Color _resolveBackgroundColor() {
    const greenText = Color(0xFF2F9E6F);
    if (widget.fact.textColor == Colors.white) {
      return widget.index.isEven
          ? const Color(0xFF1D4B43)
          : Colors.black;
    }
    if (widget.fact.textColor == Colors.black) {
      return Colors.white;
    }
    if (widget.fact.textColor == greenText) {
      return widget.index.isEven ? Colors.white : Colors.black;
    }
    return widget.fact.background;
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave(_isSaved);
  }

  void _handleShare() {
    Clipboard.setData(ClipboardData(text: widget.fact.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fact copied to clipboard.')),
    );
  }

  void _handleMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _GlassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetAction(
                icon: Icons.bookmark_add_rounded,
                label: _isSaved ? 'Unsave' : 'Save',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleSave();
                },
              ),
              _SheetAction(
                icon: Icons.edit_note_rounded,
                label: 'Reflect',
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onReflect();
                },
              ),
              _SheetAction(
                icon: Icons.content_copy_rounded,
                label: 'Copy text',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleShare();
                },
              ),
              _SheetAction(
                icon: Icons.flag_rounded,
                label: 'Report',
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _resolveBackgroundColor(),
            ),
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
                color: widget.fact.textColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
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
                iconColor: _isSaved ? const Color(0xFF3AAE73) : widget.fact.textColor,
                label: 'Save',
                labelColor: widget.fact.textColor,
                glassColor: _glassBaseColor(),
                onTap: _handleSave,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.edit_note_rounded,
                label: 'Reflect',
                labelColor: widget.fact.textColor,
                glassColor: _glassBaseColor(),
                onTap: widget.onReflect,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                labelColor: widget.fact.textColor,
                glassColor: _glassBaseColor(),
                onTap: _handleShare,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.more_horiz_rounded,
                label: '',
                glassColor: _glassBaseColor(),
                onTap: _handleMore,
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
                      border: Border.all(
                        color: widget.fact.textColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D726B), Color(0xFF5CB6A5)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
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
                              color: widget.fact.textColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF4DAA9B),
                            size: 16,
                          ),
                        ],
                      ),
                      Text(
                        'Psychology Insights',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.fact.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _GlassPill(
                baseColor: _glassBaseColor(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  '${widget.fact.category} • ${widget.fact.tone}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.fact.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _GlassPill(
                baseColor: _glassBaseColor(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      color: widget.fact.textColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Instrumental • Loop',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: widget.fact.textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
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
  final Color labelColor;
  final Color glassColor;

  const _ReelAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    this.labelColor = Colors.white,
    this.glassColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          _GlassCircle(
            baseColor: glassColor,
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child, required this.baseColor});

  final Widget child;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child, this.padding, required this.baseColor});

  final Widget child;
  final EdgeInsets? padding;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

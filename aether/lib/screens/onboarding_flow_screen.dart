import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/onboarding_service.dart';
import '../widgets/animated_mosaic_background.dart';
import 'home_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const _stepsTotal = 3;
  static const _contentMaxWidth = 520.0;

  final OnboardingService _service = OnboardingService();

  int _currentStep = 0;
  bool _isSaving = false;
  bool _isForward = true;

  final List<String> _interests = [];
  final List<String> _customInterests = [];
  final Map<String, List<String>> _preferences = {
    'music': <String>[],
    'movies': <String>[],
    'activities': <String>[],
  };
  final List<String> _reliefMethods = [];

  final TextEditingController _interestInput = TextEditingController();
  final TextEditingController _musicInput = TextEditingController();
  final TextEditingController _movieInput = TextEditingController();
  final TextEditingController _activityInput = TextEditingController();

  @override
  void dispose() {
    _interestInput.dispose();
    _musicInput.dispose();
    _movieInput.dispose();
    _activityInput.dispose();
    super.dispose();
  }

  String _normalizeEntry(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _containsNormalized(List<String> list, String value) {
    final normalized = _normalizeEntry(value);
    return list.any((entry) => _normalizeEntry(entry) == normalized);
  }

  void _toggleItem(List<String> list, String value) {
    setState(() {
      if (_containsNormalized(list, value)) {
        list.removeWhere((entry) => _normalizeEntry(entry) == _normalizeEntry(value));
      } else {
        list.add(value);
      }
    });
  }

  void _addCustomEntry(List<String> list, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    if (_containsNormalized(list, value)) {
      controller.clear();
      return;
    }
    setState(() {
      list.add(value);
      controller.clear();
    });
  }

  Future<void> _saveProgress({required bool completed}) async {
    setState(() {
      _isSaving = true;
    });

    await _service.saveOnboardingProfile(
      interests: List<String>.from(_interests),
      customInterests: List<String>.from(_customInterests),
      preferences: {
        'music': List<String>.from(_preferences['music'] ?? const []),
        'movies': List<String>.from(_preferences['movies'] ?? const []),
        'activities': List<String>.from(_preferences['activities'] ?? const []),
      },
      reliefMethods: List<String>.from(_reliefMethods),
      completed: completed,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _handleSkip() async {
    if (_isSaving) {
      return;
    }
    await _service.markOnboardingSkipped();
    if (!mounted) {
      return;
    }
    _goToHome();
  }

  Future<void> _handleNext() async {
    if (_isSaving) {
      return;
    }
    final isFinal = _currentStep == _stepsTotal - 1;
    await _saveProgress(completed: isFinal);
    if (!mounted) {
      return;
    }

    if (isFinal) {
      _goToHome();
      return;
    }

    setState(() {
      _isForward = true;
      _currentStep += 1;
    });
  }

  void _handleBack() {
    if (_currentStep == 0) {
      return;
    }
    setState(() {
      _isForward = false;
      _currentStep -= 1;
    });
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedMosaicBackground(animationSpeed: 2.0),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProgressHeader(
                          currentStep: _currentStep + 1,
                          totalSteps: _stepsTotal,
                        ),
                      ),
                      TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: _OnboardingPalette.textAccent.withValues(alpha: 0.8),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 520),
                        switchInCurve: Curves.easeOutQuart,
                        switchOutCurve: Curves.easeInQuart,
                        transitionBuilder: (child, animation) {
                          final tween = Tween<Offset>(
                            begin: Offset(_isForward ? 0.08 : -0.08, 0),
                            end: Offset.zero,
                          );
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            ),
                          );
                        },
                        child: _buildStepContent(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: _GhostButton(
                            label: 'Back',
                            onTap: _handleBack,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: _PrimaryButton(
                          label: _currentStep == _stepsTotal - 1 ? 'Start Journey' : 'Continue',
                          isLoading: _isSaving,
                          onTap: _handleNext,
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
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _StepScaffold(
          key: const ValueKey('step-1'),
          title: 'Interests & passions',
          subtitle:
              'Pick a few things you love. It helps Aether tailor your space.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChipGroup(
                options: const [
                  'Tech',
                  'Music',
                  'Fitness',
                  'Gaming',
                  'Art',
                  'Coding',
                  'Reading',
                  'Nature',
                  'Design',
                  'Mindfulness',
                ],
                selectedValues: _interests,
                onToggle: (value) => _toggleItem(_interests, value),
              ),
              const SizedBox(height: 16),
              _InlineInput(
                controller: _interestInput,
                hintText: 'Add your own',
                onSubmitted: () => _addCustomEntry(_customInterests, _interestInput),
              ),
              const SizedBox(height: 12),
              _SelectionWrap(
                values: _customInterests,
                onRemove: (value) => _toggleItem(_customInterests, value),
              ),
            ],
          ),
        );
      case 1:
        return _StepScaffold(
          key: const ValueKey('step-2'),
          title: 'Preferences & comfort',
          subtitle:
              'Share what feels familiar when you want to slow down.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(text: 'Music genres'),
              _ChipGroup(
                options: const [
                  'Lo-fi',
                  'Pop',
                  'Indie',
                  'Classical',
                  'Hip-hop',
                  'Ambient',
                ],
                selectedValues: _preferences['music'] ?? const [],
                onToggle: (value) =>
                    _toggleItem(_preferences['music']!, value),
              ),
              _InlineInput(
                controller: _musicInput,
                hintText: 'Add a genre',
                onSubmitted: () =>
                    _addCustomEntry(_preferences['music']!, _musicInput),
              ),
              const SizedBox(height: 18),
              _SectionHeader(text: 'Movies & series'),
              _ChipGroup(
                options: const [
                  'Sci-Fi',
                  'Drama',
                  'Animation',
                  'Documentary',
                  'Comedy',
                  'Thriller',
                ],
                selectedValues: _preferences['movies'] ?? const [],
                onToggle: (value) =>
                    _toggleItem(_preferences['movies']!, value),
              ),
              _InlineInput(
                controller: _movieInput,
                hintText: 'Add a genre',
                onSubmitted: () =>
                    _addCustomEntry(_preferences['movies']!, _movieInput),
              ),
              const SizedBox(height: 18),
              _SectionHeader(text: 'Relaxing activities'),
              _ChipGroup(
                options: const [
                  'Journaling',
                  'Walks',
                  'Tea / Coffee',
                  'Gaming',
                  'Meditation',
                  'Stretching',
                ],
                selectedValues: _preferences['activities'] ?? const [],
                onToggle: (value) =>
                    _toggleItem(_preferences['activities']!, value),
              ),
              _InlineInput(
                controller: _activityInput,
                hintText: 'Add an activity',
                onSubmitted: () =>
                    _addCustomEntry(_preferences['activities']!, _activityInput),
              ),
            ],
          ),
        );
      case 2:
      default:
        return _StepScaffold(
          key: const ValueKey('step-3'),
          title: 'Emotional triggers & relief',
          subtitle:
              'What usually helps you feel better? Choose what feels right.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChipGroup(
                options: const [
                  'Music',
                  'Talking to someone',
                  'Being alone',
                  'Watching content',
                  'Exercise',
                  'Breathing',
                  'Grounding',
                  'Sleep',
                  'Nature',
                ],
                selectedValues: _reliefMethods,
                onToggle: (value) => _toggleItem(_reliefMethods, value),
              ),
            ],
          ),
        );
    }
  }
}

class _OnboardingPalette {
  static const background = Color(0xFFB8D3CC);
  static const surface = Color(0xFFF7FFFB);
  static const outline = Color(0xFFC5D7D1);
  static const accent = Color(0xFF2D726B);
  static const accentLight = Color(0xFF5CB6A5);
  static const textPrimary = Color(0xFF244A44);
  static const textMuted = Color(0xFF4E7E76);
  static const textAccent = Color(0xFF2D726B);
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: _OnboardingPalette.textAccent.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _OnboardingPalette.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: MediaQuery.of(context).size.width * 0.5 * (currentStep / totalSteps),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_OnboardingPalette.accent, _OnboardingPalette.accentLight],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _OnboardingPalette.accent.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StaggerReveal(
            order: 0,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Doto',
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: _OnboardingPalette.textPrimary,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _StaggerReveal(
            order: 1,
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: _OnboardingPalette.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _StaggerReveal(
            order: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _OnboardingPalette.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (option) => _SelectableChip(
              label: option,
              selected: selectedValues
                  .any((value) => value.toLowerCase() == option.toLowerCase()),
              onTap: () => onToggle(option),
            ),
          )
          .toList(),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_OnboardingPalette.accent, Color(0xFF1D5A54)],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? _OnboardingPalette.accentLight : _OnboardingPalette.outline,
            width: selected ? 1.2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _OnboardingPalette.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : _OnboardingPalette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _InlineInput extends StatelessWidget {
  const _InlineInput({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(
                color: _OnboardingPalette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              onSubmitted: (_) => onSubmitted(),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                  color: _OnboardingPalette.textMuted.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _OnboardingPalette.outline.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _OnboardingPalette.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _OnboardingPalette.accent, width: 1.2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSubmitted,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_OnboardingPalette.accent, Color(0xFF1D5A54)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _OnboardingPalette.accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionWrap extends StatelessWidget {
  const _SelectionWrap({
    required this.values,
    required this.onRemove,
  });

  final List<String> values;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => _RemovableChip(
              label: value,
              onRemove: () => onRemove(value),
            ),
          )
          .toList(),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _OnboardingPalette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _OnboardingPalette.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: _OnboardingPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _OnboardingPalette.textMuted,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D726B), Color(0xFF184F4B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D726B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _OnboardingPalette.outline.withValues(alpha: 0.8),
          width: 1.5,
        ),
        color: Colors.white.withValues(alpha: 0.15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _OnboardingPalette.textAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({
    required this.child,
    required this.order,
  });

  final Widget child;
  final int order;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 100 + (widget.order * 120)), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.15),
        child: widget.child,
      ),
    );
  }
}

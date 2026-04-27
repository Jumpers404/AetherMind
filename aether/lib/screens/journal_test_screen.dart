import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../services/journal_controller.dart';
import '../services/report_service.dart';
import 'report_screen.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';

class JournalTestScreen extends StatefulWidget {
  const JournalTestScreen({super.key});

  @override
  State<JournalTestScreen> createState() => _JournalTestScreenState();
}

class _JournalTestScreenState extends State<JournalTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalController _journalController = JournalController();
  final ReportService _reportService = ReportService();

  DateTime? _typingStart;
  DateTime? _lastKeyAt;
  String _previousText = '';
  int _keystrokeCount = 0;
  int _backspaceCount = 0;
  final List<double> _pausesSec = <double>[];

  final Map<String, String> _selectedAnswers = {};
  bool _isLoading = false;

  final List<_QuestionDef> _questions = [
    _QuestionDef(
      id: 'mood',
      title: 'How are you feeling emotionally right now?',
      sentencePrefix: 'Current mood',
      options: ['very low', 'low', 'neutral', 'good', 'very good'],
    ),
    _QuestionDef(
      id: 'energy',
      title: 'How is your energy level today?',
      sentencePrefix: 'Energy level',
      options: ['drained', 'low', 'moderate', 'high'],
    ),
    _QuestionDef(
      id: 'stress',
      title: 'How stressed or overwhelmed do you feel?',
      sentencePrefix: 'Stress level',
      options: ['very high', 'high', 'moderate', 'low'],
    ),
    _QuestionDef(
      id: 'focus',
      title: 'How well were you able to focus today?',
      sentencePrefix: 'Focus level',
      options: ['very poor', 'poor', 'average', 'good', 'excellent'],
    ),
    _QuestionDef(
      id: 'sleep',
      title: 'How was your sleep quality?',
      sentencePrefix: 'Sleep quality',
      options: ['very bad', 'bad', 'okay', 'good', 'great'],
    ),
    _QuestionDef(
      id: 'social',
      title: 'How connected did you feel with others today?',
      sentencePrefix: 'Social connection',
      options: ['isolated', 'low', 'okay', 'connected', 'very connected'],
    ),
    _QuestionDef(
      id: 'control',
      title: 'How in control did you feel today?',
      sentencePrefix: 'Sense of control',
      options: ['not at all', 'slightly', 'moderately', 'mostly', 'fully'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final now = DateTime.now();
    final current = _controller.text;

    if (_typingStart == null && current.isNotEmpty) {
      _typingStart = now;
    }

    if (_lastKeyAt != null && current != _previousText) {
      final pause = now.difference(_lastKeyAt!).inMilliseconds / 1000.0;
      if (pause >= 0) {
        _pausesSec.add(pause);
      }
    }

    final delta = current.length - _previousText.length;
    if (delta < 0) {
      _backspaceCount += delta.abs();
      _keystrokeCount += delta.abs();
    } else if (delta > 0) {
      _keystrokeCount += delta;
    } else if (current != _previousText) {
      // Replacement with same length.
      _keystrokeCount += 1;
    }

    _lastKeyAt = now;
    _previousText = current;
  }

  Map<String, dynamic>? _buildKeystrokeData() {
    if (_typingStart == null || _keystrokeCount <= 0) {
      return null;
    }

    final totalTime =
        DateTime.now().difference(_typingStart!).inMilliseconds / 1000.0;
    if (totalTime <= 0) {
      return null;
    }

    final avgPause = _pausesSec.isEmpty
        ? 0.0
        : _pausesSec.reduce((a, b) => a + b) / _pausesSec.length;
    final maxPause =
        _pausesSec.isEmpty ? 0.0 : _pausesSec.reduce((a, b) => a > b ? a : b);

    return <String, dynamic>{
      'typing_speed': _keystrokeCount / totalTime,
      'avg_pause': avgPause,
      'max_pause': maxPause,
      'backspace_count': _backspaceCount,
      'total_time': totalTime,
      'keystroke_count': _keystrokeCount,
    };
  }

  void _resetKeystrokeTracking() {
    _typingStart = null;
    _lastKeyAt = null;
    _previousText = '';
    _keystrokeCount = 0;
    _backspaceCount = 0;
    _pausesSec.clear();
  }

  String _buildPayload() {
    final lines = <String>[];

    for (final q in _questions) {
      final a = _selectedAnswers[q.id];
      if (a != null) {
        lines.add('${q.sentencePrefix}: $a.');
      }
    }

    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      lines.add('Journal note: $text');
    }

    return lines.join(' ');
  }

  Future<void> _handleSubmit() async {
    final payload = _buildPayload();

    if (payload.isEmpty) {
      _showSnack('Write something or answer a question');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Please sign in first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final keystrokeData = _buildKeystrokeData();
      final entry = await _journalController
          .createJournal(payload, keystrokeData: keystrokeData)
          .timeout(const Duration(seconds: 12));

      if (entry == null) throw Exception("Save failed");

      final report = _reportService.generateSingleEntryReport(entry);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReportScreen(report: report)),
      );

      _controller.clear();
      _resetKeystrokeTracking();
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Journal',
          style: TextStyle(
            fontFamily: 'Doto',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
            child: Column(
              children: [
                _InfoCard(),
                const SizedBox(height: AppSpacing.md),

                ..._questions.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _QuestionCard(
                        q: q,
                        selected: _selectedAnswers[q.id],
                        onSelect: (v) {
                          setState(() => _selectedAnswers[q.id] = v);
                        },
                      ),
                )),

                _FreeWriteCard(controller: _controller),
              ],
            ),
          ),

          /// Sticky Button
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: _SubmitButton(
              isLoading: _isLoading,
              onTap: _handleSubmit,
            ),
          )
        ],
      ),
    );
  }
}

/* ---------------- UI ---------------- */

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFDCF4E9),
          Colors.white.withValues(alpha: 0.9),
        ],
      ),
      child: Text(
        'Reflect on your day. Answer a few prompts or write freely.',
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2F5C63),
        ),
      ),
    );
  }
}

class _FreeWriteCard extends StatelessWidget {
  const _FreeWriteCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: TextField(
        controller: controller,
        minLines: 5,
        maxLines: 10,
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Write thoughts, triggers, wins...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.background),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap, required this.isLoading});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Submit Entry',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}

/* ---------------- QUESTIONS ---------------- */

class _QuestionDef {
  const _QuestionDef({
    required this.id,
    required this.title,
    required this.sentencePrefix,
    required this.options,
  });

  final String id;
  final String title;
  final String sentencePrefix;
  final List<String> options;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.q,
    required this.selected,
    required this.onSelect,
  });

  final _QuestionDef q;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.title,
            style: const TextStyle(
              fontFamily: 'Doto',
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: q.options.map((o) {
              return AppChip(
                label: o,
                isSelected: selected == o,
                onTap: () => onSelect(o),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../services/journal_controller.dart';
import '../services/report_service.dart';
import 'report_screen.dart';

class JournalTestScreen extends StatefulWidget {
  const JournalTestScreen({super.key});

  @override
  State<JournalTestScreen> createState() => _JournalTestScreenState();
}

class _JournalTestScreenState extends State<JournalTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalController _journalController = JournalController();
  final ReportService _reportService = ReportService();

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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      final entry = await _journalController
          .createJournal(payload)
          .timeout(const Duration(seconds: 12));

      if (entry == null) throw Exception("Save failed");

      final report = _reportService.generateSingleEntryReport(entry);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReportScreen(report: report)),
      );

      _controller.clear();
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
      backgroundColor: const Color(0xFFF5FAF7),
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
            color: Color(0xFF1E3A46),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
            child: Column(
              children: [
                _InfoCard(),
                const SizedBox(height: 14),

                ..._questions.map((q) => _QuestionCard(
                      q: q,
                      selected: _selectedAnswers[q.id],
                      onSelect: (v) {
                        setState(() => _selectedAnswers[q.id] = v);
                      },
                    )),

                const SizedBox(height: 14),
                _FreeWriteCard(controller: _controller),
              ],
            ),
          ),

          /// Sticky Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
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
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.94,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFDCF4E9),
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: Text(
            'Reflect on your day. Answer a few prompts or write freely.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2F5C63),
            ),
          ),
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
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.94,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            minLines: 5,
            maxLines: 10,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Write thoughts, triggers, wins...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
        backgroundColor: const Color.fromARGB(255, 36, 120, 116),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'Submit Entry',
              style: GoogleFonts.poppins(
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
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.94,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.92),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203A43).withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q.title,
                style: const TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF21464D),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: q.options.map((o) {
                  final isSelected = selected == o;

                  return GestureDetector(
                    onTap: () => onSelect(o),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? const Color(0xFFDDF5EA)
                            : const Color(0xFFF5FAF7),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8ED7B7)
                              : const Color(0xFFD7E7E1),
                        ),
                      ),
                      child: Text(
                        o,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF1E5944)
                              : const Color(0xFF335D63),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
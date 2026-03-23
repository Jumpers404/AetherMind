import 'dart:async';

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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFDCF4E9),
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3C46).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.2,
          height: 1.4,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.92),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203A43).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write more if you want',
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF21464D),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 8,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF2A5058),
            ),
            decoration: InputDecoration(
              hintText: 'Write thoughts, triggers, wins, or anything on your mind...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF6A7E86),
              ),
              filled: true,
              fillColor: const Color(0xFFF4FAF7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD3E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD3E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF4CB68D),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  final _QuestionDef question;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.92),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203A43).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF21464D),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((option) {
              final isSelected = selectedValue == option;
              return ChoiceChip(
                label: Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF1E5944) : const Color(0xFF335D63),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onSelected(option),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF8ED7B7) : const Color(0xFFD7E7E1),
                  ),
                ),
                backgroundColor: const Color(0xFFF5FAF7),
                selectedColor: const Color(0xFFDDF5EA),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _JournalTestScreenState extends State<JournalTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalController _journalController = JournalController();
  final ReportService _reportService = ReportService();
  final Map<String, String> _selectedAnswers = <String, String>{};
  bool _isLoading = false;
  final List<_QuestionDef> _questions = <_QuestionDef>[
    const _QuestionDef(
      id: 'mood',
      title: 'How would you describe your mood right now?',
      sentencePrefix: 'Current mood',
      options: <String>['very low', 'a bit down', 'neutral', 'good', 'very good'],
    ),
    const _QuestionDef(
      id: 'energy',
      title: 'What is your energy level today?',
      sentencePrefix: 'Energy level',
      options: <String>['drained', 'low', 'moderate', 'high'],
    ),
    const _QuestionDef(
      id: 'stress',
      title: 'How stressed or overwhelmed do you feel?',
      sentencePrefix: 'Stress level',
      options: <String>['very high', 'high', 'moderate', 'low', 'very low'],
    ),
    const _QuestionDef(
      id: 'control',
      title: 'How in control do you feel with today\'s challenges?',
      sentencePrefix: 'Sense of control',
      options: <String>[
        'not in control',
        'slightly in control',
        'mostly in control',
        'fully in control',
      ],
    ),
    const _QuestionDef(
      id: 'support',
      title: 'How connected and supported do you feel?',
      sentencePrefix: 'Support feeling',
      options: <String>['isolated', 'somewhat disconnected', 'okay', 'supported', 'deeply supported'],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildHybridEntryText() {
    final lines = <String>[];

    for (final q in _questions) {
      final answer = _selectedAnswers[q.id];
      if (answer == null || answer.isEmpty) {
        continue;
      }
      lines.add('${q.sentencePrefix}: $answer.');
    }

    final freeText = _controller.text.trim();
    if (freeText.isNotEmpty) {
      lines.add('Journal note: $freeText');
    }

    return lines.join(' ');
  }

  List<Widget> _buildPageChildren(List<Widget> questionWidgets) {
    final children = <Widget>[
      _InfoCard(
        text:
        'This is a hybrid journal — answer quick questions and/or write freely; it also works great if you prefer to simply write a journal entry.',
      ),
      const SizedBox(height: 14),
    ];

    children.addAll(questionWidgets);
    children.addAll(<Widget>[
      const SizedBox(height: 4),
      _FreeWriteCard(controller: _controller),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 37, 130, 115),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Submit',
                style: const TextStyle(
                  fontFamily: 'Doto',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ]);

    return children;
  }

  Future<void> _handleSubmit() async {
    final payload = _buildHybridEntryText();
    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select options, write a note, or both.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final entry = await _journalController
          .createJournal(payload)
          .timeout(const Duration(seconds: 12));

      if (!mounted) {
        return;
      }

      if (entry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save journal')),
        );
        return;
      }

      final report = _reportService.generateSingleEntryReport(entry);

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportScreen(report: report),
        ),
      );
      _controller.clear();
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> questionWidgets = <Widget>[];
    for (final _QuestionDef q in _questions) {
      questionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QuestionCard(
            question: q,
            selectedValue: _selectedAnswers[q.id],
            onSelected: (String value) {
              setState(() {
                _selectedAnswers[q.id] = value;
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        title: const Text('Write Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save & Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}

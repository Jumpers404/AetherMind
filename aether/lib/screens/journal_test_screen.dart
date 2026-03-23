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

class _JournalTestScreenState extends State<JournalTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalController _journalController = JournalController();
  final ReportService _reportService = ReportService();
  final Map<String, String> _selectedAnswers = <String, String>{};
  bool _isLoading = false;

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
      print('STEP 1: Calling createJournal');
    final entry = await _journalController
      .createJournal(text)
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

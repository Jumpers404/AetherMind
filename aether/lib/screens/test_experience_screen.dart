import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestData {
  const TestData({
    required this.id,
    required this.title,
    required this.scenes,
    required this.results,
    required this.primaryColor,
    required this.scoringKey,
  });

  final String id;
  final String title;
  final List<Scene> scenes;
  final Map<String, String> results; // simple keys: low/moderate/high -> insight
  final Color primaryColor;
  final String scoringKey;

  static TestData anxietyTest() => TestData(
        id: 'anxiety',
        title: 'Anxiety Test',
        scoringKey: 'anxiety',
        primaryColor: const Color(0xFF78A8E6),
        scenes: const [
          Scene(
            text:
                'You step into a quiet room with soft lights; the air feels slightly still and your breath notices the hush.',
            choices: [
              Choice(text: 'Pause and notice the details', effects: {'anxiety': 1}),
              Choice(text: 'Keep moving through the space', effects: {'anxiety': 2}),
              Choice(text: 'Leave as quickly as possible', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text:
                'A gentle conversation begins near you, but the words drift and you catch only fragments of their meaning.',
            choices: [
              Choice(text: 'Listen to how your body responds', effects: {'anxiety': 1}),
              Choice(text: 'Smile and nod along', effects: {'anxiety': 2}),
              Choice(text: 'Make a small excuse to step away', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text:
                'Outside, rain taps the windows; a thought rises about what might come next, like a soft wave.',
            choices: [
              Choice(text: 'Breathe slowly and stay present', effects: {'anxiety': 1}),
              Choice(text: 'Plan a list of what could happen', effects: {'anxiety': 2}),
              Choice(text: 'Imagine worst-case quickly', effects: {'anxiety': 3}),
            ],
          ),
        ],
        results: const {
          'low': 'You show gentle signs of unease but remain grounded. Small breathing practices may help.',
          'moderate': 'There is a recurring tension; try short grounding checks and small pauses through the day.',
          'high': 'You often feel strongly on edge. Consider reaching out for steadying routines or a supportive check-in.',
        },
      );

  static TestData depressionTest() => TestData(
        id: 'depression',
        title: 'Depression Test',
        scoringKey: 'depression',
        primaryColor: const Color(0xFFBFC8D6),
        scenes: const [
          Scene(
            text:
                'You notice the room feels dimmer today; colors seem quieter and movement slower.',
            choices: [
              Choice(text: 'Sit with the quiet for a moment', effects: {'depression': 1}),
              Choice(text: 'Try to push through with a task', effects: {'depression': 2}),
              Choice(text: 'Cancel plans and stay in', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text:
                'An old photograph lies on a table; a memory brushes by and you feel a distance from it.',
            choices: [
              Choice(text: 'Gently recall the small detail that comforts', effects: {'depression': 1}),
              Choice(text: 'Put the photo away', effects: {'depression': 2}),
              Choice(text: 'Avoid looking at photographs today', effects: {'depression': 3}),
            ],
          ),
        ],
        results: const {
          'low': 'You carry a light heaviness; small routines and sunlight may help gently lift mood.',
          'moderate': 'There is a slowing pattern. Consider brief routines and kindly check-ins with someone you trust.',
          'high': 'A deep low is present. A steady routine and supportive contact could offer safety and relief.',
        },
      );

  static TestData stressTest() => TestData(
        id: 'stress',
        title: 'Stress Test',
        scoringKey: 'stress',
        primaryColor: const Color(0xFFF49A5A),
        scenes: const [
          Scene(
            text: 'A clock ticks faster than usual and a list of small tasks grows in your mind.',
            choices: [
              Choice(text: 'Breathe and prioritize one thing', effects: {'stress': 1}),
              Choice(text: 'Try to complete everything at once', effects: {'stress': 3}),
              Choice(text: 'Step away briefly to clear thoughts', effects: {'stress': 2}),
            ],
          ),
          Scene(
            text: 'Someone asks for a quick favor while your plate feels full.',
            choices: [
              Choice(text: 'Offer a small boundary', effects: {'stress': 1}),
              Choice(text: 'Say yes but feel rushed', effects: {'stress': 2}),
              Choice(text: 'Say yes immediately to avoid conflict', effects: {'stress': 3}),
            ],
          ),
        ],
        results: const {
          'low': 'Stress is present but manageable. Short pauses and small boundaries help.',
          'moderate': 'Tension is consistent. Try short resets and clearer limits around tasks.',
          'high': 'The load feels heavy. A slower pace and supportive conversation may reduce strain.',
        },
      );

  static TestData selfEsteemTest() => TestData(
        id: 'selfesteem',
        title: 'Self-esteem Test',
        scoringKey: 'selfesteem',
        primaryColor: const Color(0xFF5BC79C),
        scenes: const [
          Scene(
            text: 'You notice your reflection briefly and the small voice of judgement speaks up.',
            choices: [
              Choice(text: 'Notice one small kindness about yourself', effects: {'selfesteem': 1}),
              Choice(text: 'Ignore the reflection', effects: {'selfesteem': 2}),
              Choice(text: 'Get frustrated with yourself', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'A simple task finishes differently than you hoped; a thought about worth follows.',
            choices: [
              Choice(text: 'Acknowledge the effort first', effects: {'selfesteem': 1}),
              Choice(text: 'Focus on the outcome only', effects: {'selfesteem': 3}),
              Choice(text: 'Remind yourself of past small wins', effects: {'selfesteem': 1}),
            ],
          ),
        ],
        results: const {
          'low': 'You hold a gentle regard for yourself. Keep practicing brief affirmations.',
          'moderate': 'Self-doubt appears. Small, kind reminders of capability can help.',
          'high': 'Self-criticism is frequent. Consider supportive routines that reinforce small wins.',
        },
      );
}

class Scene {
  const Scene({required this.text, required this.choices});

  final String text;
  final List<Choice> choices;
}

class Choice {
  const Choice({required this.text, required this.effects});

  final String text;
  final Map<String, int> effects;
}

class TestExperienceScreen extends StatefulWidget {
  const TestExperienceScreen({super.key, required this.testData});

  final TestData testData;

  @override
  State<TestExperienceScreen> createState() => _TestExperienceScreenState();
}

class _TestExperienceScreenState extends State<TestExperienceScreen> {
  int _currentIndex = 0;
  final Map<String, int> _scores = {};
  int? _pressedChoiceIndex;

  void _handleChoiceTap(Choice choice, int idx) async {
    if (_pressedChoiceIndex != null) return;
    setState(() => _pressedChoiceIndex = idx);
    await Future.delayed(const Duration(milliseconds: 220));

    // apply effects
    for (final k in choice.effects.keys) {
      _scores[k] = (_scores[k] ?? 0) + (choice.effects[k] ?? 0);
    }

    if (!mounted) return;

    if (_currentIndex < widget.testData.scenes.length - 1) {
      setState(() {
        _currentIndex += 1;
        _pressedChoiceIndex = null;
      });
    } else {
      // finalize
      final total = _scores[widget.testData.scoringKey] ?? 0;
      final label = _severityLabel(total);
      final insight = widget.testData.results[label] ?? '';

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            title: widget.testData.title,
            label: label,
            insight: insight,
            onRetake: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TestExperienceScreen(testData: widget.testData),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  String _severityLabel(int score) {
    if (score <= 3) return 'low';
    if (score <= 6) return 'moderate';
    return 'high';
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.testData.scenes[_currentIndex];
    final progress = (_currentIndex + 1) / widget.testData.scenes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF21464D)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.testData.title,
                      style: const TextStyle(
                        fontFamily: 'Doto',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF21464D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.testData.primaryColor.withOpacity(0.9)),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
                        .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: _StoryCard(
                    key: ValueKey(_currentIndex),
                    color: widget.testData.primaryColor.withOpacity(0.08),
                    text: scene.text,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scene.choices.asMap().entries.map((e) {
                  final idx = e.key;
                  final choice = e.value;
                  final pressed = _pressedChoiceIndex == idx;

                  return GestureDetector(
                    onTap: () => _handleChoiceTap(choice, idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: pressed ? widget.testData.primaryColor.withOpacity(0.16) : const Color(0xFFF5FAF7),
                        border: Border.all(
                          color: pressed ? widget.testData.primaryColor.withOpacity(0.28) : const Color(0xFFEAF3EF),
                        ),
                      ),
                      child: AnimatedScale(
                        scale: pressed ? 0.98 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        child: Text(
                          choice.text,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: pressed ? widget.testData.primaryColor.darken() : const Color(0xFF335D63),
                          ),
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.96,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203A43).withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14.2, height: 1.4, color: const Color(0xFF21464D)),
          ),
        ),
      ),
    );
  }
}

class TestResultScreen extends StatelessWidget {
  const TestResultScreen({
    super.key,
    required this.title,
    required this.label,
    required this.insight,
    required this.onRetake,
  });

  final String title;
  final String label;
  final String insight;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final displayTitle = label == 'low'
        ? 'Mild'
        : label == 'moderate'
            ? 'Moderate'
            : 'Strong';

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.white, const Color(0xFFF4F9F7)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$displayTitle ${title.split(' ').first}',
                        style: const TextStyle(
                          fontFamily: 'Doto',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF21464D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        insight,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13.2, color: const Color(0xFF5F7380)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: onRetake,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF36B37E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Retake'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                            child: const Text('Back to Home'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _ColorHelpers on Color {
  Color darken([double amount = .12]) {
    final f = 1 - amount;
    return Color.fromARGB(this.alpha, (this.red * f).round(), (this.green * f).round(), (this.blue * f).round());
  }
}

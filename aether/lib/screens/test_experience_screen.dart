// Interactive test/experience screens used for small in-app assessments.
// Contains mini-simulations and scoring helpers used for demo content.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

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
  final Map<String, String> results;
  final Color primaryColor;
  final String scoringKey;

  static TestData anxietyTest() => TestData(
        id: 'anxiety',
        title: 'Anxiety Test',
        scoringKey: 'anxiety',
        primaryColor: const Color(0xFF78A8E6),
        scenes: const [
          Scene(
            text: 'You step into a quiet room with soft lights; the air feels slightly still and your breath notices the hush.',
            choices: [
              Choice(text: 'Pause and notice the details', effects: {'anxiety': 1}),
              Choice(text: 'Keep moving through the space', effects: {'anxiety': 2}),
              Choice(text: 'Leave as quickly as possible', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'A gentle conversation begins near you, but the words drift and you catch only fragments of their meaning.',
            choices: [
              Choice(text: 'Listen to how your body responds', effects: {'anxiety': 1}),
              Choice(text: 'Smile and nod along', effects: {'anxiety': 2}),
              Choice(text: 'Make a small excuse to step away', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'Outside, rain taps the windows; a thought rises about what might come next, like a soft wave.',
            choices: [
              Choice(text: 'Breathe slowly and stay present', effects: {'anxiety': 1}),
              Choice(text: 'Plan a list of what could happen', effects: {'anxiety': 2}),
              Choice(text: 'Imagine worst-case quickly', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You receive an unexpected message — the sender is unknown and the subject is vague.',
            choices: [
              Choice(text: 'Open it with calm curiosity', effects: {'anxiety': 1}),
              Choice(text: 'Check it but feel unsettled', effects: {'anxiety': 2}),
              Choice(text: 'Ignore it and feel tense all day', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'At a gathering, someone across the room glances at you briefly.',
            choices: [
              Choice(text: 'Smile and continue what you\'re doing', effects: {'anxiety': 1}),
              Choice(text: 'Wonder if you said something wrong', effects: {'anxiety': 2}),
              Choice(text: 'Feel a sudden urge to leave', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You have a task due tomorrow that you haven\'t started yet.',
            choices: [
              Choice(text: 'Start with a small step tonight', effects: {'anxiety': 1}),
              Choice(text: 'Feel worried but distract yourself', effects: {'anxiety': 2}),
              Choice(text: 'Feel overwhelmed and unable to begin', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You\'re waiting for an important phone call that is running late.',
            choices: [
              Choice(text: 'Trust that it will come in time', effects: {'anxiety': 1}),
              Choice(text: 'Check your phone repeatedly', effects: {'anxiety': 2}),
              Choice(text: 'Assume something has gone wrong', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You\'re asked to speak briefly in front of a small group.',
            choices: [
              Choice(text: 'Feel prepared and calm', effects: {'anxiety': 1}),
              Choice(text: 'Feel nervous but manage', effects: {'anxiety': 2}),
              Choice(text: 'Feel frozen and want to refuse', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You make a small mistake at work — something easy to fix.',
            choices: [
              Choice(text: 'Correct it and move on', effects: {'anxiety': 1}),
              Choice(text: 'Worry about how it looks', effects: {'anxiety': 2}),
              Choice(text: 'Replay it throughout the day', effects: {'anxiety': 3}),
            ],
          ),
          Scene(
            text: 'You wake up early and can\'t fall back asleep; the silence feels heavy.',
            choices: [
              Choice(text: 'Use the time for something peaceful', effects: {'anxiety': 1}),
              Choice(text: 'Lie there feeling restless', effects: {'anxiety': 2}),
              Choice(text: 'Feel a wave of worry with no clear cause', effects: {'anxiety': 3}),
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
            text: 'You notice the room feels dimmer today; colors seem quieter and movement slower.',
            choices: [
              Choice(text: 'Sit with the quiet for a moment', effects: {'depression': 1}),
              Choice(text: 'Try to push through with a task', effects: {'depression': 2}),
              Choice(text: 'Cancel plans and stay in', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'An old photograph lies on a table; a memory brushes by and you feel a distance from it.',
            choices: [
              Choice(text: 'Gently recall the small detail that comforts', effects: {'depression': 1}),
              Choice(text: 'Put the photo away', effects: {'depression': 2}),
              Choice(text: 'Avoid looking at photographs today', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'A friend invites you to join them for a short walk outside.',
            choices: [
              Choice(text: 'Go — the fresh air sounds nice', effects: {'depression': 1}),
              Choice(text: 'Hesitate but eventually agree', effects: {'depression': 2}),
              Choice(text: 'Decline without explaining why', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'You finish eating a meal and notice you barely tasted it.',
            choices: [
              Choice(text: 'Sip something warm and pause', effects: {'depression': 1}),
              Choice(text: 'Clear up and move on quietly', effects: {'depression': 2}),
              Choice(text: 'Feel a hollow heaviness afterward', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'A hobby you once loved is right in front of you.',
            choices: [
              Choice(text: 'Pick it up with some enthusiasm', effects: {'depression': 1}),
              Choice(text: 'Touch it but put it back down', effects: {'depression': 2}),
              Choice(text: 'Feel nothing and walk away', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'You wake up and the day stretches ahead with no plans.',
            choices: [
              Choice(text: 'Feel a small sense of possibility', effects: {'depression': 1}),
              Choice(text: 'Feel uncertain how to fill the time', effects: {'depression': 2}),
              Choice(text: 'Feel too tired to start anything', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'Someone compliments something you did recently.',
            choices: [
              Choice(text: 'Thank them and feel a small warmth', effects: {'depression': 1}),
              Choice(text: 'Brush it off politely', effects: {'depression': 2}),
              Choice(text: 'Doubt they mean it', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'The evening light grows soft and night approaches.',
            choices: [
              Choice(text: 'Feel a quiet calm settle in', effects: {'depression': 1}),
              Choice(text: 'Feel time passing a little blankly', effects: {'depression': 2}),
              Choice(text: 'Dread the stillness that comes with night', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'You look in the mirror briefly before leaving the house.',
            choices: [
              Choice(text: 'Give yourself a small nod and go', effects: {'depression': 1}),
              Choice(text: 'Look away quickly', effects: {'depression': 2}),
              Choice(text: 'Feel disconnected from the person staring back', effects: {'depression': 3}),
            ],
          ),
          Scene(
            text: 'A song you once listened to often starts playing.',
            choices: [
              Choice(text: 'Let it play and feel a gentle lift', effects: {'depression': 1}),
              Choice(text: 'Notice it but feel distant', effects: {'depression': 2}),
              Choice(text: 'Turn it off — it feels too heavy', effects: {'depression': 3}),
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
          Scene(
            text: 'You notice your jaw is clenched and your shoulders tight.',
            choices: [
              Choice(text: 'Take a slow breath and release', effects: {'stress': 1}),
              Choice(text: 'Acknowledge it but keep going', effects: {'stress': 2}),
              Choice(text: 'Push through without noticing', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'You receive three messages and two calls in ten minutes.',
            choices: [
              Choice(text: 'Respond calmly when ready', effects: {'stress': 1}),
              Choice(text: 'Feel pressure to reply immediately', effects: {'stress': 2}),
              Choice(text: 'Feel overwhelmed and freeze', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'A plan you prepared carefully falls through at the last moment.',
            choices: [
              Choice(text: 'Adapt and find an alternative', effects: {'stress': 1}),
              Choice(text: 'Feel frustrated but problem-solve', effects: {'stress': 2}),
              Choice(text: 'Feel deeply stressed and helpless', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'You haven\'t had a real break in several days.',
            choices: [
              Choice(text: 'Block out time today deliberately', effects: {'stress': 1}),
              Choice(text: 'Know you need one but delay it', effects: {'stress': 2}),
              Choice(text: 'Feel guilty even thinking about it', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'You try to sleep but your mind keeps running through tomorrow.',
            choices: [
              Choice(text: 'Write a list and let go', effects: {'stress': 1}),
              Choice(text: 'Lie restlessly for a while', effects: {'stress': 2}),
              Choice(text: 'Stay awake for hours replaying things', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'A decision at work lands with you and only you.',
            choices: [
              Choice(text: 'Trust your judgment and decide', effects: {'stress': 1}),
              Choice(text: 'Deliberate longer than needed', effects: {'stress': 2}),
              Choice(text: 'Feel paralyzed by the weight of it', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'You finish a long day and someone at home needs help immediately.',
            choices: [
              Choice(text: 'Breathe and engage warmly', effects: {'stress': 1}),
              Choice(text: 'Help but feel drained', effects: {'stress': 2}),
              Choice(text: 'Feel resentment rising', effects: {'stress': 3}),
            ],
          ),
          Scene(
            text: 'You look at your schedule for next week and it is packed.',
            choices: [
              Choice(text: 'Identify one thing to protect as rest', effects: {'stress': 1}),
              Choice(text: 'Feel a low hum of dread', effects: {'stress': 2}),
              Choice(text: 'Feel a sharp spike of stress immediately', effects: {'stress': 3}),
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
          Scene(
            text: 'You are about to share an idea in a group setting.',
            choices: [
              Choice(text: 'Share it — your ideas are valid', effects: {'selfesteem': 1}),
              Choice(text: 'Share it hesitantly', effects: {'selfesteem': 2}),
              Choice(text: 'Stay quiet, assuming it\'s not good enough', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'Someone achieves something you wanted for yourself.',
            choices: [
              Choice(text: 'Feel genuinely pleased for them', effects: {'selfesteem': 1}),
              Choice(text: 'Feel a mix of inspired and uneasy', effects: {'selfesteem': 2}),
              Choice(text: 'Feel diminished by their success', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'You make a decision that turns out well.',
            choices: [
              Choice(text: 'Acknowledge your role in the outcome', effects: {'selfesteem': 1}),
              Choice(text: 'Credit it mostly to luck', effects: {'selfesteem': 2}),
              Choice(text: 'Wait for it to unravel — it won\'t last', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'You try something new and make a few beginner mistakes.',
            choices: [
              Choice(text: 'Expect this and learn from it', effects: {'selfesteem': 1}),
              Choice(text: 'Feel embarrassed but continue', effects: {'selfesteem': 2}),
              Choice(text: 'Conclude you are not capable', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'A peer is praised heavily in front of the group.',
            choices: [
              Choice(text: 'Feel secure in your own path', effects: {'selfesteem': 1}),
              Choice(text: 'Wonder if you measure up', effects: {'selfesteem': 2}),
              Choice(text: 'Feel invisible and undervalued', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'You receive constructive feedback from someone you respect.',
            choices: [
              Choice(text: 'Receive it openly and reflect', effects: {'selfesteem': 1}),
              Choice(text: 'Feel stung but process it', effects: {'selfesteem': 2}),
              Choice(text: 'Take it as proof you aren\'t good enough', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'You say no to something you do not want to do.',
            choices: [
              Choice(text: 'Feel comfortable setting the boundary', effects: {'selfesteem': 1}),
              Choice(text: 'Say no but feel guilty afterward', effects: {'selfesteem': 2}),
              Choice(text: 'Agree even though you don\'t want to', effects: {'selfesteem': 3}),
            ],
          ),
          Scene(
            text: 'You sit quietly for a moment with no task ahead of you.',
            choices: [
              Choice(text: 'Feel comfortable simply being', effects: {'selfesteem': 1}),
              Choice(text: 'Feel restless without a purpose', effects: {'selfesteem': 2}),
              Choice(text: 'Feel your worth is tied to being productive', effects: {'selfesteem': 3}),
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
    if (score <= 10) return 'low';
    if (score <= 20) return 'moderate';
    return 'high';
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.testData.scenes[_currentIndex];
    final progress = (_currentIndex + 1) / widget.testData.scenes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.testData.title,
                          style: const TextStyle(
                            fontFamily: 'Doto',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.testData.scenes.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.testData.primaryColor.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation);
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
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: scene.choices.asMap().entries.map((e) {
                  final idx = e.key;
                  final choice = e.value;
                  final pressed = _pressedChoiceIndex == idx;

                  return GestureDetector(
                    onTap: () => _handleChoiceTap(choice, idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        color: pressed
                            ? widget.testData.primaryColor.withOpacity(0.16)
                            : Colors.white,
                        border: Border.all(
                          color: pressed
                              ? widget.testData.primaryColor.withOpacity(0.3)
                              : const Color(0xFFEAF3EF),
                        ),
                      ),
                      child: Text(
                        choice.text,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: pressed ? FontWeight.w600 : FontWeight.w500,
                          color: pressed
                              ? widget.testData.primaryColor._darken()
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
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
      child: AppCard(
        color: color,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14.2,
            height: 1.6,
            color: AppColors.textPrimary,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$displayTitle ${title.split(' ').first}',
                      style: const TextStyle(
                        fontFamily: 'Doto',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      insight,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: onRetake,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: const Text(
                            'Retake',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _ColorDarken on Color {
  Color _darken([double amount = .12]) {
    final f = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:aether/models/journal_entry.dart';
import 'package:aether/services/insight_service.dart';

JournalEntry _entry({
  required String text,
  required String emotion,
  required double sentiment,
  DateTime? timestamp,
}) {
  return JournalEntry(
    id: 'id-${timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
    userId: 'u1',
    text: text,
    timestamp: timestamp ?? DateTime.now(),
    sentimentScore: sentiment,
    emotion: emotion,
    intensity: 5,
    triggers: const <String>[],
    keywords: const <String>[],
    stressKeywords: const <String>[],
    cognitivePatterns: const <String>[],
    sentimentLabel: sentiment >= 0.2 ? 'positive' : sentiment <= -0.2 ? 'negative' : 'neutral',
    processed: true,
  );
}

void main() {
  const service = InsightService();

  test('happy single entry should stay low stress with no risk flags', () {
    final insights = service.generateClinicalInsights(<JournalEntry>[
      _entry(text: 'I feel happy, calm and grateful today.', emotion: 'happy', sentiment: 0.8),
    ]);

    expect(insights['stress_level'], equals('low'));
    expect((insights['risk_flags'] as List), isEmpty);
  });

  test('depressed single entry should not be low stress', () {
    final insights = service.generateClinicalInsights(<JournalEntry>[
      _entry(text: 'I feel depressed and hopeless.', emotion: 'sadness', sentiment: -0.7),
    ]);

    expect(insights['stress_level'], isNot(equals('low')));
  });

  test('suicidal language should trigger crisis/high risk and high stress', () {
    final insights = service.generateClinicalInsights(<JournalEntry>[
      _entry(
        text: 'I feel suicidal and want to end my life.',
        emotion: 'sadness',
        sentiment: -0.9,
      ),
    ]);

    final flags = (insights['risk_flags'] as List).whereType<String>().toList();
    expect(insights['stress_level'], equals('high'));
    expect(flags, contains('crisis'));
    expect(flags, contains('high_risk'));
    expect(insights['emotional_variability'], equals('high'));
  });
}

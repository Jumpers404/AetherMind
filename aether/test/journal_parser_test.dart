import 'package:flutter_test/flutter_test.dart';

import 'package:aether/services/journal_parser.dart';

void _assertValidSentimentRange(double score) {
  expect(score, lessThanOrEqualTo(1));
  expect(score, greaterThanOrEqualTo(-1));
}

void main() {
  group('Negation Tests', () {
    test('not happy becomes negative', () {
      final score = JournalParser.getSentiment('I am not happy');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-1.0, 0.2));
      expect(label, equals('negative'));
    });

    test('not stressed anymore becomes positive', () {
      final score = JournalParser.getSentiment('I am not stressed anymore');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(1.0, 0.2));
      expect(label, equals('positive'));
    });

    test('not sad but tired leans negative', () {
      final score = JournalParser.getSentiment('I am not sad but tired');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-0.6, 0.2));
      expect(label, equals('negative'));
    });
  });

  group('Contrast Tests', () {
    test('stressed but better ends positive', () {
      final score = JournalParser.getSentiment('I was stressed but now I feel better');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(1.0, 0.2));
      expect(label, equals('positive'));
    });

    test('good but overwhelmed ends negative', () {
      final score = JournalParser.getSentiment("I felt good but now I'm overwhelmed");
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-1.0, 0.2));
      expect(label, equals('negative'));
    });
  });

  group('Intensity Tests', () {
    test('very stressed is negative and intense', () {
      final score = JournalParser.getSentiment('I am very stressed');
      final label = JournalParser.getSentimentLabel(score);
      final intensity = JournalParser.getIntensityFromText('I am very stressed', score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-1.0, 0.2));
      expect(label, equals('negative'));
      expect(intensity, greaterThan(7));
    });

    test('slightly sad remains negative', () {
      final score = JournalParser.getSentiment('I am slightly sad');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-1.0, 0.2));
      expect(label, equals('negative'));
    });

    test('extremely happy is positive', () {
      final score = JournalParser.getSentiment('I am extremely happy');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(1.0, 0.2));
      expect(label, equals('positive'));
    });

    test('happy repetition boosts intensity', () {
      final text = 'I feel happy happy happy';
      final score = JournalParser.getSentiment(text);
      final label = JournalParser.getSentimentLabel(score);
      final intensity = JournalParser.getIntensityFromText(text, score);

      _assertValidSentimentRange(score);
      expect(label, equals('positive'));
      expect(intensity, greaterThan(7));
    });
  });

  group('Real-world Cases', () {
    test('messy mixed sentence can still lean positive due to negated second bad', () {
      final score = JournalParser.getSentiment('idk man today was kinda bad but like not too bad');
      final label = JournalParser.getSentimentLabel(score);

      _assertValidSentimentRange(score);
      expect(score, closeTo(0.6, 0.2));
      expect(label, equals('positive'));
    });

    test('killing me phrase is strongly negative', () {
      final text = "ugh exams are killing me but I'll manage";
      final score = JournalParser.getSentiment(text);
      final label = JournalParser.getSentimentLabel(score);
      final stressKeywords = JournalParser.getStressKeywords(text);

      _assertValidSentimentRange(score);
      expect(score, closeTo(-0.8, 0.2));
      expect(label, equals('negative'));
      expect(stressKeywords, anyOf(isEmpty, isA<List<String>>()));
    });

    test('depressed/worst-day text should not be neutral emotion', () {
      const text = 'I am very depressed and not happy at all, i had the worst day possible';
      final emotion = JournalParser.getEmotion(text);
      final score = JournalParser.getSentiment(text);

      expect(score, lessThan(0));
      expect(emotion, equals('sadness'));
      expect(emotion, isNot(equals('neutral')));
    });
  });
}

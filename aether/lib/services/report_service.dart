import '../models/journal_entry.dart';
import 'insight_service.dart';

class MentalHealthReport {
  const MentalHealthReport({
    required this.totalEntries,
    required this.averageSentiment,
    required this.dominantEmotion,
    required this.emotionDistribution,
    required this.triggerFrequency,
    required this.highStressDetected,
    required this.trend,
    required this.stressLevel,
    required this.emotionalVariability,
    required this.riskFlags,
    required this.behavioralInsights,
    required this.keystrokeEmotion,
    required this.keystrokeConfidence,
    required this.summary,
  });

  final int totalEntries;
  final double averageSentiment;
  final String dominantEmotion;
  final Map<String, int> emotionDistribution;
  final Map<String, int> triggerFrequency;
  final bool highStressDetected;
  final String trend;
  final String stressLevel;
  final String emotionalVariability;
  final List<String> riskFlags;
  final List<String> behavioralInsights;
  final String keystrokeEmotion;
  final double keystrokeConfidence;
  final String summary;
}

class ReportService {
  ReportService({InsightService? insightService})
      : _insightService = insightService ?? const InsightService();

  final InsightService _insightService;

  MentalHealthReport generateReport(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return const MentalHealthReport(
        totalEntries: 0,
        averageSentiment: 0.0,
        dominantEmotion: 'neutral',
        emotionDistribution: <String, int>{},
        triggerFrequency: <String, int>{},
        highStressDetected: false,
        trend: 'stable',
        stressLevel: 'low',
        emotionalVariability: 'low',
        riskFlags: <String>[],
        behavioralInsights: <String>[],
        keystrokeEmotion: 'unknown',
        keystrokeConfidence: 0.0,
        summary: 'No data available for this period.',
      );
    }

    final totalEntries = journals.length;
    final averageSentiment = _insightService.getAverageSentiment(journals);
    final dominantEmotion = _insightService.getDominantEmotion(journals);
    final emotionDistribution =
        _insightService.getEmotionDistribution(journals);
    final triggerFrequency = _insightService.getTriggerFrequency(journals);
    final highStressDetected = _insightService.detectHighStress(journals);
    final insights = _insightService.generateClinicalInsights(journals);

    final trend = insights['trend'] as String? ?? 'stable';
    final stressLevel = insights['stress_level'] as String? ?? 'low';
    final emotionalVariability =
        insights['emotional_variability'] as String? ?? 'low';
    final riskFlags = (insights['risk_flags'] as List?)
            ?.whereType<String>()
            .toList() ??
        <String>[];
    final behavioralInsights = (insights['behavioral_insights'] as List?)
            ?.whereType<String>()
            .toList() ??
        <String>[];
    final summary = insights['summary'] as String? ??
        _buildSummary(
          dominantEmotion: dominantEmotion,
          averageSentiment: averageSentiment,
          highStressDetected: highStressDetected,
        );

    return MentalHealthReport(
      totalEntries: totalEntries,
      averageSentiment: averageSentiment,
      dominantEmotion: dominantEmotion,
      emotionDistribution: emotionDistribution,
      triggerFrequency: triggerFrequency,
      highStressDetected: highStressDetected,
      trend: trend,
      stressLevel: stressLevel,
      emotionalVariability: emotionalVariability,
      riskFlags: riskFlags,
      behavioralInsights: behavioralInsights,
      keystrokeEmotion: 'mixed',
      keystrokeConfidence: 0.0,
      summary: summary,
    );
  }

  MentalHealthReport generateWeeklyReport(List<JournalEntry> journals) {
    final recent = _filterByDays(_sorted(journals), 7);
    return generateReport(recent);
  }

  MentalHealthReport generateMonthlyReport(List<JournalEntry> journals) {
    final recent = _filterByDays(_sorted(journals), 30);
    return generateReport(recent);
  }

  MentalHealthReport generateSingleEntryReport(JournalEntry entry) {
    final hasContent = entry.text.trim().isNotEmpty ||
        entry.emotion.trim().isNotEmpty ||
        entry.triggers.isNotEmpty ||
        entry.stressKeywords.isNotEmpty;

    if (!hasContent) {
      return const MentalHealthReport(
        totalEntries: 0,
        averageSentiment: 0.0,
        dominantEmotion: 'neutral',
        emotionDistribution: <String, int>{'neutral': 1},
        triggerFrequency: <String, int>{},
        highStressDetected: false,
        trend: 'stable',
        stressLevel: 'low',
        emotionalVariability: 'low',
        riskFlags: <String>[],
        behavioralInsights: <String>[],
        keystrokeEmotion: 'unknown',
        keystrokeConfidence: 0.0,
        summary: 'No sufficient data available',
      );
    }

    final resolvedEmotion = entry.emotion.trim().isEmpty ? 'neutral' : entry.emotion;
    final emotionDistribution = <String, int>{resolvedEmotion: 1};
    final triggerFrequency = <String, int>{};
    for (final trigger in entry.triggers) {
      if (trigger.trim().isEmpty) {
        continue;
      }
      triggerFrequency.update(trigger, (value) => value + 1, ifAbsent: () => 1);
    }

    final insights = _insightService.generateClinicalInsights(<JournalEntry>[entry]);
    final stressLevel = insights['stress_level'] as String? ??
        (entry.stressKeywords.isNotEmpty ? 'moderate' : 'low');
    final riskFlags = (insights['risk_flags'] as List?)
            ?.whereType<String>()
            .toList() ??
        <String>[];
    final behavioralInsights = (insights['behavioral_insights'] as List?)
            ?.whereType<String>()
            .toList() ??
        <String>[];

    final summary =
        'User is experiencing $resolvedEmotion with $stressLevel stress indicators.';

    final computedHighStress = (stressLevel == 'high' || stressLevel == 'moderate');

    return MentalHealthReport(
      totalEntries: 1,
      averageSentiment: entry.sentimentScore,
      dominantEmotion: resolvedEmotion,
      emotionDistribution: emotionDistribution,
      triggerFrequency: triggerFrequency,
      // Align highStressDetected with the computed stressLevel for consistency
      highStressDetected: computedHighStress,
      trend: 'stable',
      stressLevel: stressLevel,
      emotionalVariability: 'low',
      riskFlags: riskFlags,
      behavioralInsights: behavioralInsights,
      keystrokeEmotion: entry.keystrokeEmotion,
      keystrokeConfidence: entry.keystrokeConfidence,
      summary: summary,
    );
  }

  List<JournalEntry> _filterByDays(List<JournalEntry> journals, int days) {
    if (journals.isEmpty) {
      return <JournalEntry>[];
    }
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return journals
        .where((journal) => journal.timestamp.isAfter(cutoff))
        .toList();
  }

  List<JournalEntry> _sorted(List<JournalEntry> journals) {
    final sorted = List<JournalEntry>.from(journals);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  String _buildSummary({
    required String dominantEmotion,
    required double averageSentiment,
    required bool highStressDetected,
  }) {
    final sentences = <String>[];

    if (dominantEmotion != 'neutral') {
      sentences.add('Dominant emotion is $dominantEmotion.');
    }
    if (highStressDetected) {
      sentences.add('User shows signs of elevated stress.');
    }
    if (averageSentiment < -0.3) {
      sentences.add('Overall emotional trend is negative.');
    }

    if (sentences.isEmpty) {
      return 'Overall emotional state appears stable for this period.';
    }

    return sentences.join(' ');
  }
}

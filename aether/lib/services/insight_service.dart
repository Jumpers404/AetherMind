import '../models/journal_entry.dart';

/// InsightService
///
/// Computes clinical-style insights from a list of `JournalEntry` objects.
///
/// Responsibilities:
/// - Aggregate emotion distribution and trend detection
/// - Compute stress level and emotional variability
/// - Detect crisis language and produce risk flags
///
/// Notes on behavior:
/// - When a `JournalEntry` includes a stored `emotion` value, that label is
///   preferred for aggregation. If `emotion` is empty the service falls back
///   to simple sentiment thresholds.
/// - The scoring heuristics are intentionally conservative and tuned to
///   surface risk flags (e.g., 'crisis') when strong signals (keywords or
///   extreme sentiment) are detected.
class InsightService {
  const InsightService();

  static const List<String> _crisisTerms = <String>[
    'suicidal',
    'suicide',
    'kill myself',
    'end my life',
    'self harm',
    'self-harm',
    'want to die',
    'can\'t go on',
    'cant go on',
  ];

  static const List<String> _highStressTerms = <String>[
    'hopeless',
    'helpless',
    'worthless',
    'panic',
    'panicking',
    'depressed',
    'overwhelmed',
    'breakdown',
  ];

  static const List<String> _moderateStressTerms = <String>[
    'sad',
    'anxious',
    'stressed',
    'stress',
    'pressure',
    'burden',
    'overthinking',
    'drained',
    'exhausted',
  ];

  Map<String, dynamic> generateClinicalInsights(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return <String, dynamic>{
        'trend': 'stable',
        'emotional_variability': 'low',
        'stress_level': 'low',
        'risk_flags': <String>[],
        'behavioral_insights': <String>[
          'No sufficient data available',
        ],
        'summary': 'No sufficient data available',
      };
    }

    final sorted = List<JournalEntry>.from(journals)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final trend = _detectTrend(sorted);
    final emotionalVariability = _getEmotionalVariability(sorted);
    final stressLevel = _getStressLevel(sorted);
    final riskFlags = _getRiskFlags(sorted, stressLevel);
    final behavioralInsights = _buildBehavioralInsights(
      sorted,
      trend: trend,
      emotionalVariability: emotionalVariability,
      stressLevel: stressLevel,
    );
    final summary = _buildClinicalSummary(
      sorted,
      trend: trend,
      emotionalVariability: emotionalVariability,
      stressLevel: stressLevel,
      riskFlags: riskFlags,
    );
    final fusion = _buildSignalFusion(sorted);

    return <String, dynamic>{
      'trend': trend,
      'emotional_variability': emotionalVariability,
      'stress_level': stressLevel,
      'risk_flags': riskFlags,
      'behavioral_insights': behavioralInsights,
      'summary': summary,
      'signal_fusion': fusion,
    };
  }

  Map<String, dynamic> _buildSignalFusion(List<JournalEntry> journals) {
    var aligned = 0;
    var mixed = 0;
    var confidenceBoost = 0.0;

    for (final journal in journals) {
      final journalEmotion = _resolveEmotion(journal).toLowerCase();
      final keyEmotion = journal.keystrokeEmotion.toLowerCase().trim();
      final keyConfidence = journal.keystrokeConfidence;

      if (keyEmotion.isEmpty || keyEmotion == 'unknown') {
        continue;
      }

      if (journalEmotion == keyEmotion) {
        aligned += 1;
        confidenceBoost += 0.1 * keyConfidence;
      } else {
        mixed += 1;
      }
    }

    final signalStatus = mixed > aligned
        ? 'mixed signal'
        : aligned > 0
            ? 'aligned'
            : 'insufficient keystroke signal';

    return <String, dynamic>{
      'status': signalStatus,
      'aligned_count': aligned,
      'mixed_count': mixed,
      'confidence_boost': confidenceBoost,
    };
  }

  Map<String, int> getEmotionDistribution(List<JournalEntry> journals) {
    final distribution = <String, int>{};
    for (final journal in journals) {
      final emotion = _resolveEmotion(journal);
      if (emotion.isEmpty) {
        continue;
      }
      distribution.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }
    return distribution;
  }

  double getAverageSentiment(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 0.0;
    }
    final total = journals.fold<double>(
      0.0,
      (sum, journal) => sum + journal.sentimentScore,
    );
    return total / journals.length;
  }

  String getDominantEmotion(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 'neutral';
    }

    final distribution = getEmotionDistribution(journals);
    if (distribution.isEmpty) {
      return 'neutral';
    }

    var dominant = 'neutral';
    var maxCount = 0;
    distribution.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = emotion;
      }
    });
    return dominant;
  }

  String _resolveEmotion(JournalEntry journal) {
    final stored = journal.emotion.trim();
    if (stored.isNotEmpty) {
      return stored;
    }

    final sentiment = journal.sentimentScore;
    if (sentiment <= -0.2) {
      return 'sadness';
    }
    if (sentiment >= 0.2) {
      return 'joy';
    }
    return 'neutral';
  }

  Map<String, int> getTriggerFrequency(List<JournalEntry> journals) {
    final frequency = <String, int>{};
    for (final journal in journals) {
      for (final trigger in journal.triggers) {
        if (trigger.isEmpty) {
          continue;
        }
        frequency.update(trigger, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    // Fallback: if no explicit triggers were found, infer a generic
    // "emotional" trigger when entries show anxiety, sadness or anger.
    if (frequency.isEmpty) {
      var inferred = 0;
      for (final journal in journals) {
        final emotion = _resolveEmotion(journal).toLowerCase();
        if (emotion == 'anxiety' || emotion == 'sadness' || emotion == 'anger') {
          inferred += 1;
        }
      }
      if (inferred > 0) {
        frequency['emotional'] = inferred;
      }
    }
    return frequency;
  }

  bool detectHighStress(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return false;
    }

    final stressLevel = _getStressLevel(journals);
    // Consider both 'moderate' and 'high' as elevated/high stress to
    // avoid false negatives when stress is present but not extreme.
    return stressLevel == 'high' || stressLevel == 'moderate';
  }

  String generateSummary(List<JournalEntry> journals) {
    final insights = generateClinicalInsights(journals);
    return insights['summary'] as String;
  }

  String _detectTrend(List<JournalEntry> journals) {
    if (journals.length < 2) {
      return 'stable';
    }
    final midpoint = journals.length ~/ 2;
    final firstHalf = journals.sublist(0, midpoint);
    final secondHalf = journals.sublist(midpoint);
    final previousAvg = getAverageSentiment(firstHalf);
    final recentAvg = getAverageSentiment(secondHalf);
    final delta = recentAvg - previousAvg;
    if (delta > 0.15) {
      return 'improving';
    }
    if (delta < -0.15) {
      return 'declining';
    }
    return 'stable';
  }

  String _getEmotionalVariability(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 'low';
    }

    if (journals.length == 1) {
      final only = journals.first;
      if (_hasCrisisLanguage(only.text)) {
        return 'high';
      }

      final emotion = _resolveEmotion(only).toLowerCase();
      final sentimentMag = only.sentimentScore.abs();
      if (sentimentMag >= 0.75 || emotion == 'anxiety' || emotion == 'anger') {
        return 'moderate';
      }
      return 'low';
    }

    final uniqueEmotions = journals
        .map(_resolveEmotion)
        .where((emotion) => emotion.isNotEmpty)
        .toSet()
        .length;

    if (uniqueEmotions >= 5) {
      return 'high';
    }
    if (uniqueEmotions >= 3) {
      return 'moderate';
    }
    return 'low';
  }

  String _getStressLevel(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 'low';
    }

    var hasCrisisSignal = false;
    var totalScore = 0.0;

    for (final journal in journals) {
      final text = journal.text.toLowerCase();
      if (_containsAny(text, _crisisTerms)) {
        hasCrisisSignal = true;
      }

      var score = 0.0;
      if (journal.stressKeywords.isNotEmpty) {
        score += 2.0;
      }

      if (_containsAny(text, _highStressTerms)) {
        score += 2.0;
      } else if (_containsAny(text, _moderateStressTerms)) {
        score += 1.0;
      }

      final emotion = _resolveEmotion(journal).toLowerCase();
      if (emotion == 'anxiety' || emotion == 'fear' || emotion == 'anger') {
        score += 1.5;
      } else if (emotion == 'sadness' || emotion == 'guilt' || emotion == 'shame') {
        score += 1.0;
      }

      final sentiment = journal.sentimentScore;
      if (sentiment <= -0.75) {
        score += 2.5;
      } else if (sentiment <= -0.45) {
        score += 1.5;
      } else if (sentiment <= -0.2) {
        score += 0.75;
      } else if (sentiment >= 0.45) {
        score -= 0.5;
      }

      if (score < 0) {
        score = 0;
      }
      totalScore += score;
    }

    if (hasCrisisSignal) {
      return 'high';
    }

    final avgScore = totalScore / journals.length;
    if (avgScore >= 2.0) {
      return 'high';
    }
    if (avgScore >= 0.9) {
      return 'moderate';
    }
    return 'low';
  }

  List<String> _getRiskFlags(List<JournalEntry> journals, String stressLevel) {
    final flags = <String>[];
    final avgSentiment = getAverageSentiment(journals);
    var crisisMentions = 0;
    var distressMentions = 0;

    for (final journal in journals) {
      final lower = journal.text.toLowerCase();
      if (_containsAny(lower, _crisisTerms)) {
        crisisMentions += 1;
      }
      if (lower.contains('sad') ||
          lower.contains('hopeless') ||
          lower.contains('helpless') ||
          lower.contains('depressed') ||
          lower.contains('worthless')) {
        distressMentions += 1;
      }
    }

    if (crisisMentions > 0) {
      flags.add('crisis');
      flags.add('high_risk');
    }

    if (avgSentiment < -0.5 && stressLevel == 'high') {
      flags.add('high_risk');
    }

    if (distressMentions >= 2 ||
        (journals.length == 1 && distressMentions >= 1 && avgSentiment <= -0.25)) {
      flags.add('emotional_distress');
    }

    return flags.toSet().toList();
  }

  List<String> _buildBehavioralInsights(
    List<JournalEntry> journals, {
    required String trend,
    required String emotionalVariability,
    required String stressLevel,
  }) {
    final insights = <String>[];
    final triggerFrequency = getTriggerFrequency(journals);
    final topTrigger = _getMostCommonKey(triggerFrequency);

    if (topTrigger != 'unknown') {
      insights.add('User frequently reports $topTrigger stress.');
    }

    if (trend == 'improving') {
      insights.add('Recent entries show emotional improvement.');
    } else if (trend == 'declining') {
      insights.add('Recent entries show declining emotional trend.');
    } else {
      insights.add('Emotional trend appears stable recently.');
    }

    if (emotionalVariability == 'high') {
      insights.add('High emotional fluctuation detected.');
    } else if (emotionalVariability == 'moderate') {
      insights.add('Moderate emotional variability observed.');
    } else {
      insights.add('Emotional state appears relatively consistent.');
    }

    if (stressLevel == 'high') {
      insights.add('Frequent stress indicators are present across entries.');
      if (journals.any((journal) => _hasCrisisLanguage(journal.text))) {
        insights.add('Critical distress language detected; immediate support is recommended.');
      }
    }

    return insights;
  }

  String _buildClinicalSummary(
    List<JournalEntry> journals, {
    required String trend,
    required String emotionalVariability,
    required String stressLevel,
    required List<String> riskFlags,
  }) {
    if (journals.isEmpty) {
      return 'No sufficient data available';
    }

    final triggerFrequency = getTriggerFrequency(journals);
    final topTrigger = _getMostCommonKey(triggerFrequency);
    final triggerText = topTrigger == 'unknown'
        ? 'General stressors are present'
        : '${_capitalize(topTrigger)} triggers appear frequently';

    final trendText = trend == 'declining'
        ? 'a declining emotional trend'
        : trend == 'improving'
            ? 'an improving emotional trend'
            : 'a stable emotional trend';

    final variabilityText = emotionalVariability == 'high'
        ? 'Emotional variability is high, indicating instability.'
        : emotionalVariability == 'moderate'
            ? 'Emotional variability is moderate.'
            : 'Emotional variability is low.';

    final riskText = riskFlags.isEmpty
        ? 'No acute risk flags detected.'
        : 'Risk flags detected: ${riskFlags.join(', ')}.';

    return 'User shows signs of $stressLevel stress with $trendText. '
        '$triggerText. $variabilityText $riskText';
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  String _getMostCommonKey(Map<String, int> frequency) {
    if (frequency.isEmpty) {
      return 'unknown';
    }

    var bestKey = 'unknown';
    var bestCount = 0;
    frequency.forEach((key, count) {
      if (count > bestCount) {
        bestCount = count;
        bestKey = key;
      }
    });
    return bestKey;
  }

  bool _hasCrisisLanguage(String text) {
    return _containsAny(text.toLowerCase(), _crisisTerms);
  }

  bool _containsAny(String text, List<String> terms) {
    for (final term in terms) {
      if (text.contains(term)) {
        return true;
      }
    }
    return false;
  }
}

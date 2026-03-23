import '../models/journal_entry.dart';
import 'journal_parser.dart';

class InsightService {
  const InsightService();

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
    if (stored.isNotEmpty && stored != 'neutral') {
      return stored;
    }
    if (journal.text.trim().isEmpty) {
      return stored.isEmpty ? 'neutral' : stored;
    }
    return JournalParser.getEmotion(journal.text);
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
    final withStress = journals.where((journal) {
      if (journal.stressKeywords.isNotEmpty) {
        return true;
      }
      final text = journal.text.toLowerCase();
      return text.contains('stress') ||
          text.contains('overwhelmed') ||
          text.contains('deadline') ||
          text.contains('pressure') ||
          text.contains('burden') ||
          text.contains('overthinking');
    }).length;

    final ratio = withStress / journals.length;
    if (ratio > 0.5) {
      return 'high';
    }
    if (ratio >= 0.2) {
      return 'moderate';
    }
    return 'low';
  }

  List<String> _getRiskFlags(List<JournalEntry> journals, String stressLevel) {
    final flags = <String>[];
    final avgSentiment = getAverageSentiment(journals);
    if (avgSentiment < -0.5 && stressLevel == 'high') {
      flags.add('high_risk');
    }

    var distressMentions = 0;
    for (final journal in journals) {
      final lower = journal.text.toLowerCase();
      if (lower.contains('sad') ||
          lower.contains('hopeless') ||
          lower.contains('helpless') ||
          lower.contains('depressed')) {
        distressMentions += 1;
      }
    }
    if (distressMentions >= 2) {
      flags.add('emotional_distress');
    }

    return flags;
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

  String _sentimentLabel(double score) {
    if (score > 0.2) {
      return 'positive';
    }
    if (score < -0.2) {
      return 'negative';
    }
    return 'neutral';
  }
}

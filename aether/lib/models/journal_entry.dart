import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.sentimentScore,
    required this.emotion,
    required this.intensity,
    required this.triggers,
    required this.keywords,
    required this.stressKeywords,
    required this.cognitivePatterns,
    required this.sentimentLabel,
    this.keystrokeEmotion = 'unknown',
    this.keystrokeConfidence = 0.0,
    required this.processed,
  });

  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final double sentimentScore;
  final String emotion;
  final int intensity;
  final List<String> triggers;
  final List<String> keywords;
  final List<String> stressKeywords;
  final List<String> cognitivePatterns;
  final String sentimentLabel;
  final String keystrokeEmotion;
  final double keystrokeConfidence;
  final bool processed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
  'timestamp': Timestamp.fromDate(timestamp),
      'sentiment_score': sentimentScore,
      'emotion': emotion,
      'intensity': intensity,
      'triggers': List<String>.from(triggers),
      'keywords': List<String>.from(keywords),
      'stress_keywords': List<String>.from(stressKeywords),
      'cognitive_patterns': List<String>.from(cognitivePatterns),
      'sentiment_label': sentimentLabel,
      'keystroke_emotion': keystrokeEmotion,
      'keystroke_confidence': keystrokeConfidence,
      'processed': processed,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: _parseTimestamp(map['timestamp']),
      sentimentScore: _parseDouble(map['sentiment_score']),
  emotion: map['emotion'] as String? ?? 'neutral',
      intensity: _parseInt(map['intensity']),
      triggers: _parseStringList(map['triggers']),
      keywords: _parseStringList(map['keywords']),
      stressKeywords: _parseStringList(map['stress_keywords']),
      cognitivePatterns: _parseStringList(map['cognitive_patterns']),
      sentimentLabel: map['sentiment_label'] as String? ?? '',
      keystrokeEmotion: map['keystroke_emotion'] as String? ?? 'unknown',
      keystrokeConfidence: _parseDouble(map['keystroke_confidence']),
      processed: map['processed'] as bool? ?? false,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }
}

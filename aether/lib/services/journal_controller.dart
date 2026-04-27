/// JournalController
///
/// Orchestrates journal creation: parsing, calling remote ML services, and
/// persisting the final `JournalEntry` via `JournalService`.
///
/// Important behavior:
/// - Uses the remote text emotion ML (`TextEmotionService`) as the primary
///   source of emotion labels. If the ML call fails or returns an invalid
///   response the controller falls back to the local rule-based
///   `JournalParser.getEmotion(...)` implementation.
/// - Keystroke features (when available) are sent to the keystroke ML
///   service but failures there do not block saving the journal; instead the
///   controller stores a safe `keystrokeEmotion = 'unknown'` and
///   `keystrokeConfidence = 0.0`.
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';
import 'journal_parser.dart';
import 'journal_service.dart';
import 'keystroke_service.dart';
import 'text_emotion_service.dart';

class JournalController {
  JournalController({
    JournalService? service,
    Uuid? uuid,
    KeystrokeService? keystrokeService,
    TextEmotionService? textEmotionService,
  })
      : _service = service ?? JournalService(),
        _uuid = uuid ?? const Uuid(),
        _keystrokeService = keystrokeService ?? KeystrokeService(),
        _textEmotionService = textEmotionService ?? TextEmotionService();

  final JournalService _service;
  final Uuid _uuid;
  final KeystrokeService _keystrokeService;
  final TextEmotionService _textEmotionService;

  /// Creates a journal from [text], optionally sending [keystrokeData]
  /// to the keystroke ML service. Returns the saved [JournalEntry] or null
  /// if creation failed.
  Future<JournalEntry?> createJournal(
    String text, {
    Map<String, dynamic>? keystrokeData,
  }) async {
    try {
      print('CONTROLLER: Starting createJournal');
      final cleanText = text.trim();
      if (cleanText.isEmpty) {
        return null;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('CONTROLLER ERROR: No authenticated user');
        return null;
      }
      print('Current UID: ${user.uid}');

      final id = _uuid.v4();
      final timestamp = DateTime.now();

      // Local sentiment computation is kept for other scoring and intensity
      // calculations even when the ML API is used for the primary emotion.
      final sentiment = JournalParser.getSentiment(cleanText);
      print('CONTROLLER: Parsed sentiment = $sentiment');

      var emotion = 'neutral';
      var emotionSource = 'ml_api';

      // Primary: call text ML service. Any error or invalid response falls
      // back to the local parser so saving still proceeds.
      try {
        final textPrediction = await _textEmotionService.predictEmotion(cleanText);
        final apiEmotion = (textPrediction['emotion'] ?? '').toString().trim();
        if (apiEmotion.isNotEmpty) {
          emotion = apiEmotion;
        } else {
          // API returned a payload but without an emotion label.
          emotion = JournalParser.getEmotion(cleanText);
          emotionSource = 'fallback_parser';
        }
      } catch (e) {
        print('CONTROLLER: text emotion prediction failed, using fallback parser: $e');
        emotion = JournalParser.getEmotion(cleanText);
        emotionSource = 'fallback_parser';
      }

      print('CONTROLLER: Emotion source = $emotionSource, emotion = $emotion');
      final triggers = JournalParser.getTriggers(cleanText);
      final keywords = JournalParser.extractKeywords(cleanText);
      final stressKeywords = JournalParser.getStressKeywords(cleanText);
      final cognitivePatterns = JournalParser.getCognitivePatterns(cleanText);
      final intensity = JournalParser.getIntensityFromText(cleanText, sentiment);
      final sentimentLabel = JournalParser.getSentimentLabel(sentiment);

      // Keystroke ML is optional: we attempt a prediction but failures do not
      // prevent journal persistence.
      var keystrokeEmotion = 'unknown';
      var keystrokeConfidence = 0.0;
      if (keystrokeData != null && keystrokeData.isNotEmpty) {
        try {
          final prediction = await _keystrokeService.predictKeystrokeEmotion(
            keystrokeData,
          );
          keystrokeEmotion = (prediction['emotion'] ?? 'unknown').toString();
          keystrokeConfidence = _toDouble(prediction['confidence']);
        } catch (e) {
          print('CONTROLLER: keystroke prediction failed: $e');
        }
      }

      final entry = JournalEntry(
        id: id,
        userId: user.uid,
        text: cleanText,
        timestamp: timestamp,
        sentimentScore: sentiment,
        emotion: emotion,
        intensity: intensity,
        triggers: triggers,
        keywords: keywords,
        stressKeywords: stressKeywords,
        cognitivePatterns: cognitivePatterns,
        sentimentLabel: sentimentLabel,
        keystrokeEmotion: keystrokeEmotion,
        keystrokeConfidence: keystrokeConfidence,
        processed: true,
      );

      print('Saving journal for UID: ${user.uid}');
      await _service.saveJournal(entry);
      print('CONTROLLER: Save completed');
      print('Journal created: ${entry.id}');
      return entry;
    } catch (error) {
      print('CONTROLLER ERROR: $error');
      return null;
    }
  }

  double _toDouble(dynamic value) {
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

  Future<List<JournalEntry>> fetchUserJournals() async {
    return _service.getUserJournals();
  }

  Future<List<JournalEntry>> fetchRecentJournals(int days) async {
    return _service.getRecentJournals(days);
  }

  Future<bool> deleteJournal(String id) async {
    try {
      await _service.deleteJournal(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}

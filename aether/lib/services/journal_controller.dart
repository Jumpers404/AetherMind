import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';
import 'journal_parser.dart';
import 'journal_service.dart';
import 'keystroke_service.dart';

class JournalController {
  JournalController({
    JournalService? service,
    Uuid? uuid,
    KeystrokeService? keystrokeService,
  })
      : _service = service ?? JournalService(),
        _uuid = uuid ?? const Uuid(),
        _keystrokeService = keystrokeService ?? KeystrokeService();

  final JournalService _service;
  final Uuid _uuid;
  final KeystrokeService _keystrokeService;

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

      final sentiment = JournalParser.getSentiment(cleanText);
  print('CONTROLLER: Parsed sentiment = $sentiment');
      final emotion = JournalParser.getEmotion(cleanText);
      final triggers = JournalParser.getTriggers(cleanText);
      final keywords = JournalParser.extractKeywords(cleanText);
      final stressKeywords = JournalParser.getStressKeywords(cleanText);
      final cognitivePatterns = JournalParser.getCognitivePatterns(cleanText);
  final intensity = JournalParser.getIntensityFromText(cleanText, sentiment);
      final sentimentLabel = JournalParser.getSentimentLabel(sentiment);

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

import 'package:flutter/material.dart';

class EmotionEntry {
  final DateTime date;
  final String mood; // good, neutral, low, stressed

  EmotionEntry({
    required this.date,
    required this.mood,
  });

  static Color getColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'good':
        return const Color(0xFF66BB6A);
      case 'neutral':
        return const Color(0xFFFFCA28);
      case 'low':
        return const Color(0xFF42A5F5);
      case 'stressed':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey.shade300;
    }
  }

  static List<EmotionEntry> generateMockData() {
    final now = DateTime.now();
    final List<EmotionEntry> data = [];
    final moods = ['good', 'neutral', 'low', 'stressed'];
    
    // Generate data for the last 60 days
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      // Artificial pattern: More stressed mid-week (Tuesday/Wednesday/Thursday)
      // Improved mood on weekends (Saturday/Sunday)
      String mood;
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        mood = 'good';
      } else if (date.weekday == DateTime.tuesday || date.weekday == DateTime.wednesday) {
        mood = 'stressed';
      } else {
        mood = moods[i % 4];
      }
      
      data.add(EmotionEntry(date: date, mood: mood));
    }
    return data;
  }
}

class EmotionAnalyticsLogic {
  static String getMostFrequentMood(List<EmotionEntry> entries) {
    if (entries.isEmpty) return 'No data';
    final Map<String, int> counts = {};
    for (var entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<String> generateInsights(List<EmotionEntry> entries) {
    if (entries.isEmpty) return ['Start logging to see patterns.'];
    
    List<String> insights = [];
    
    // Check weekend pattern
    int weekendGood = 0;
    int weekendTotal = 0;
    int weekdayStressed = 0;
    int weekdayTotal = 0;
    
    for (var entry in entries) {
      if (entry.date.weekday == DateTime.saturday || entry.date.weekday == DateTime.sunday) {
        weekendTotal++;
        if (entry.mood == 'good') weekendGood++;
      } else {
        weekdayTotal++;
        if (entry.mood == 'stressed') weekdayStressed++;
      }
    }
    
    if (weekendGood / weekendTotal > 0.6) {
      insights.add("Your mood improves significantly on weekends.");
    }
    
    if (weekdayStressed / weekdayTotal > 0.4) {
      insights.add("You tend to feel more stressed during mid-week.");
    }
    
    if (insights.length < 2) {
      insights.add("There's a consistent pattern in your emotional state.");
    }
    
    insights.add("You've been very consistent with your reflections lately!");
    
    return insights;
  }
}

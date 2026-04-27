/// JournalParser
///
/// Lightweight, rule-based text parsing utilities used as a deterministic
/// fallback for emotion/sentiment extraction when the ML service is
/// unavailable. This parser implements simple keyword/phrase matching,
/// negation handling, modifier multipliers, and heuristic intensity scoring.
///
/// Important notes:
/// - This is intentionally simple and will not match the accuracy of the
///   transformer-based ML model. It exists primarily to ensure the app can
///   continue providing basic insights when offline or when the backend is
///   unreachable.
/// - Keep the exported function names stable as they are used across the
///   app (JournalController, InsightService, tests).
class JournalParser {
  static const List<String> _positiveWords = [
    'happy',
    'joy',
    'grateful',
    'calm',
    'hopeful',
    'good',
    'great',
    'positive',
    'relaxed',
    'peaceful',
    'excited',
    'love',
    'proud',
    'confident',
    'content',
    'satisfied',
    'motivated',
    'energetic',
  ];

  static const List<String> _negativeWords = [
    'sad',
    'angry',
    'upset',
    'anxious',
    'stress',
    'stressed',
    'depressed',
    'hopeless',
    'tired',
    'exhausted',
    'overwhelmed',
    'burnout',
    'burned',
    'lonely',
    'fear',
    'bad',
    'terrible',
    'drained',
    'burning',
    'lost',
    'confused',
    'pressured',
  ];

  static const Map<String, List<String>> _triggerKeywords = {
    'academic': ['exam', 'school', 'class', 'grades', 'homework', 'college'],
    'work': ['job', 'boss', 'deadline', 'meeting', 'office', 'work'],
    'social': ['friends', 'family', 'relationship', 'party', 'social'],
    'health': ['sick', 'ill', 'doctor', 'pain', 'health', 'sleep', 'insomnia', 'fatigue'],
  };

  static const Map<String, List<String>> _stressKeywords = {
    'overwhelmed': ['overwhelmed', 'too much', 'overloaded'],
    'burnout': ['burnout', 'burned out', 'burnt out'],
    'exhausted': ['exhausted', 'drained', 'fatigued'],
    'hopeless': ['hopeless', 'helpless', 'no way out'],
    'pressure': ['deadline', 'pressure', 'burden', 'overthinking'],
  };

  static const List<String> _overgeneralizationWords = ['always', 'never'];
  static const List<String> _catastrophizingWords = ['everything'];
  static const List<String> _negationWords = [
    'not',
    'no',
    'never',
    'hardly',
    'barely',
  ];

  static const Map<String, double> _intensityModifiers = {
    'very': 1.5,
    'extremely': 2.0,
    'slightly': 0.5,
    'a bit': 0.7,
  };

  static const List<String> _contrastWords = ['but', 'however'];

  static double getSentiment(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return 0.0;
    }

    const strongNegative = {
      'overwhelmed': -2,
      'hopeless': -2,
      'exhausted': -2,
      'stressed': -2,
      'anxious': -2,
    };
    const mildNegative = {
      'sad': -1,
      'bad': -1,
      'tired': -1,
      'drained': -1,
    };
    const strongPositive = {
      'amazing': 2,
      'great': 2,
      'happy': 2,
      'motivated': 2,
      'energetic': 2,
      'better': 2,
      'relieved': 2,
    };
    const mildPositive = {
      'okay': 1,
      'fine': 1,
      'content': 1,
      'satisfied': 1,
    };
    const phraseNegative = [
      'burnt out',
      'fed up',
      'worn out',
      'under pressure',
      "i can't handle",
      'too much to deal',
      'falling apart',
      'killing me',
      'too much',
      'cant handle',
      'losing it',
    ];
    const phrasePositive = [
      'feeling better',
      'doing okay now',
      'okay now',
      'fine now',
    ];

  final tokens = _tokenize(normalized);

    final contrastIndex = _findContrastIndex(tokens);
    final firstSegment = contrastIndex == -1 ? tokens : tokens.sublist(0, contrastIndex);
    final secondSegment = contrastIndex == -1 ? <String>[] : tokens.sublist(contrastIndex + 1);

    final firstScore = _scoreSegment(
      firstSegment,
      strongNegative: strongNegative,
      mildNegative: mildNegative,
      strongPositive: strongPositive,
      mildPositive: mildPositive,
      phraseNegative: phraseNegative,
      phrasePositive: phrasePositive,
      tokenCounts: _countTokens(firstSegment),
    );

    final secondScore = _scoreSegment(
      secondSegment,
      strongNegative: strongNegative,
      mildNegative: mildNegative,
      strongPositive: strongPositive,
      mildPositive: mildPositive,
      phraseNegative: phraseNegative,
      phrasePositive: phrasePositive,
      tokenCounts: _countTokens(secondSegment),
    );

    var score = contrastIndex == -1
        ? firstScore
        : ((firstScore * 0.4) + (secondScore * 1.0));

    final stressWords = getStressKeywords(text);
    if (score == 0 && stressWords.isNotEmpty) {
      score = -0.3;
    }
    return score.clamp(-1.0, 1.0);
  }

  static double _scoreSegment(
    List<String> tokens, {
    required Map<String, int> strongNegative,
    required Map<String, int> mildNegative,
    required Map<String, int> strongPositive,
    required Map<String, int> mildPositive,
    required List<String> phraseNegative,
    required List<String> phrasePositive,
    required Map<String, int> tokenCounts,
  }) {
    if (tokens.isEmpty) {
      return 0.0;
    }

    final matches = <String, double>{};
    final anxietyWords = <String>{'stress', 'stressed', 'anxious', 'overwhelmed', 'pressure', 'deadline', 'burden', 'overthinking'};

    for (final phrase in phraseNegative) {
      final phraseTokens = _tokenize(phrase);
      final starts = _findPhraseStarts(tokens, phraseTokens);
      if (starts.isEmpty) {
        continue;
      }
      final repetitionMultiplier = 1 + ((starts.length - 1) * 0.3);
      for (final start in starts) {
        var adjusted = -2.0; // 1) base weight
        if (_isNegatedWindow(start, tokens)) {
          adjusted *= -1; // 2) negation invert
        }
        adjusted *= _getModifierMultiplier(start, tokens); // 3) modifier
        adjusted *= repetitionMultiplier; // 4) repetition
        matches['$phrase@$start'] = adjusted;
      }
    }

    for (final phrase in phrasePositive) {
      final phraseTokens = _tokenize(phrase);
      final starts = _findPhraseStarts(tokens, phraseTokens);
      if (starts.isEmpty) {
        continue;
      }
      final repetitionMultiplier = 1 + ((starts.length - 1) * 0.3);
      for (final start in starts) {
        var adjusted = 2.5;
        if (_isNegatedWindow(start, tokens)) {
          adjusted *= -1;
        }
        adjusted *= _getModifierMultiplier(start, tokens);
        adjusted *= repetitionMultiplier;
        matches['$phrase@$start'] = adjusted;
      }
    }

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      var weight = strongNegative[token] ??
          mildNegative[token] ??
          strongPositive[token] ??
          mildPositive[token];

      // Ensure stress/anxiety words always influence sentiment.
      weight ??= anxietyWords.contains(token) ? -2 : null;
      if (weight == null) {
        continue;
      }

      var adjusted = weight.toDouble(); // 1) base
      if (_isNegatedWindow(i, tokens)) {
        adjusted *= -1; // 2) negation
      }
      adjusted *= _getModifierMultiplier(i, tokens); // 3) modifier after weight assignment
      final count = tokenCounts[token] ?? 1;
      adjusted *= (1 + (count - 1) * 0.3); // 4) repetition
      matches['$token@$i'] = adjusted;
    }

    if (matches.isEmpty) {
      return 0.0;
    }
    final totalScore = matches.values.fold<double>(0, (sum, value) => sum + value);
    return totalScore / matches.length;
  }

  static String getEmotion(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return 'neutral';
    }

    const sadnessPhrases = <String>[
      'worst day',
      'not happy',
      'not okay',
      'feel depressed',
    ];

    if (sadnessPhrases.any(normalized.contains)) {
      return 'sadness';
    }

    const emotionGroups = <String, List<String>>{
      'anxiety': [
        'stress',
        'stressed',
        'overwhelmed',
        'nervous',
        'anxious',
        'panic',
        'panicked',
        'worry',
        'worried',
      ],
      'sadness': [
        'sad',
        'down',
        'hopeless',
        'depressed',
        'unhappy',
        'miserable',
        'awful',
        'terrible',
        'worst',
        'low',
      ],
      'joy': ['happy', 'great', 'good', 'relaxed', 'content', 'satisfied', 'grateful'],
      'anger': ['angry', 'frustrated', 'irritated', 'mad', 'furious'],
      'fear': ['scared', 'afraid', 'fear', 'dread'],
      'guilt': ['guilty', 'regret'],
      'shame': ['ashamed', 'embarrassed'],
    };

    final tokens = _tokenize(normalized);
    var bestEmotion = 'neutral';
    var bestScore = 0;
    var bestLastIndex = -1;

    emotionGroups.forEach((emotion, keywords) {
      var count = 0;
      var lastIndex = -1;
      for (var i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        if (!keywords.contains(token)) {
          continue;
        }
        if (_isNegatedWindow(i, tokens)) {
          continue;
        }
        count += 1;
        lastIndex = i;
      }
      if (count > bestScore || (count == bestScore && lastIndex > bestLastIndex)) {
        bestScore = count;
        bestEmotion = emotion;
        bestLastIndex = lastIndex;
      }
    });

    if (bestScore > 0) {
      return bestEmotion;
    }

    final sentiment = getSentiment(normalized);
    if (sentiment <= -0.25) {
      final stressKeywords = getStressKeywords(normalized);
      if (stressKeywords.isNotEmpty) {
        return 'anxiety';
      }
      return 'sadness';
    }
    if (sentiment >= 0.25) {
      return 'joy';
    }

    return 'neutral';
  }

  static List<String> getTriggers(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return <String>['unknown'];
    }
    final tokens = _tokenize(normalized);
    final triggers = <String>[];
    _triggerKeywords.forEach((label, keywords) {
      final match = keywords.any((keyword) => _matchesKeyword(tokens, keyword));
      if (match) {
        triggers.add(label);
      }
    });

    return triggers.isEmpty ? <String>['unknown'] : triggers;
  }

  static List<String> getStressKeywords(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return <String>[];
    }

    final tokens = _tokenize(normalized);
    final results = <String>[];
    _stressKeywords.forEach((label, keywords) {
      var matched = false;
      for (final keyword in keywords) {
        final keywordTokens = _tokenize(keyword);
        final starts = _findPhraseStarts(tokens, keywordTokens);
        if (starts.isEmpty) {
          continue;
        }
        final negated = starts.any((start) => _isNegatedWindow(start, tokens));
        if (!negated) {
          matched = true;
          break;
        }
      }
      if (matched) {
        results.add(label);
      }
    });
    return results;
  }

  static List<String> extractKeywords(String text) {
    const stopwords = <String>{
      'the',
      'and',
      'is',
      'was',
      'very',
      'i',
      'am',
      'to',
      'of',
      'in',
      'it',
    };

    const maxKeywords = 8;
    final tokens = _tokenize(text)
        .where((word) => word.length > 4)
        .where((word) => !stopwords.contains(word))
        .toList();
    if (tokens.isEmpty) {
      return <String>[];
    }
    final counts = <String, int>{};
    for (final token in tokens) {
      counts[token] = (counts[token] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) {
          return byCount;
        }
        return a.key.compareTo(b.key);
      });
    return sorted.take(maxKeywords).map((entry) => entry.key).toList();
  }

  static List<String> getCognitivePatterns(String text) {
    final tokens = _tokenize(text);
    final patterns = <String>[];

    if (_overgeneralizationWords.any(tokens.contains)) {
      patterns.add('overgeneralization');
    }
    if (_catastrophizingWords.any(tokens.contains)) {
      patterns.add('catastrophizing');
    }

    return patterns;
  }

  static int getIntensity(
    double sentiment, {
    int emotionalKeywordCount = 0,
    int repetitionScore = 0,
    double modifierImpact = 1.0,
  }) {
    if (sentiment == 0) {
      return 3;
    }
    final base = sentiment.abs() * 8;
    final keywordBoost = emotionalKeywordCount * 0.6;
    final repetitionBoost = repetitionScore * 0.3;
    final modifierBoost = (modifierImpact - 1).abs() * 2.5;
    final scaled = (base + keywordBoost + repetitionBoost + modifierBoost).round();
    return scaled.clamp(1, 10);
  }

  static int getIntensityFromText(String text, double sentiment) {
    final tokens = _tokenize(text);
    if (tokens.isEmpty) {
      return getIntensity(sentiment);
    }

    final tokenCounts = _countTokens(tokens);
    final emotionVocabulary = <String>{
      ..._positiveWords,
      ..._negativeWords,
    };

    var emotionalKeywordCount = 0;
    var repetitionScore = 0;
    var modifierImpact = 1.0;

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (!emotionVocabulary.contains(token)) {
        continue;
      }
      emotionalKeywordCount += 1;
      final count = tokenCounts[token] ?? 1;
      if (count > 1) {
        repetitionScore += (count - 1);
      }
      final modifier = _getModifierMultiplier(i, tokens);
      if (modifier > modifierImpact) {
        modifierImpact = modifier;
      }
    }

    return getIntensity(
      sentiment,
      emotionalKeywordCount: emotionalKeywordCount,
      repetitionScore: repetitionScore,
      modifierImpact: modifierImpact,
    );
  }

  static String getSentimentLabel(double score) {
    if (score > 0.2) {
      return 'positive';
    }
    if (score < -0.2) {
      return 'negative';
    }
    return 'neutral';
  }

  static List<String> _tokenize(String text) {
    final normalized = _normalize(text);
    return normalized
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static Map<String, int> _countTokens(List<String> tokens) {
    final counts = <String, int>{};
    for (final token in tokens) {
      counts[token] = (counts[token] ?? 0) + 1;
    }
    return counts;
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .trim();
  }

  static bool _isNegatedWindow(int index, List<String> tokens) {
    if (index <= 0) {
      return false;
    }
    final start = index - 3 < 0 ? 0 : index - 3;
    for (var i = start; i < index; i++) {
      if (_negationWords.contains(tokens[i])) {
        return true;
      }
    }
    return false;
  }

  static int _findContrastIndex(List<String> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      if (_contrastWords.contains(tokens[i])) {
        return i;
      }
    }
    return -1;
  }

  static double _getContrastMultiplier(int index, int contrastIndex) {
    if (contrastIndex == -1) {
      return 1.0;
    }
    return index > contrastIndex ? 1.2 : 0.85;
  }

  static double _getModifierMultiplier(int index, List<String> tokens) {
    if (index <= 0) {
      return 1.0;
    }
    var multiplier = 1.0;
    _intensityModifiers.forEach((phrase, value) {
      final phraseTokens = _tokenize(phrase);
      final start = index - phraseTokens.length;
      if (start < 0) {
        return;
      }
      var match = true;
      for (var i = 0; i < phraseTokens.length; i++) {
        if (tokens[start + i] != phraseTokens[i]) {
          match = false;
          break;
        }
      }
      if (match) {
        multiplier = multiplier < value ? value : multiplier;
      }
    });
    return multiplier;
  }

  static double _getRepetitionMultiplier(
    String token,
    Map<String, int> tokenCounts,
  ) {
    final baseToken = token.split(' ').first;
    final count = tokenCounts[baseToken] ?? 1;
    if (count <= 1) {
      return 1.0;
    }
    return 1.0 + ((count - 1) * 0.3);
  }

  static bool _matchesKeyword(List<String> tokens, String keyword) {
    final keywordTokens = _tokenize(keyword);
    if (keywordTokens.length == 1) {
      return tokens.contains(keywordTokens.first);
    }
    return _findPhraseStarts(tokens, keywordTokens).isNotEmpty;
  }

  static List<int> _findPhraseStarts(
    List<String> tokens,
    List<String> phraseTokens,
  ) {
    if (phraseTokens.isEmpty || tokens.length < phraseTokens.length) {
      return <int>[];
    }
    final starts = <int>[];
    for (var i = 0; i <= tokens.length - phraseTokens.length; i++) {
      var match = true;
      for (var j = 0; j < phraseTokens.length; j++) {
        if (tokens[i + j] != phraseTokens[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        starts.add(i);
      }
    }
    return starts;
  }
}

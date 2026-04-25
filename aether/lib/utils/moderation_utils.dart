enum ModerationResult { clean, mildToxicity, harmful, selfHarm }

class ModerationService {
  // Simple heuristic checks simulating an AI API.
  static Future<ModerationResult> analyzeText(String text) async {
    final lowerText = text.toLowerCase();

    // 1. Self-Harm Check
    final selfHarmKeywords = [
      'kill myself',
      'suicide',
      'end it all',
      'want to die',
      'hurt myself',
      'better off dead',
      'can\'t go on',
    ];
    for (final kw in selfHarmKeywords) {
      if (lowerText.contains(kw)) {
        return ModerationResult.selfHarm;
      }
    }

    // 2. Harmful / Hate Speech Check
    final harmfulKeywords = [
      'hate you',
      'kys',
      'kill yourself',
      'die',
      'stupid piece of',
      'abuser',
    ];
    for (final kw in harmfulKeywords) {
      if (lowerText.contains(kw)) {
        return ModerationResult.harmful;
      }
    }

    // 3. Mild Toxicity Check
    final mildToxKeywords = ['shut up', 'idiot', 'dumb', 'loser', 'suck'];
    for (final kw in mildToxKeywords) {
      if (lowerText.contains(kw)) {
        return ModerationResult.mildToxicity;
      }
    }

    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return ModerationResult.clean;
  }
}

/// TextEmotionService
///
/// Small HTTP client wrapper that calls the ML backend's text prediction
/// endpoint to obtain an emotion label and confidence for a piece of text.
///
/// Behavior & guarantees:
/// - Uses `MlApiConfig.textPredictUri` so endpoints can be overridden via
///   dart-define during development or CI.
/// - Applies a 4 second timeout to avoid hanging the UI when the ML service
///   is slow or unreachable. Timeouts throw and are expected to be handled by
///   callers (which may fall back to a local parser).
/// - Returns a Map with keys `emotion` (String) and `confidence` (double) on
///   success. On failure this client throws an exception to signal the caller
///   to run fallback logic.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ml_api_config.dart';

class TextEmotionService {
  TextEmotionService({http.Client? client}) : _client = client ?? http.Client() {
    // Ensure we log the active config once during early usage so devs can
    // confirm which endpoint the app will call.
    MlApiConfig.logActiveConfigOnce();
  }

  // resolved at class initialization so tests can inject alternate MlApiConfig
  static final Uri _predictUri = MlApiConfig.textPredictUri;

  final http.Client _client;

  /// Predicts emotion for [text] by calling the remote ML endpoint.
  ///
  /// Throws on timeout or when the response is malformed. Successful responses
  /// are normalized to a Map: {'emotion': <String>, 'confidence': <double>}.
  Future<Map<String, dynamic>> predictEmotion(String text) async {
    try {
      final response = await _client
          .post(
            _predictUri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{'text': text}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final emotion = (decoded['emotion'] ?? '').toString().trim();
          if (emotion.isNotEmpty) {
            return <String, dynamic>{
              'emotion': emotion,
              'confidence': _toDouble(decoded['confidence']),
            };
          }
        }
      }

      // Any unexpected response shape is surfaced as an exception so the
      // caller (e.g. JournalController) can run fallback parsing logic.
      throw Exception('Text emotion API returned invalid response');
    } on TimeoutException {
      throw Exception('Text emotion API timed out');
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
}

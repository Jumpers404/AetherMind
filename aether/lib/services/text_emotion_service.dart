import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ml_api_config.dart';

class TextEmotionService {
  TextEmotionService({http.Client? client}) : _client = client ?? http.Client() {
    MlApiConfig.logActiveConfigOnce();
  }

  static final Uri _predictUri = MlApiConfig.textPredictUri;

  final http.Client _client;

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

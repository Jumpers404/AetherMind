import 'package:flutter/foundation.dart';

class MlApiConfig {
  MlApiConfig._();

  // 🔥 SINGLE SWITCH (change this only)
  static const bool useLocal = true;

  static const String _localBaseUrl = 'http://127.0.0.1:8010';
  static const String _prodBaseUrl = 'https://aethermind-ml.onrender.com';

  static String get _baseUrl => useLocal ? _localBaseUrl : _prodBaseUrl;

  static Uri get keystrokePredictUri =>
      Uri.parse('$_baseUrl/predict');

  static Uri get textPredictUri =>
      Uri.parse('$_baseUrl/predict/text');

  static void logActiveConfigOnce() {
    debugPrint(
      'ML API => ${useLocal ? "LOCAL" : "PROD"} | base=$_baseUrl',
    );
  }
}
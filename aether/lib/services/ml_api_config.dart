import 'package:flutter/foundation.dart';

class MlApiConfig {
  MlApiConfig._();

  static bool _hasLoggedConfig = false;

  static const String _prodBaseUrl = 'https://aethermind-ml.onrender.com';
  static const String _localBaseUrl =
      String.fromEnvironment('LOCAL_ML_BASE_URL', defaultValue: 'http://127.0.0.1:10000');

  static const String _explicitKeystrokeUrl =
      String.fromEnvironment('KEYSTROKE_API_URL', defaultValue: '');
  static const String _explicitTextUrl =
      String.fromEnvironment('TEXT_EMOTION_API_URL', defaultValue: '');

  // Manual toggle:
  // 1 => localhost
  // 0 => Render
  static const int _useLocalMl =
    int.fromEnvironment('ML_USE_LOCAL', defaultValue: 0);

  static bool get _isLocalEnabled => _useLocalMl == 1;

  static String get _baseUrl {
    return _isLocalEnabled ? _localBaseUrl : _prodBaseUrl;
  }

  static Uri get keystrokePredictUri {
    if (_explicitKeystrokeUrl.isNotEmpty) {
      return Uri.parse(_explicitKeystrokeUrl);
    }
    return Uri.parse('$_baseUrl/predict');
  }

  static Uri get textPredictUri {
    if (_explicitTextUrl.isNotEmpty) {
      return Uri.parse(_explicitTextUrl);
    }
    return Uri.parse('$_baseUrl/predict/text');
  }

  static void logActiveConfigOnce() {
    if (_hasLoggedConfig) {
      return;
    }
    _hasLoggedConfig = true;

    final mode = _isLocalEnabled ? 'manual_local' : 'manual_prod';

    debugPrint(
      'ML API CONFIG => mode=$mode, ML_USE_LOCAL=$_useLocalMl, base=$_baseUrl, '
      'keystroke=${keystrokePredictUri.toString()}, '
      'text=${textPredictUri.toString()}',
    );
  }
}

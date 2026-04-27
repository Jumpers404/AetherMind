/// Centralized ML API configuration for the app.
///
/// This file controls which ML backend the Flutter app will call for both
/// keystroke-based and text-based emotion predictions. It supports three
/// mechanisms, in precedence order:
/// 1. Explicit URL overrides via the environment variables
///    - `KEYSTROKE_API_URL`
///    - `TEXT_EMOTION_API_URL`
/// 2. Manual mode toggle via the dart-define `ML_USE_LOCAL`:
///    - `1` => use local ML base URL (useful for development)
///    - `0` => use the production Render-hosted URL (default)
/// 3. Fallback base URL (production or local default)
///
/// Usage examples:
/// - Run Flutter using the remote (default):
///     flutter run
/// - Force local ML during development:
///     flutter run --dart-define=ML_USE_LOCAL=1
/// - Override only the text prediction endpoint:
///     flutter run --dart-define=TEXT_EMOTION_API_URL=http://127.0.0.1:10000/predict/text
///
/// Note: This file only constructs URIs and logs the active configuration.
/// It does not perform network requests directly.
import 'package:flutter/foundation.dart';

class MlApiConfig {
  MlApiConfig._();

  static bool _hasLoggedConfig = false;

  // Production (deployed) base URL for the ML microservice.
  static const String _prodBaseUrl = 'https://aethermind-ml.onrender.com';

  // Local base URL default; can be overridden with dart-define
  // `LOCAL_ML_BASE_URL` when running locally.
  static const String _localBaseUrl =
      String.fromEnvironment('LOCAL_ML_BASE_URL', defaultValue: 'http://127.0.0.1:10000');

  // Explicit override URLs (highest precedence). Use these when you want
  // to point only one endpoint at a custom host.
  static const String _explicitKeystrokeUrl =
      String.fromEnvironment('KEYSTROKE_API_URL', defaultValue: '');
  static const String _explicitTextUrl =
      String.fromEnvironment('TEXT_EMOTION_API_URL', defaultValue: '');

  // Manual toggle for local vs prod ML. Default is 0 (production).
  // Set with: --dart-define=ML_USE_LOCAL=1
  static const int _useLocalMl =
    int.fromEnvironment('ML_USE_LOCAL', defaultValue: 0);

  static bool get _isLocalEnabled => _useLocalMl == 1;

  static String get _baseUrl {
    return _isLocalEnabled ? _localBaseUrl : _prodBaseUrl;
  }

  /// Effective keystroke prediction URI (explicit override or built from base).
  static Uri get keystrokePredictUri {
    if (_explicitKeystrokeUrl.isNotEmpty) {
      return Uri.parse(_explicitKeystrokeUrl);
    }
    return Uri.parse('$_baseUrl/predict');
  }

  /// Effective text prediction URI (explicit override or built from base).
  static Uri get textPredictUri {
    if (_explicitTextUrl.isNotEmpty) {
      return Uri.parse(_explicitTextUrl);
    }
    return Uri.parse('$_baseUrl/predict/text');
  }

  /// Logs the active configuration once. Useful during development and
  /// debugging to confirm which backend the app will call.
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

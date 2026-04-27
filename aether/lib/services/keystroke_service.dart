/// KeystrokeService
///
/// Client wrapper for the keystroke ML endpoint. Accepts a small feature
/// vector (typing speed, pauses, backspaces, etc.) and returns an emotion
/// prediction and confidence. This service is intentionally tolerant: it
/// returns a safe default of `emotion: 'unknown'` and `confidence: 0.0` when
/// the remote API times out or returns an unexpected payload so the app can
/// continue functioning without blocking user flows.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ml_api_config.dart';

class KeystrokeService {
	KeystrokeService({http.Client? client}) : _client = client ?? http.Client() {
		MlApiConfig.logActiveConfigOnce();
	}
	// Resolved from MlApiConfig so CI/dev overrides apply.
	static final Uri _predictUri = MlApiConfig.keystrokePredictUri;

	final http.Client _client;

	/// Sends keystroke feature [data] to the ML backend and returns a map with
	/// keys `emotion` and `confidence`.
	///
	/// On timeout the method returns a safe default rather than throwing to
	/// simplify caller logic (controller saves entries even if keystroke ML
	/// fails).
	Future<Map<String, dynamic>> predictKeystrokeEmotion(
		Map<String, dynamic> data,
	) async {
		try {
			final response = await _client
				.post(
					_predictUri,
					headers: const {'Content-Type': 'application/json'},
					body: jsonEncode(data),
				)
				.timeout(const Duration(seconds: 4));

			if (response.statusCode >= 200 && response.statusCode < 300) {
				final decoded = jsonDecode(response.body);
				if (decoded is Map<String, dynamic>) {
					return <String, dynamic>{
						'emotion': (decoded['emotion'] ?? 'unknown').toString(),
						'confidence': _toDouble(decoded['confidence']),
					};
				}
			}
		} on TimeoutException {
			// Return safe default for UI flows.
			return <String, dynamic>{
				'emotion': 'unknown',
				'confidence': 0.0,
			};
		}

		return <String, dynamic>{
			'emotion': 'unknown',
			'confidence': 0.0,
		};
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

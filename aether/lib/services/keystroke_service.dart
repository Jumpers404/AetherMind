import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ml_api_config.dart';

class KeystrokeService {
	KeystrokeService({http.Client? client}) : _client = client ?? http.Client() {
		MlApiConfig.logActiveConfigOnce();
	}
	static final Uri _predictUri = MlApiConfig.keystrokePredictUri;

	final http.Client _client;

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

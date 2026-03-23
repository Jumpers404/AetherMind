import 'dart:convert';

import 'package:http/http.dart' as http;

class KeystrokeService {
	KeystrokeService({http.Client? client}) : _client = client ?? http.Client();

	static const String _defaultApiUrl =
		  'https://aethermind-ml.onrender.com/predict';
	static final Uri _predictUri = Uri.parse(
		const String.fromEnvironment(
			'KEYSTROKE_API_URL',
			defaultValue: _defaultApiUrl,
		),
	);

	final http.Client _client;

	Future<Map<String, dynamic>> predictKeystrokeEmotion(
		Map<String, dynamic> data,
	) async {
		final response = await _client.post(
			_predictUri,
			headers: const {'Content-Type': 'application/json'},
			body: jsonEncode(data),
		);

		if (response.statusCode >= 200 && response.statusCode < 300) {
			final decoded = jsonDecode(response.body);
			if (decoded is Map<String, dynamic>) {
				return <String, dynamic>{
					'emotion': (decoded['emotion'] ?? 'unknown').toString(),
					'confidence': _toDouble(decoded['confidence']),
				};
			}
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

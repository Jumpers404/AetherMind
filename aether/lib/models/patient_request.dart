import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRequest {
  const PatientRequest({
    required this.id,
    required this.userId,
    required this.psychiatristId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String psychiatristId;
  final String status;
  final DateTime? createdAt;

  factory PatientRequest.fromMap(String id, Map<String, dynamic> data) {
    return PatientRequest(
      id: id,
      userId: data['user_id'] as String? ?? '',
      psychiatristId: data['psychiatrist_id'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: _parseDate(data['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}

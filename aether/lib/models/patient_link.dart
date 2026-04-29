import 'package:cloud_firestore/cloud_firestore.dart';

class PatientLink {
  const PatientLink({
    required this.id,
    required this.psychiatristId,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.lastAccessedAt,
  });

  final String id;
  final String psychiatristId;
  final String userId;
  final String userName;
  final DateTime? createdAt;
  final DateTime? lastAccessedAt;

  factory PatientLink.fromMap(String id, Map<String, dynamic> data) {
    return PatientLink(
      id: id,
      psychiatristId: data['psychiatrist_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      userName: data['user_name'] as String? ?? 'Unknown',
      createdAt: _parseDate(data['created_at']),
      lastAccessedAt: _parseDate(data['last_accessed_at']),
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

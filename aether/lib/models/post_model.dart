class SupportPost {
  final String id;
  final String anonymousId;
  final String text;
  final String mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime expiresAt;

  SupportPost({
    required this.id,
    required this.anonymousId,
    required this.text,
    required this.mood,
    required this.tags,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anonymousId': anonymousId,
      'text': text,
      'mood': mood,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory SupportPost.fromJson(Map<String, dynamic> json) {
    return SupportPost(
      id: json['id'],
      anonymousId: json['anonymousId'],
      text: json['text'],
      mood: json['mood'],
      tags: List<String>.from(json['tags'] ?? const []),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

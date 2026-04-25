class SupportReply {
  final String id;
  final String postId;
  final String anonymousId;
  final String text;
  final DateTime createdAt;

  SupportReply({
    required this.id,
    required this.postId,
    required this.anonymousId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'anonymousId': anonymousId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SupportReply.fromJson(Map<String, dynamic> json) {
    return SupportReply(
      id: json['id'],
      postId: json['postId'],
      anonymousId: json['anonymousId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

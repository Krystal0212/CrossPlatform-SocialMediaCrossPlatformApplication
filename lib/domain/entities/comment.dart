class CommentModel {
  final String commentId;
  final String username;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? likes;

  CommentModel({
    required this.commentId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
  });

  // factory CommentModel.fromJson(Map<String, dynamic> json) {
  //   return CommentModel(
  //     content: json['content'],
  //     timestamp: DateTime.parse(json['timestamp']),
  //     likes: json['likes'] ?? {},
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'userId': userId,
  //     'content': content,
  //     'timestamp': timestamp.toIso8601String(),
  //     'likes': likes,
  //   };
  // }
}
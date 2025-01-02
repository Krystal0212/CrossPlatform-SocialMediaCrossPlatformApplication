class PostModel {
  final String postId;
  final String username;
  final String userAvatar;
  final String content;
  final List<Map<String, String>> media; // Updated to support multiple media types
  final DateTime timestamp;
  final int likeAmount;
  final int commentAmount;
  final int viewAmount;
  final List<String> topicRefs;
  final Map<String, dynamic>? comments;
  final Map<String, dynamic>? likes;
  final Map<String, dynamic>? views;

  PostModel({
    required this.postId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.likeAmount,
    required this.commentAmount,
    required this.viewAmount,
    required this.media,
    required this.timestamp,
    required this.comments,
    required this.likes,
    required this.views,
    required this.topicRefs,
  });

  factory PostModel.newPost({
    required String postId,
    required String username,
    required String userAvatar,
    required String content,
    required List<Map<String, String>> media,
    required DateTime timestamp,
    required List<String> topicRefs,
  }) {
    return PostModel(
      postId: postId,
      username: username,
      userAvatar: userAvatar,
      content: content,
      media: media,
      timestamp: timestamp,
      likeAmount: 0,
      commentAmount: 0,
      viewAmount: 0,
      comments: {},
      likes: {},
      views: {},
      topicRefs: topicRefs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'media': media,
      'timestamp': timestamp.toIso8601String(),
      'likeAmount': likeAmount,
      'commentAmount': commentAmount,
      'viewAmount': viewAmount,
      'topicRefs': topicRefs,
      'comments': comments,
      'likes': likes,
      'views': views,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'],
      username: map['username'],
      userAvatar: map['userAvatar'],
      content: map['content'],
      media: List<Map<String, String>>.from(map['media'] ?? []),
      timestamp: DateTime.parse(map['timestamp']),
      likeAmount: map['likeAmount'] ?? 0,
      commentAmount: map['commentAmount'] ?? 0,
      viewAmount: map['viewAmount'] ?? 0,
      topicRefs: List<String>.from(map['topicRefs'] ?? []),
      comments: map['comments'],
      likes: map['likes'],
      views: map['views'],
    );
  }
}

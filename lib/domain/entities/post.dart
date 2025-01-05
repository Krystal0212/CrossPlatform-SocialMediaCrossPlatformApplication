class PostModel {
  final String postId;
  final String username;
  final String userAvatarUrl;
  final String content;
  final List<Map<String, String>>? media; // Optional media
  final List<Map<String, String>>? mediaOffline; // Optional mediaOffline
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
    required this.userAvatarUrl,
    required this.content,
    this.media,
    this.mediaOffline,
    required this.timestamp,
    required this.likeAmount,
    required this.commentAmount,
    required this.viewAmount,
    required this.topicRefs,
    required this.comments,
    required this.likes,
    required this.views,
  })  : assert(
  (media != null || mediaOffline != null),
  'Either media or mediaOffline must be provided');

  factory PostModel.newPost({
    required String postId,
    required String username,
    required String userAvatar,
    required String content,
    List<Map<String, String>>? media,
    List<Map<String, String>>? mediaOffline,
    required DateTime timestamp,
    required List<String> topicRefs,
  }) {
    assert(
    (media != null || mediaOffline != null),
    'Either media or mediaOffline must be provided');
    return PostModel(
      postId: postId,
      username: username,
      userAvatarUrl: userAvatar,
      content: content,
      media: media,
      mediaOffline: mediaOffline,
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
      'userAvatar': userAvatarUrl,
      'content': content,
      'media': media,
      'mediaOffline': mediaOffline,
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
      userAvatarUrl: map['userAvatar'],
      content: map['content'],
      media: map['media'] != null
          ? (map['media'] as List<dynamic>).map((item) {
        final mapItem = item as Map<String, dynamic>;
        return mapItem.map(
              (key, value) => MapEntry(key, value.toString()),
        );
      }).toList()
          : null,
      mediaOffline: map['mediaOffline'] != null
          ? (map['mediaOffline'] as List<dynamic>).map((item) {
        final mapItem = item as Map<String, dynamic>;
        return mapItem.map(
              (key, value) => MapEntry(key, value.toString()),
        );
      }).toList()
          : null,
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
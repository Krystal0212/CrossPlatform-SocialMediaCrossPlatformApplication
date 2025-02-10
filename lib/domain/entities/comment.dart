import 'package:socialapp/utils/import.dart';

class CommentPostModel {
  final String? commentId;
  String? userId;
  String? username;
  String? userAvatar;
  final String content;
  final int priorityRank, likesCount;
  final Timestamp timestamp;
  final Set<String> likes;
  Map<String, ReplyCommentPostModel> replyComments;
  final Map<String, ImageData>? media;
  final String? record;
  DocumentSnapshot? documentSnapshot;

  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CommentPostModel({
    required this.likesCount,
    required this.replyComments,
    required this.priorityRank,
    this.commentId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    this.userId,
    this.media,
    this.record,
    this.documentSnapshot,
  }) : assert(
          !(media != null && record != null),
          'Either media or record must be provided, but not both.',
        );

  CommentPostModel.newComment({
    required this.priorityRank,
    required this.content,
    required this.userId,
    this.media,
    this.record,
  })  : timestamp = Timestamp.now(),
        likes = {},
        replyComments = {},
  likesCount = 0,
        commentId = null,
        assert(
          !(media != null && record != null),
          'Either media or record can be provided, but not both.',
        );

  factory CommentPostModel.fromMap(Map<String, dynamic> map) {
    return CommentPostModel(
      commentId: map['commentId'],
      userId: map['userId'] as String?,
      username: map['username'] as String,
      userAvatar: map['userAvatar'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as Timestamp,
      likes: Set<String>.from(map['likes'] ?? {}),
      likesCount: map['likesCount'] as int,
      media: map['media'] != null
          ? (map['media'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, ImageData.fromMap(value)),
      )
          : null,
      record: map['record'] as String?,
      priorityRank: map['priorityRank'],
      documentSnapshot: map['documentSnapshot'] as DocumentSnapshot?,
      replyComments: map['replyComments'] as Map<String, ReplyCommentPostModel>,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'userRef': _usersRef.doc(userId),
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'likesCount': likesCount,
      'replyComments': replyComments,
      'media': media?.map((key, value) => MapEntry(key, value.toMap())),
      'record': record,
      'priorityRank': priorityRank,
    };
  }

  void likeComment(String userId) {
    likes.add(userId);
  }

  void unlikeComment(String userId) {
    likes.remove(userId);
  }
}

class ReplyCommentPostModel {
  final String? order;
  String? userId;
  String? username;
  String? userAvatar;
  final String content;
  final Timestamp timestamp;
  final Set<String> likes;

  ReplyCommentPostModel({
    this.order,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    this.userId,
  });

  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  ReplyCommentPostModel.newReplyComment({
    required this.content,
    required this.userId,
  })  : timestamp = Timestamp.now(),
        likes = {},
        order = null;

  factory ReplyCommentPostModel.fromMap(Map<String, dynamic> map) {
    return ReplyCommentPostModel(
      order: map['order'],
      userId: map['userId'] as String?,
      username: map['username'] as String?,
      userAvatar: map['userAvatar'] as String?,
      content: map['content'] as String,
      timestamp: map['timestamp'] as Timestamp,
      likes: Set<String>.from(map['likes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userRef': _usersRef.doc(userId),
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
    };
  }

  void likeComment(String userId) {
    likes.add(userId);
  }

  void unlikeComment(String userId) {
    likes.remove(userId);
  }
}

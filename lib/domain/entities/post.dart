import 'package:socialapp/utils/import.dart';

class NewPostModel {
  final String content;
  final Map<String, OnlineMediaItem> media;
  final Timestamp timestamp;
  final Set<DocumentReference> topicRefs;
  final DocumentReference userRef;

  const NewPostModel( {
    required this.content,
    required this.media,
    required this.timestamp,
    required this.topicRefs,
    required this.userRef,
  });


  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'media': media,
      'timestamp': timestamp,
      'likeAmount': 0,
      'commentAmount': 0,
      'viewAmount': 0,
      'topicRefs': topicRefs,
      'userRef': userRef,
    };
  }
}

class OnlinePostModel {
  final String postId;
  final String username;
  final String userAvatarUrl;
  final String content;
  final Map<String, OnlineMediaItem> media;
  final Timestamp timestamp;
  final int likeAmount;
  final int commentAmount;
  final int viewAmount;
  final Set<DocumentReference> topicRefs;
  final Set<String> comments;
  final Set<String> likes;


  OnlinePostModel({
    required this.postId,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.media,
    required this.timestamp,
    required this.likeAmount,
    required this.commentAmount,
    required this.viewAmount,
    required this.topicRefs,
    required this.comments,
    required this.likes,
  });

  factory OnlinePostModel.newPost({
    required String content,
    required Map<String, OnlineMediaItem> media,
    required Timestamp timestamp,
    required Set<DocumentReference> topicRefs,
  }) {
    return OnlinePostModel(
      postId: '',
      username: '',
      userAvatarUrl: '',
      content: content,
      media: media,
      timestamp: timestamp,
      likeAmount: 0,
      commentAmount: 0,
      viewAmount: 0,
      comments: {},
      likes: {},
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
      'timestamp': timestamp,
      'likeAmount': likeAmount,
      'commentAmount': commentAmount,
      'viewAmount': viewAmount,
      'topicRefs': topicRefs,
      'comments': comments,
      'likes': likes,
    };
  }

  factory OnlinePostModel.fromMap(Map<String, dynamic> map) {
    return OnlinePostModel(
      postId: map['postId'],
      username: map['username'],
      userAvatarUrl: map['userAvatar'],
      content: map['content'],
      media: (map['media'] as Map<String, dynamic>).map((key, value) =>
          MapEntry(
              key, OnlineMediaItem.fromMap(value as Map<String, dynamic>))),
      timestamp: (map['timestamp'] as Timestamp),
      likeAmount: map['likeAmount'] ?? 0,
      commentAmount: map['commentAmount'] ?? 0,
      viewAmount: map['viewAmount'] ?? 0,
      topicRefs: Set<DocumentReference>.from(map['topicRefs'] ?? []),
      comments: map['comments'],
      likes: map['likes'],
    );
  }
}

class OfflinePostModel {
  final String postId;
  final String username;
  final Uint8List userAvatarImageData;
  final String content;
  final List<OfflineMediaItem> mediaOffline;
  final DateTime timestamp;
  final int likeAmount;
  final int commentAmount;
  final int viewAmount;
  final List<String> topicRefs;
  final Set<String> comments;
  final Set<String> likes;

  OfflinePostModel({
    required this.postId,
    required this.username,
    required this.userAvatarImageData,
    required this.content,
    required this.mediaOffline,
    required this.timestamp,
    required this.likeAmount,
    required this.commentAmount,
    required this.viewAmount,
    required this.topicRefs,
    required this.comments,
    required this.likes,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'mediaOffline': mediaOffline.map((item) => item.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'likeAmount': likeAmount,
      'commentAmount': commentAmount,
      'viewAmount': viewAmount,
      'topicRefs': topicRefs,
    };
  }

  factory OfflinePostModel.fromMap(Map<String, dynamic> map) {
    return OfflinePostModel(
      postId: map['postId'],
      username: map['username'],
      userAvatarImageData: map['userAvatarImageData'],
      content: map['content'],
      mediaOffline: (map['mediaOffline'] as List<dynamic>)
          .map((item) => OfflineMediaItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likeAmount: map['likeAmount'] ?? 0,
      commentAmount: map['commentAmount'] ?? 0,
      viewAmount: map['viewAmount'] ?? 0,
      topicRefs: List<String>.from(map['topicRefs'] ?? []),
      comments: Set<String>.from(map['comments'] ?? {}),
      likes: Set<String>.from(map['likes'] ?? {}),
    );
  }
}

abstract class MediaItemBase {
  final String dominantColor;
  final double height;
  final double width;
  final String type;

  MediaItemBase({
    required this.dominantColor,
    required this.height,
    required this.width,
    required this.type,
  });

  Map<String, dynamic> toMap();

  factory MediaItemBase.fromMap(Map<String, dynamic> map, bool isOffline) {
    if (isOffline) {
      return OfflineMediaItem.fromMap(map);
    } else {
      return OnlineMediaItem.fromMap(map);
    }
  }
}

class OnlineMediaItem extends MediaItemBase {
  final String assetUrl;

  OnlineMediaItem({
    required super.dominantColor,
    required super.height,
    required super.width,
    required super.type,
    required this.assetUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'dominantColor': dominantColor,
      'height': height,
      'width': width,
      'type': type,
      'imageUrl': assetUrl,
    };
  }

  factory OnlineMediaItem.fromMap(Map<String, dynamic> map) {
    return OnlineMediaItem(
      dominantColor: map['dominantColor'],
      height: map['height'],
      width: map['width'],
      type: map['type'],
      assetUrl: map['imageUrl'],
    );
  }
}

class OfflineMediaItem extends MediaItemBase {
  final Uint8List imageData;

  OfflineMediaItem({
    required super.dominantColor,
    required super.height,
    required super.width,
    required super.type,
    required this.imageData,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'dominantColor': dominantColor,
      'height': height,
      'width': width,
      'type': type,
      'imageData': imageData,
    };
  }

  factory OfflineMediaItem.fromMap(Map<String, dynamic> map) {
    return OfflineMediaItem(
      dominantColor: map['dominantColor'] as String,
      height: (map['height'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      type: map['type'] as String,
      imageData: map['imageData'] as Uint8List,
    );
  }
}

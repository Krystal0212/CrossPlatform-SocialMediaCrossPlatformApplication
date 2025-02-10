import 'package:socialapp/utils/import.dart';

class NewPostModel {
  final String content;
  final Map<String, OnlineMediaItem>? media;
  final String? record;
  final Timestamp timestamp;
  final Set<DocumentReference>? topicRefs;
  final DocumentReference userRef;

  const NewPostModel({
    required this.content,
    this.media,
    this.record,
    required this.timestamp,
    required this.topicRefs,
    required this.userRef,
  }) : assert(
          (media != null) ^ (record != null),
          'Either media or record must be provided, but not both.',
        );

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
      'record': record,
    };
  }
}

class SoundPostModel {
  final String postId;
  final String recordUrl;

  SoundPostModel({
    required this.postId,
    required this.recordUrl,
  });

  factory SoundPostModel.fromMap(Map<String, dynamic> map) {
    return SoundPostModel(
      postId: map['postId'] as String,
      recordUrl: map['recordUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'recordUrl': recordUrl,
    };
  }
}


class OnlinePostModel {
  final String postId;
  final String userId;
  final String username;
  final String userAvatarUrl;
   String content;
  final Map<String, OnlineMediaItem>? media;
  final String? record;
  final Timestamp timestamp;
  final int likeAmount;
   int commentAmount;
  final int viewAmount;
  final Set<DocumentReference> topicRefs;
  final Set<String> comments;
  final Set<String> likes;
  final DocumentSnapshot? documentSnapshot;
  final double? trendingScore;

  OnlinePostModel(   {
    required this.userId,
    required this.postId,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    this.media,
    this.record,
    required this.timestamp,
    required this.likeAmount,
    required this.commentAmount,
    required this.viewAmount,
    required this.topicRefs,
    required this.comments,
    required this.likes,this.documentSnapshot,
    this.trendingScore
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'username': username,
      'userAvatar': userAvatarUrl,
      'content': content,
      'media': media,
      'record': record,
      'timestamp': timestamp,
      'likeAmount': likeAmount,
      'commentAmount': commentAmount,
      'viewAmount': viewAmount,
      'topicRefs': topicRefs,
      'comments': comments,
      'likes': likes,
      'contentLowercase': content.toLowerCase(),
    };
  }

  factory OnlinePostModel.fromMap(Map<String, dynamic> map) {
    try {
      return OnlinePostModel(
        postId: map['postId'],
        username: map['username'],
        userAvatarUrl: map['userAvatar'],
        content: map['content'],
        media: map['media'] != null
            ? (map['media'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(key, OnlineMediaItem.fromMap(value as Map<String, dynamic>)))
            : null,
        record: map['record'],
        timestamp: (map['timestamp'] as Timestamp),
        likeAmount: map['likeAmount'] ?? 0,
        commentAmount: map['commentAmount'] ?? 0,
        viewAmount: map['viewAmount'] ?? 0,
        topicRefs: Set<DocumentReference>.from(map['topicRefs'] ?? []),
        comments: map['comments'],
        likes: map['likes'],
        documentSnapshot: map['documentSnapshot'],
        trendingScore: map['trendingScore'], userId: map['userId'],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error creating OnlinePostModel from map: $e");
      }
      rethrow;
    }
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
  final bool isNSFW;

  MediaItemBase({
    required this.dominantColor,
    required this.height,
    required this.width,
    required this.type,
    required this.isNSFW,
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
  final String imageUrl;
  final String? thumbnailUrl;

  OnlineMediaItem({
    required super.dominantColor,
    required super.height,
    required super.width,
    required super.type,
    required this.imageUrl,
    required super.isNSFW,
    required this.thumbnailUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'dominantColor': dominantColor,
      'height': height,
      'width': width,
      'type': type,
      'imageUrl': imageUrl,
      'isNSFW': isNSFW,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory OnlineMediaItem.fromMap(Map<String, dynamic> map) {
    return OnlineMediaItem(
      dominantColor: map['dominantColor'],
      height: map['height'].toDouble(),
      width: map['width'].toDouble(),
      type: map['type'],
      imageUrl: map['imageUrl'],
      isNSFW: map['isNSFW'],
      thumbnailUrl: map['thumbnailUrl'],
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
    required super.isNSFW,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'dominantColor': dominantColor,
      'height': height,
      'width': width,
      'type': type,
      'imageData': imageData,
      'isNSFW': isNSFW
    };
  }

  factory OfflineMediaItem.fromMap(Map<String, dynamic> map) {
    return OfflineMediaItem(
      dominantColor: map['dominantColor'] as String,
      height: (map['height'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      type: map['type'] as String,
      imageData: map['imageData'] as Uint8List,
      isNSFW: map['isNSFW'],
    );
  }
}

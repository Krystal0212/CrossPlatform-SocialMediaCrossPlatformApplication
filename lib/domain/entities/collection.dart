import 'package:socialapp/utils/import.dart';

class CollectionModel {
  final String collectionId;
  final String title;
  final String? dominantColor;
  final String? presentationUrl;
  final int shotsNumber;
   List<PreviewAssetPostModel> assets;
  final UserModel userData;
  final bool isPublic;
  final bool? isNSFW;

  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionModel( {
    required this.shotsNumber,
    required this.presentationUrl,
    required this.dominantColor,
    required this.collectionId,
    required this.title,
    required this.assets,
    required this.userData,
    required this.isPublic,required this.isNSFW,
  });

  CollectionModel.newCollection( {
    required this.title,
    required this.userData,
    required this.isPublic,
  })  : presentationUrl = '',
        shotsNumber = 0,
        dominantColor = 'FFBDBDBD',
        assets = [],
        collectionId = '',
        isNSFW = false
  ;

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      collectionId: map['collectionId'] ?? '',
      title: map['title'] ?? '',
      assets: (map['assets'] as List<dynamic>?)
              ?.map((post) =>
                  PreviewAssetPostModel.fromMap(post as Map<String, dynamic>))
              .toList() ??
          [],
      userData: UserModel.fromMap(map['userData'] as Map<String, dynamic>),
      presentationUrl: map['presentationUrl'],
      dominantColor: map['dominantColor'],
      shotsNumber: map['shotsNumber'],
      isPublic: map['isPublic'],
      isNSFW: map['isNSFW'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'assets': assets.map((post) => post.toMap()).toList(),
      'userRef': _usersRef.doc(userData.id),
      'isPublic': isPublic,
      'titleLowercase': title.toLowerCase(),
    };
  }
}

class PreviewAssetPostModel {
  final String postId;
  final double height, width;
  final String mediasOrThumbnailUrl;
  final int mediaOrder;
  final bool isVideo;
  final bool isNSFW;
  final String dominantColor;

  PreviewAssetPostModel({
    required this.postId,
    required this.mediasOrThumbnailUrl,
    required this.mediaOrder,
    required this.height,
    required this.width,
    required this.isVideo,
    required this.isNSFW,
    required this.dominantColor,
  });

  factory PreviewAssetPostModel.fromMap(Map<String, dynamic> map) {
    return PreviewAssetPostModel(
      postId: map['postId'] as String,
      mediasOrThumbnailUrl: map['mediasOrThumbnailUrl'],
      mediaOrder: map['mediaOrder'],
      height: map['height'],
      width: map['width'],
      isVideo: map['isVideo'],
      isNSFW: map['isNSFW'],
      dominantColor: map['dominantColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'mediasOrThumbnailUrl': mediasOrThumbnailUrl,
      'mediaOrder': mediaOrder,
      'height': height,
      'width': width,
      'isVideo': isVideo,
      'isNSFW': isNSFW,
      'dominantColor': dominantColor,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreviewAssetPostModel &&
        other.postId == postId &&
        other.mediasOrThumbnailUrl == mediasOrThumbnailUrl &&
        other.mediaOrder == mediaOrder &&
        other.width == width &&
        other.height == height &&
        other.isVideo == isVideo &&
        other.isNSFW == isNSFW &&
        other.dominantColor == dominantColor;
  }

  @override
  int get hashCode => Object.hash(postId, mediasOrThumbnailUrl, mediaOrder,
      width, height, isVideo, isNSFW, dominantColor);
}

import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/domain/entities/user.dart';

class CollectionModel {
  final String collectionId;
  final String title;
  final String? dominantColor;
  final String? presentationUrl;
  final int shotsNumber;
  final List<PreviewAssetPostModel> posts;
  final UserModel userData;

  CollectionModel( {required this.shotsNumber,
    required this.presentationUrl,
    required this.dominantColor,
    required this.collectionId,
    required this.title,
    required this.posts,
    required this.userData,
  });

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      collectionId: map['collectionId'] ?? '',
      title: map['title'] ?? '',
      posts: (map['posts'] as List<dynamic>?)
              ?.map((post) =>
                  PreviewAssetPostModel.fromMap(post as Map<String, dynamic>))
              .toList() ??
          [],
      userData: UserModel.fromMap(map['userData'] as Map<String, dynamic>),
      presentationUrl: map['presentationUrl'],
      dominantColor: map['dominantColor'], shotsNumber: map['shotsNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'title': title,
      'posts': posts.map((post) => post.toMap()).toList(),
      'userData': userData.toMap(),
      'presentationUrl': presentationUrl,
      'dominantColor': dominantColor,
      'shotsNumber': shotsNumber,
    };
  }
}

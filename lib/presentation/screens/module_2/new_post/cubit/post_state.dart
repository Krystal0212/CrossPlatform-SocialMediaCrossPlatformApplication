import 'package:socialapp/utils/import.dart';

abstract class PostState {
  const PostState();
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostWithImage extends PostState {
  final File image;
  final String caption;

  File get getImage => image;

  PostWithImage(this.image, this.caption);
}

class PostWithoutImage extends PostState {
  // final String caption;

  const PostWithoutImage();
}

class PostWithData extends PostState {
  final File? image;
  final String? content;

  File? get getImage => image;

  String? get getContent => content;

  const PostWithData({this.image, this.content});

  PostWithData copyWith({File? image, String? content}) {
    return PostWithData(
      image: image ?? this.image,
      content: content ?? this.content,
    );
  }
}

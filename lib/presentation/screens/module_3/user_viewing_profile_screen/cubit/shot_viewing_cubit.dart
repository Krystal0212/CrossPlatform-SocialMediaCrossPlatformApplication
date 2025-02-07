import 'package:socialapp/utils/import.dart';

import 'shot_viewing_state.dart';

class ShotViewingPostCubit extends Cubit<ShotViewingPostState> {
  final String userId;

  ShotViewingPostCubit({required this.userId}) : super(ShotViewingPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getImageUrlsForUserPosts();
  }

  Future<void> getImageUrlsForUserPosts() async {
    emit(ShotViewingPostLoading());

    try {

      List<OnlinePostModel>? posts = await serviceLocator<PostRepository>()
          .getAssetPostsByUserId(userId);
      List<PreviewAssetPostModel> imageUrls = [];

      if (posts != null) {
        for (var post in posts) {
          List<PreviewAssetPostModel> imageUrlsForPost = await serviceLocator<PostRepository>()
              .getPostImagesByPostId(post.postId);
          if (imageUrlsForPost.isNotEmpty) {
            imageUrls.addAll(imageUrlsForPost);
          }
        }
      }

      emit(ShotViewingPostLoaded(imageUrls));
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(ShotViewingPostError());
    }
  }


}

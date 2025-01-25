import 'package:socialapp/utils/import.dart';
import 'media_state.dart';

class MediaPostCubit extends Cubit<MediaPostState> {
  MediaPostCubit() : super(MediaPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    await getImageUrlsForUserPosts();
  }

  Future<void> getImageUrlsForUserPosts() async {
    emit(MediaPostLoading());

    try {
      final User? currentUser =
      await serviceLocator<AuthRepository>().getCurrentUser();

      List<OnlinePostModel>? posts = await serviceLocator<PostRepository>()
          .getPostsByUserId(currentUser?.uid ?? "");
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

      emit(MediaPostLoaded(imageUrls));
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(MediaPostError());
    }
  }
}

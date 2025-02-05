import 'package:socialapp/presentation/screens/module_3/profile_and_setting/cubit/shot_state.dart';
import 'package:socialapp/utils/import.dart';

class ShotPostCubit extends Cubit<ShotPostState> {
  final String userId;

  ShotPostCubit({required this.userId}) : super(ShotPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getImageUrlsForUserPostsStream();
  }

  // Future<void> getImageUrlsForUserPosts() async {
  //   emit(ShotPostLoading());
  //
  //   try {
  //
  //     List<OnlinePostModel>? posts = await serviceLocator<PostRepository>()
  //         .getPostsByUserId(userId);
  //     List<PreviewAssetPostModel> imageUrls = [];
  //
  //     if (posts != null) {
  //       for (var post in posts) {
  //         List<PreviewAssetPostModel> imageUrlsForPost = await serviceLocator<PostRepository>()
  //             .getPostImagesByPostId(post.postId);
  //         if (imageUrlsForPost.isNotEmpty) {
  //           imageUrls.addAll(imageUrlsForPost);
  //         }
  //       }
  //     }
  //
  //     emit(ShotPostLoaded(imageUrls));
  //   } catch (error) {
  //     debugPrint("Error fetching image URLs: $error");
  //     emit(ShotPostError());
  //   }
  // }

  Future<void> getImageUrlsForUserPostsStream() async {
    emit(ShotPostLoading());

    try {

      Stream<List<PreviewAssetPostModel>?> postStreams = serviceLocator<PostRepository>()
          .getPostsByUserIdRealTime(userId);

      // List<PreviewAssetPostModel> imageUrls = [];
      //
      // if (posts != null) {
      //   for (var post in posts) {
      //     List<PreviewAssetPostModel> imageUrlsForPost = await serviceLocator<PostRepository>()
      //         .getPostImagesByPostId(post.postId);
      //     if (imageUrlsForPost.isNotEmpty) {
      //       imageUrls.addAll(imageUrlsForPost);
      //     }
      //   }
      // }

      emit(ShotPostLoaded(postStreams));
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(ShotPostError());
    }
  }


}

import 'package:socialapp/utils/import.dart';

class PostRepositoryImpl extends PostRepository {
  @override
  Future<List<OnlinePostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false}) {
    return serviceLocator
        .get<PostService>()
        .getPostsData(isOffline: isOffline, skipLocalFetch: skipLocalFetch);
  }

  @override
  Future<List<OnlinePostModel>> getExplorePostsData(
      {required bool isOffline, bool skipLocalFetch = false}) {
    return serviceLocator
        .get<PostService>()
        .getExplorePostsData(isOffline: isOffline);
  }

  @override
  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post) {
    return serviceLocator.get<PostService>().getCommentPost(post);
  }

  @override
  Future<void> createAssetPost(
      String content,
      List<Map<String, dynamic>> imagesAndVideos,
      List<TopicModel> topics) async {
    return serviceLocator
        .get<PostService>()
        .createAssetPost(content, imagesAndVideos, topics);
  }

  @override
  Future<List<OnlinePostModel>?> getPostsByUserId(String userId) {
    return serviceLocator.get<PostService>().getPostsByUserId(userId);
  }

  @override
  Future<List<OnlinePostModel>> loadMorePostsData() {
    return serviceLocator.get<PostService>().loadMorePostsData();
  }

  @override
  Future<void> createSoundPost(String content, String filePath) async {
    return serviceLocator.get<PostService>().createSoundPost(content, filePath);
  }

  @override
  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(String postId) {
    return serviceLocator.get<PostService>().getPostImagesByPostId(postId);
  }
}

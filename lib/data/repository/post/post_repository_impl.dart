import 'package:socialapp/utils/import.dart';

class PostRepositoryImpl extends PostRepository {
  @override
  Future<List<OnlinePostModel>> getPostsData({required bool isOffline, bool skipLocalFetch = false}) {
    return serviceLocator.get<PostService>().getPostsData(isOffline: isOffline, skipLocalFetch: skipLocalFetch);
  }

  @override
  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post) {
    return serviceLocator.get<PostService>().getCommentPost(post);
  }

  @override
  Future<void> createAssetPost(
      String content, List<Map<String, dynamic>> imagesAndVideos, List<TopicModel> topics)async {
    return serviceLocator.get<PostService>().createAssetPost(content, imagesAndVideos, topics);
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
  Future<String?> getPostImageById(String postId) {
    return serviceLocator.get<PostService>().getPostImageById(postId);
  }
}

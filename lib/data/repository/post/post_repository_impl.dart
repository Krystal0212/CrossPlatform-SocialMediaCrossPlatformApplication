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
      {bool isOffline = false,
      bool skipLocalFetch = false,
        List<OnlinePostModel>? lastFetchedModels,}) {
    return serviceLocator.get<PostService>().getExplorePostsData(
        isOffline: isOffline,
        skipLocalFetch: skipLocalFetch,
        lastFetchedModels: lastFetchedModels);
  }

  @override
  Future<List<OnlinePostModel>> getTrendyPostsData({
    bool isOffline = false,
    bool skipLocalFetch = false,
    List<OnlinePostModel>? lastFetchedModels,
  }) {
    return serviceLocator.get<PostService>().getTrendyPostsData(
        isOffline: isOffline,
        skipLocalFetch: skipLocalFetch,
        lastFetchedModels: lastFetchedModels);
  }

  @override
  Future<List<OnlinePostModel>> getFollowingPostsData(
  {bool isOffline = false,
  bool skipLocalFetch = false,
  OnlinePostModel? lastFetchedPost,}){
    return serviceLocator.get<PostService>().getFollowingPostsData(
      isOffline: isOffline,
      skipLocalFetch: skipLocalFetch,
      lastFetchedPost: lastFetchedPost,
    );
  }

  @override
  Stream<List<CommentPostModel>> getCommentsOfPost(String postId) {
    return serviceLocator.get<PostService>().getCommentsOfPost(postId);
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
  Future<void> createSoundPost(String content, String filePath) async {
    return serviceLocator.get<PostService>().createSoundPost(content, filePath);
  }

  @override
  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(String postId) {
    return serviceLocator.get<PostService>().getPostImagesByPostId(postId);
  }

  @override
  Future<void> syncLikesToFirestore(Map<String, bool> likedPostsCache) {
    return serviceLocator.get<PostService>().syncLikesToFirestore(likedPostsCache);
  }
}

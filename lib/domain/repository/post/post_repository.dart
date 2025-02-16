import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';

abstract class PostRepository {
  Future<List<OnlinePostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false});

  Future<List<OnlinePostModel>> getExplorePostsData(
      {bool isOffline = false,
      bool skipLocalFetch = false,
      List<OnlinePostModel>? lastFetchedModels});

  Future<List<OnlinePostModel>> getTrendyPostsData({
    bool isOffline = false,
    bool skipLocalFetch = false,
    List<OnlinePostModel> lastFetchedModels,
  });

  Future<List<OnlinePostModel>> getFollowingPostsData({
    bool isOffline = false,
    bool skipLocalFetch = false,
    OnlinePostModel? lastFetchedPost,
  });

  Stream<List<CommentPostModel>> getCommentsOfPost(String postId);

  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(String postId);


  Future<void> createAssetPost(String content,
      List<Map<String, dynamic>> imagesAndVideos, List<TopicModel> topics);

  Future<void> createSoundPost(String content, String filePath);

  Future<void> syncLikesToFirestore(
      Map<String, bool> likedPostsCache);

  Future<void> syncViewsToFirestore(Map<String, bool> viewedPostsCache);

  Future<List<OnlinePostModel>?> getAssetPostsByUserId(String userId);

  Stream<List<PreviewAssetPostModel>?> getAssetPostsByUserIdRealTime(String userId);

  Future<List<PreviewSoundPostModel>> getSoundPostsByUserId(
      String userId);

  Stream<List<PreviewSoundPostModel>?> getSoundPostsByUserIdRealTime(
      String userId);

  Future<OnlinePostModel> getDataFromPostId(String postId);

  Future<List<OnlinePostModel>> searchPost(String query);

  Future<void> reduceTopicRanksOfPostForCurrentUser(String postId);

  Future<void> updatePostContent(String newContent, String postId);

  Future<void> deletePost(String postId);

}

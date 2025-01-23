import 'package:socialapp/utils/import.dart';

abstract class PostRepository {
  Future<List<OnlinePostModel>> getPostsData({required bool isOffline, bool skipLocalFetch = false});

  Future<List<OnlinePostModel>> loadMorePostsData();

  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post);

  Future<List<OnlinePostModel>?> getPostsByUserId(String userId);

  Future<String?> getPostImageById(String postId);

  Future<void> createAssetPost(
      String content, List<Map<String, dynamic>> imagesAndVideos, List<TopicModel> topics);

  // Future<void> deletePost(PostModel post);
  // Future<
  // Future<void> addPostData(AddPostReq addPostReq);

  // Future<void> updatePostData(UpdatePostReq updatePostReq);
}
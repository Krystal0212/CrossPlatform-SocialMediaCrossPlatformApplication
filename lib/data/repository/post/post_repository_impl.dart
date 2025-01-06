import 'package:socialapp/utils/import.dart';

class PostRepositoryImpl extends PostRepository {
  @override
  Future<List<PostModel>> getPostsData({required bool isOffline, bool skipLocalFetch = false}) {
    return serviceLocator.get<PostService>().getPostsData(isOffline: isOffline, skipLocalFetch: skipLocalFetch);
  }

  @override
  Future<List<CommentModel>?> getCommentPost(PostModel post) {
    return serviceLocator.get<PostService>().getCommentPost(post);
  }

  @override
  Future<void> createPost(String content, File image) {
    return serviceLocator.get<PostService>().createPost(content, image);
  }

  @override
  Future<List<PostModel>?> getPostsByUserId(String userId) {
    return serviceLocator.get<PostService>().getPostsByUserId(userId);
  }

  @override
  Future<String?> getPostImageById(String postId) {
    return serviceLocator.get<PostService>().getPostImageById(postId);
  }
}

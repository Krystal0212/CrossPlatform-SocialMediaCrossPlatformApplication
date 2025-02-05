import 'package:socialapp/utils/import.dart';

class CommentRepositoryImpl extends CommentRepository {
  @override
  Future<List<CommentPostModel>> fetchInitialComments(
      String postId, String sortBy) {
    return serviceLocator
        .get<CommentService>()
        .fetchInitialComments(postId, sortBy);
  }

  @override
  Future<void> sendComment(String postId, String postOwnerId, String comment,) {
    return serviceLocator
        .get<CommentService>()
        .sendComment(postId, postOwnerId, comment);
  }

  @override
  Future<int> sendReplyComment(String postId, String postOwnerId, String comment, String repliedTo) {
    return serviceLocator.get<CommentService>().sendReplyComment(postId, postOwnerId, comment, repliedTo);
  }

  @override
  Future<void> syncCommentLikesToFirestore(String postId,
      Map<String, bool> likedCommentsCache){
    return serviceLocator.get<CommentService>().syncCommentLikesToFirestore(postId, likedCommentsCache);
  }

  @override
  Future<List<CommentPostModel>> fetchMoreComments(String postId, String sortBy, DocumentSnapshot<Object?> lastDoc) {
    return serviceLocator.get<CommentService>().fetchMoreComments(postId, sortBy, lastDoc);
  }

  @override
  Stream<CommentPostModel?> getCommentStream(String postId) {
    return serviceLocator.get<CommentService>().getCommentStream(postId);
  }

  @override
  Future<void> removeComment(String postId, String commentId) {
    return serviceLocator.get<CommentService>().removeComment(postId, commentId);
  }

  @override
  Future<void> removeReplyComment(String postId, String repliedTo, int replyOrder) {
    return serviceLocator.get<CommentService>().removeReplyComment(postId, repliedTo, replyOrder);
  }


}

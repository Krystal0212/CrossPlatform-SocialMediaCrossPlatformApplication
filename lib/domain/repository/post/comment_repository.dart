import 'package:socialapp/utils/import.dart';

abstract class CommentRepository {

  Future<void> sendComment(
      String postId, String postOwnerId, String comment);

  Future<int> sendReplyComment(
      String postId, String postOwnerId, String comment, String repliedTo);

  Future<void> removeComment(String postId, String commentId);

  Future<void> removeReplyComment(String postId, String repliedTo, int replyOrder);

  Stream<List<CommentPostModel>> getCommentsStream(String postId, String sortBy);

  Future<void> syncCommentLikesToFirestore(
      String postId, Map<String, bool> likedCommentsCache);
}

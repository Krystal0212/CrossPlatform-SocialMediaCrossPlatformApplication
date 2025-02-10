import '../../../../../utils/import.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  Timer? _syncTimer;

  final String postId;
  final Map<String, bool> likedPostsCache = {};
  final Map<String, bool> likedCommentsCache = {};
  final Map<String, Map<String, bool>> likedReplyCommentsCache = {};

  PostDetailCubit(this.postId) : super(PostDetailLoading()) {
    _startPeriodicSync();
  }

  @override
  Future<void> close() {
    syncLikesData();
    _syncTimer?.cancel();
    return super.close();
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final user = await serviceLocator<UserRepository>().getCurrentUserData();
      if (user == null) {
        return UserModel.empty();
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Check user data: $e");
      }
      return UserModel.empty();
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      syncLikesData();
    });
  }

  void syncLikesData() async {
    await serviceLocator<PostRepository>()
        .syncLikesToFirestore(likedPostsCache);
    await serviceLocator<CommentRepository>()
        .syncCommentLikesToFirestore(postId, likedCommentsCache);
  }

  void addPostLike() {
    likedPostsCache.putIfAbsent(postId, () => true);
    likedPostsCache[postId] = true;
  }

  // Remove like status for a post
  void removePostLike() {
    likedPostsCache.putIfAbsent(postId, () => false);
    likedPostsCache[postId] = false;
  }

  void sendComment(String postOwnerId, String comment) {
    try {
      serviceLocator<CommentRepository>()
          .sendComment(postId, postOwnerId, comment);
    } catch (error) {
      if (kDebugMode) {
        print('Error sending comment for posts: $error');
      }
    }
  }

  Future<int> sendReplyComment(String postOwnerId, String comment,
      String repliedToCommentId) async {
    try {
      int replyOrder = await serviceLocator<CommentRepository>()
          .sendReplyComment(postId, postOwnerId, comment, repliedToCommentId);
      return replyOrder;
    } catch (error) {
      if (kDebugMode) {
        print('Error sending comment for posts: $error');
      }
      return -1;
    }
  }

  void addCommentLike(String commentId) {
    likedCommentsCache.putIfAbsent(commentId, () => true);
    likedCommentsCache[commentId] = true;
  }

  void removeCommentLike(String commentId) {
    likedCommentsCache.putIfAbsent(commentId, () => false);
    likedCommentsCache[commentId] = false;
  }

  Future<void> updatePostContent(String newContent, String postId) async {
    try {
      await serviceLocator<PostRepository>().updatePostContent(
           newContent, postId);
      emit(PostDetailChangeContentSuccess());
    } catch (error) {
      emit(PostDetailError(error.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await serviceLocator<PostRepository>().deletePost(postId);
      emit(PostDetailDeleteSuccess());
    } catch (error) {
      emit(PostDetailError(error.toString()));
  }
}}
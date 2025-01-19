import 'dart:io';

import 'package:socialapp/domain/entities/comment.dart';
import 'package:socialapp/domain/entities/post.dart';

abstract class PostRepository {
  Future<List<OnlinePostModel>> getPostsData({required bool isOffline, bool skipLocalFetch = false});

  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post);

  Future<List<OnlinePostModel>?> getPostsByUserId(String userId);

  Future<String?> getPostImageById(String postId);

  Future<void> createAssetPost(
      String content, List<Map<String, dynamic>> imagesAndVideos);

  // Future<void> deletePost(PostModel post);
  // Future<
  // Future<void> addPostData(AddPostReq addPostReq);

  // Future<void> updatePostData(UpdatePostReq updatePostReq);
}
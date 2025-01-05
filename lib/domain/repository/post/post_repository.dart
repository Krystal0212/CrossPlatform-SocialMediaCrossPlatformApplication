import 'dart:io';

import 'package:socialapp/domain/entities/comment.dart';
import 'package:socialapp/domain/entities/post.dart';

abstract class PostRepository {
  Future<List<PostModel>> getPostsData(bool isOffline);

  Future<List<CommentModel>?> getCommentPost(PostModel post);

  Future<List<PostModel>?> getPostsByUserId(String userId);

  Future<void> createPost(String content, File image);

  Future<String?> getPostImageById(String postId);

  // Future<void> deletePost(PostModel post);
  // Future<
  // Future<void> addPostData(AddPostReq addPostReq);

  // Future<void> updatePostData(UpdatePostReq updatePostReq);
}
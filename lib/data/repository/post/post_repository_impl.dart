import 'dart:io';

import 'package:socialapp/data/sources/firestore/firestore_service.dart';
import 'package:socialapp/domain/entities/comment.dart';
import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/domain/repository/post/post_repository.dart';
import 'package:socialapp/service_locator.dart';

class PostRepositoryImpl extends PostRepository {
  @override
  Future<List<PostModel>?>? getPostsData() {
    return serviceLocator.get<FirestoreService>().getPostsData();
  }

  @override
  Future<List<CommentModel>?> getCommentPost(PostModel post) {
    return serviceLocator.get<FirestoreService>().getCommentPost(post);
  }

  @override
  Future<void> createPost(String content, File image) {
    return serviceLocator.get<FirestoreService>().createPost(content, image);
  }

  @override
  Future<List<PostModel>?> getPostsByUserId(String userId){
    return serviceLocator.get<FirestoreService>().getPostsByUserId(userId);
  }

  @override
  Future<String?> getPostImageById(String postId){
    return serviceLocator.get<FirestoreService>().getPostImageById(postId);
  }

  // @override
  // Future<void>
}
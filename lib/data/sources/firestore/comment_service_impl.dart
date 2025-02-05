import 'package:socialapp/utils/import.dart';

abstract class CommentService {
  Future<void> sendComment(String postId, String postOwnerId, String comment);

  Future<int> sendReplyComment(String postId, String postOwnerId,
      String comment, String repliedTo);

  Future<void> removeComment(String postId, String commentId);

  Future<void> removeReplyComment(String postId, String repliedTo,
      int replyOrder);

  Future<List<CommentPostModel>> fetchInitialComments(String postId,
      String sortBy);

  Stream<CommentPostModel?> getCommentStream(String postId);

  Future<List<CommentPostModel>> fetchMoreComments(String postId, String sortBy,
      DocumentSnapshot lastDoc);

  Future<void> syncCommentLikesToFirestore(String postId,
      Map<String, bool> likedCommentsCache);
}

class CommentServiceImpl extends CommentService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int loadSize = 5;

  bool noMoreNewestComments = false;
  bool noMoreMostLikedComments = false;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  String get currentUserId => currentUser?.uid ?? '';

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference _commentPostsRef(String postId) {
    return _postRef.doc(postId).collection('comments');
  }

  // ToDo: Service Functions
  @override
  Future<void> sendComment(String postId, String postOwnerId,
      String comment) async {
    if (comment
        .trim()
        .isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      await _commentPostsRef(postId).add(CommentPostModel.newComment(
        content: comment,
        userId: currentUser?.uid,
        priorityRank: (currentUser?.uid != postOwnerId) ? 1 : 0,
      ).toMap());
      _postRef.doc(postId).update({
        'commentAmount': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error sending comment: $e");
      }
      throw Exception("Failed to send comment");
    }
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final commentDoc = _commentPostsRef(postId).doc(commentId);
      final commentSnapshot = await commentDoc.get();
      if (!commentSnapshot.exists) {
        throw Exception("Comment not found");
      }

      if ((commentSnapshot.data() as Map<String, dynamic>)['userRef'] !=
          _usersRef.doc(user.uid)) {
        throw Exception("You can only delete your own comments");
      }

      await commentDoc.delete();

      await _postRef.doc(postId).update({
        'commentAmount': FieldValue.increment(-1),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error removing comment: $e");
      }
      throw Exception("Failed to remove comment");
    }
  }


  @override
  Future<int> sendReplyComment(String postId, String postOwnerId,
      String comment, String repliedTo) async {
    if (comment
        .trim()
        .isEmpty) return -1;

    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final DocumentReference replyCommentPostRef =
    _commentPostsRef(postId).doc(repliedTo);

    try {
      DocumentSnapshot postSnapshot = await replyCommentPostRef.get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>? ?? {};

      Map<String, dynamic> commentsMap =
          postData['replyComments'] as Map<String, dynamic>? ?? {};

      // Create the reply comment data
      Map<String, dynamic> replyCommentMap =
      ReplyCommentPostModel.newReplyComment(
        content: comment,
        userId: user.uid,
      ).toMap();

      int replyOrder = commentsMap.length;
      commentsMap[replyOrder.toString()] = replyCommentMap;

      // Update the post document with the new comments map
      await replyCommentPostRef.update({'replyComments': commentsMap});

      return replyOrder;
    } catch (e) {
      if (kDebugMode) {
        print("Error sending comment: $e");
      }
      return -1;
    }
  }

  @override
  Future<void> removeReplyComment(String postId, String repliedTo,
      int replyOrder) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final DocumentReference replyCommentPostRef = _commentPostsRef(postId).doc(
        repliedTo);

    try {
      DocumentSnapshot postSnapshot = await replyCommentPostRef.get();
      Map<String, dynamic> postData = postSnapshot.data() as Map<String,
          dynamic>? ?? {};

      Map<String, dynamic> commentsMap = postData['replyComments'] as Map<
          String,
          dynamic>? ?? {};

      if (!commentsMap.containsKey(replyOrder.toString())) {
        throw Exception("Reply comment not found");
      }

      final replyData = commentsMap[replyOrder.toString()];
      if (replyData['userRef'] != _usersRef.doc(user.uid)) {
        throw Exception("You can only delete your own reply");
      }

      commentsMap.remove(replyOrder.toString());

      await replyCommentPostRef.update({'replyComments': commentsMap});
    } catch (e) {
      if (kDebugMode) {
        print("Error removing reply comment: $e");
      }
      throw Exception("Failed to remove reply comment");
    }
  }


  @override
  Future<List<CommentPostModel>> fetchInitialComments(String postId,
      String sortBy) async {
    try {
      noMoreNewestComments = false;
      noMoreMostLikedComments = false;

      Query query = _commentPostsRef(postId).orderBy('priorityRank');

      if (sortBy == "newest") {
        query = query.orderBy('timestamp', descending: true);
      } else if (sortBy == "mostLiked") {
        query = query.orderBy('likesCount', descending: true);
      }

      query = query.limit(5);

      QuerySnapshot querySnapshot = await query.get();

      List<CommentPostModel> comments = [];
      for (var document in querySnapshot.docs) {
        Map<String, dynamic> documentMap =
        document.data() as Map<String, dynamic>;

        DocumentReference userRef = document['userRef'];
        DocumentSnapshot userSnapshot = await userRef.get();

        String username = userSnapshot['name'];
        String userAvatar = userSnapshot['avatar'];

        documentMap['commentId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = username;
        documentMap['userAvatar'] = userAvatar;
        documentMap['documentSnapshot'] = document;

        // Handle replyComments asynchronously
        var replyComments = <String, ReplyCommentPostModel>{};
        for (var key
        in (documentMap['replyComments'] as Map<String, dynamic>).keys) {
          Map<String, dynamic> replyData = documentMap['replyComments'][key];
          DocumentReference replyUserRef = replyData['userRef'];
          DocumentSnapshot replyUserSnapshot = await replyUserRef.get();

          replyData['order'] = key;
          replyData['userId'] = replyUserRef.id;
          replyData['username'] = replyUserSnapshot['name'];
          replyData['userAvatar'] = replyUserSnapshot['avatar'];
          replyComments[key] = ReplyCommentPostModel.fromMap(replyData);
        }

        documentMap['replyComments'] = replyComments;

        CommentPostModel parentComment = CommentPostModel.fromMap(documentMap);

        comments.add(parentComment);
      }

      return comments;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching comments: $error');
      }
      throw Exception('Failed to fetch comments');
    }
  }

  @override
  Stream<CommentPostModel?> getCommentStream(String postId) {
      return _commentPostsRef(postId)
          .orderBy('priorityRank')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          var document = snapshot.docs.first;

          Map<String, dynamic> documentMap =
          document.data() as Map<String, dynamic>;

          DocumentReference userRef = document['userRef'];
          DocumentSnapshot userSnapshot = await userRef.get();

          String username = userSnapshot['name'];
          String userAvatar = userSnapshot['avatar'];

          documentMap['commentId'] = document.id;
          documentMap['userId'] = userRef.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['documentSnapshot'] = document;

          // Handle replyComments asynchronously
          var replyComments = <String, ReplyCommentPostModel>{};
          for (var key
          in (documentMap['replyComments'] as Map<String, dynamic>).keys) {
            Map<String, dynamic> replyData = documentMap['replyComments'][key];
            DocumentReference replyUserRef = replyData['userRef'];
            DocumentSnapshot replyUserSnapshot = await replyUserRef.get();

            replyData['order'] = key;
            replyData['userId'] = replyUserRef.id;
            replyData['username'] = replyUserSnapshot['name'];
            replyData['userAvatar'] = replyUserSnapshot['avatar'];
            replyComments[key] = ReplyCommentPostModel.fromMap(replyData);
          }

          documentMap['replyComments'] = replyComments;

          return CommentPostModel.fromMap(documentMap);
        }
        if (kDebugMode) {
          print('Error fetching comments: No new comments found');
        }
        return null;
      });

  }

  @override
  Future<List<CommentPostModel>> fetchMoreComments(String postId, String sortBy,
      DocumentSnapshot lastDoc) async {
    try {
      if (sortBy == "newest" && noMoreNewestComments) {
        throw 'no-more-newest-comments';
      } else if (sortBy == "mostLiked" && noMoreMostLikedComments) {
        throw 'no-more-most-liked-comments';
      }
      Query query = _commentPostsRef(postId).orderBy('priorityRank');

      if (sortBy == "newest") {
        query = query.orderBy('timestamp', descending: true);
      } else if (sortBy == "mostLiked") {
        query = query.orderBy('likesCount', descending: true);
      }

      query = query.startAfterDocument(lastDoc).limit(5);

      QuerySnapshot querySnapshot = await query.get();

      List<CommentPostModel> comments = [];
      for (var document in querySnapshot.docs) {
        Map<String, dynamic> documentMap =
        document.data() as Map<String, dynamic>;

        DocumentReference userRef = document['userRef'];
        DocumentSnapshot userSnapshot = await userRef.get();

        documentMap['commentId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = userSnapshot['name'];
        documentMap['userAvatar'] = userSnapshot['avatar'];
        documentMap['documentSnapshot'] = document;

        // Handle replyComments asynchronously
        var replyComments = <String, ReplyCommentPostModel>{};
        for (var key
        in (documentMap['replyComments'] as Map<String, dynamic>).keys) {
          Map<String, dynamic> replyData = documentMap['replyComments'][key];
          DocumentReference replyUserRef = replyData['userRef'];
          DocumentSnapshot replyUserSnapshot = await replyUserRef.get();

          replyData['order'] = key;
          replyData['userId'] = replyUserRef.id;
          replyData['username'] = replyUserSnapshot['name'];
          replyData['userAvatar'] = replyUserSnapshot['avatar'];
          replyComments[key] = ReplyCommentPostModel.fromMap(replyData);
        }

        documentMap['replyComments'] = replyComments;

        comments.add(CommentPostModel.fromMap(documentMap));
      }

      if (comments.length < loadSize) {
        if (sortBy == "newest") {
          noMoreNewestComments = true;
        } else {
          noMoreMostLikedComments = true;
        }
      }

      return comments;
    } catch (error) {
      if (error.toString() == 'no-more-newest-comments') {
        rethrow;
      } else if (error.toString() == 'no-more-most-liked-comments') {
        rethrow;
      }
      if (kDebugMode) {
        print('Error fetching more comments: $error');
      }
      throw Exception('Failed to fetch more comments');
    }
  }

  @override
  Future<void> syncCommentLikesToFirestore(String postId,
      Map<String, bool> likedCommentsCache) async {
    if (likedCommentsCache.isEmpty) {
      // if (kDebugMode) {
      //   print('No likes to sync.');
      // }
      return;
    }

    WriteBatch batch = _firestoreDB.batch();
    String userId = currentUserId;

    try {
      List<Future<void>> operations = [];

      likedCommentsCache.forEach((commentId, isLiked) {
        operations.add(() async {
          final DocumentReference commentRef =
          _commentPostsRef(postId).doc(commentId);
          DocumentSnapshot commentSnapshot = await commentRef.get();
          if (!commentSnapshot.exists) {
            return;
          }

          Map<String, dynamic> commentData =
          commentSnapshot.data() as Map<String, dynamic>;

          List<dynamic> currentLikes = commentData['likes'] ?? [];

          // Determine if an update is needed
          bool isAlreadyLiked = currentLikes.contains(userId);
          if (isLiked == isAlreadyLiked) {
            return;
          }

          if (isLiked) {
            batch.update(commentRef, {
              'likes': FieldValue.arrayUnion([userId]),
              'likesCount': FieldValue.increment(1),
            });
          } else {
            batch.update(commentRef, {
              'likes': FieldValue.arrayRemove([userId]),
              'likesCount': FieldValue.increment(-1),
            });
          }
        }());
      });

      // Wait for all operations to complete before committing the batch
      await Future.wait(operations);

      // Commit the batch after all operations are prepared
      await batch.commit();
      if (kDebugMode) {
        print('Likes synced to Firestore successfully.');
      }
      likedCommentsCache.clear(); // Clear the cache after successful sync
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing likes: $e');
      }
    }
  }
}

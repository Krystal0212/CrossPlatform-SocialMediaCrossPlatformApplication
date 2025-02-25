import 'package:socialapp/utils/import.dart';

abstract class CommentService {
  Future<void> sendComment(String postId, String postOwnerId, String comment);

  Future<int> sendReplyComment(String postId, String postOwnerId,
      String comment, String repliedTo);

  Future<void> removeComment(String postId, String commentId);

  Future<void> removeReplyComment(String postId, String repliedTo,
      int replyOrder);

  Stream<List<CommentPostModel>> getCommentsStream(String postId, String sortBy);

  Future<void> syncCommentLikesToFirestore(String postId,
      Map<String, bool> likedCommentsCache);
}

class CommentServiceImpl extends CommentService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  String get currentUserId => currentUser?.uid ?? '';

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  CollectionReference _commentPostsRef(String postId) {
    return _postRef.doc(postId).collection('comments');
  }

  // ToDo: Service Functions

  Future<void> _sendPostInteractionNotification(
      String receiverId, NotificationType type, String postId) async {
    try {
      CollectionReference notificationsRef =
      _notificationRef.doc(receiverId).collection('notifications');

      // Check if the document exists
      DocumentReference userNotificationsRef = _notificationRef.doc(receiverId);
      DocumentSnapshot userDocSnapshot = await userNotificationsRef.get();

      // If document doesn't exist, create it
      if (!userDocSnapshot.exists) {
        await userNotificationsRef.set({
          'list': []
        });
      }

      // Calculate the timestamp for 15 minutes ago
      Timestamp fifteenMinutesAgo = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch - (15 * 60 * 1000));

      // Query for existing notifications with the same fromUserRef and postId in the last 15 minutes
      QuerySnapshot querySnapshot = await notificationsRef
          .where('fromUserRef', isEqualTo: _usersRef.doc(currentUserId))
          .where('postId', isEqualTo: postId)
          .where('timestamp', isGreaterThan: fifteenMinutesAgo) // Check last 15 min
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Create a new notification
      NotificationModel newNotification = NotificationModel.newNotification(
        type: type.name,
        fromUserRef: _usersRef.doc(currentUserId),
        toUserId: receiverId,
        postId: postId,  // Assuming post.id exists in your model
        timestamp: Timestamp.now(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        // Overwrite the latest notification for the same fromUserRef and postId
        await querySnapshot.docs.first.reference.set(newNotification.toMap());
      } else {
        // Add a new notification if no recent one exists
        await notificationsRef.add(newNotification.toMap());
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during sending comment notification: $error');
      }
    }
  }

  Future<void> _sendReplyInteractionPostNotification(
      String userToRepliedId, NotificationType type, String postId) async {
    try {
      CollectionReference notificationsRef =
      _notificationRef.doc(userToRepliedId).collection('notifications');

      // Check if the document exists
      DocumentReference userNotificationsRef = _notificationRef.doc(userToRepliedId);
      DocumentSnapshot userDocSnapshot = await userNotificationsRef.get();

      // If document doesn't exist, create it
      if (!userDocSnapshot.exists) {
        await userNotificationsRef.set({
          'list': []  // Initialize with an empty list or necessary default data
        });
      }

      // Calculate the timestamp for 15 minutes ago
      Timestamp fifteenMinutesAgo = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch - (15 * 60 * 1000));

      // Query for existing notifications with the same fromUserRef and postId in the last 15 minutes
      QuerySnapshot querySnapshot = await notificationsRef
          .where('fromUserRef', isEqualTo: _usersRef.doc(currentUserId))
          .where('postId', isEqualTo: postId)
          .where('timestamp', isGreaterThan: fifteenMinutesAgo) // Check last 15 min
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Create a new notification
      NotificationModel newNotification = NotificationModel.newNotification(
        type: type.name,
        fromUserRef: _usersRef.doc(currentUserId),
        toUserId: userToRepliedId,
        postId: postId,  // Assuming post.id exists in your model
        timestamp: Timestamp.now(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        // Overwrite the latest notification for the same fromUserRef and postId
        await querySnapshot.docs.first.reference.set(newNotification.toMap());
      } else {
        // Add a new notification if no recent one exists
        await notificationsRef.add(newNotification.toMap());
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during sending reply comment notification: $error');
      }
    }
  }

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

      int topicScoreChange = 4;

      DocumentReference userRef = _usersRef.doc(user.uid);
      DocumentReference? topicRankBoardRef = await userRef.get().then(
              (snapshot) => snapshot.exists
              ? snapshot.get('topicRankBoardRef') as DocumentReference?
              : null);

      if (topicRankBoardRef == null) {
        throw Exception("User does not have a topicRankBoardRef");
      }

      DocumentSnapshot topicRankBoardSnapshot = await topicRankBoardRef.get();
      Map<String, dynamic> rank = topicRankBoardSnapshot.exists
          ? Map.from(topicRankBoardSnapshot['rank'])
          : {};

      DocumentReference postRef = _postRef.doc(postId);
      DocumentSnapshot postSnapshot = await postRef.get();

      List<DocumentReference> topicRefs =
      List.from(postSnapshot['topicRefs']);

      for (DocumentReference topicRef in topicRefs) {
        String topicId = topicRef.id;

        // Update rank values
        rank[topicId] = (rank[topicId] ?? 0) + topicScoreChange ;
      }

      await topicRankBoardRef.update({'rank': rank});

      await _sendPostInteractionNotification(postOwnerId, NotificationType.comment, postId);
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

      DocumentReference replyUserRef = postData['userRef'];

      await _sendReplyInteractionPostNotification(replyUserRef.id, NotificationType.commentReply, postId);

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
  Stream<List<CommentPostModel>> getCommentsStream(String postId, String sortBy) {
    Query query = _commentPostsRef(postId).orderBy('priorityRank', descending: true);

    if (sortBy == "newest") {
      query = query.orderBy('timestamp', descending: true);
    } else if (sortBy == "mostLiked") {
      query = query
          .orderBy('likesCount', descending: true)
          .orderBy('timestamp', descending: true);
    }

    return query.snapshots().asyncMap((QuerySnapshot snapshot) async {
      List<CommentPostModel> comments = [];

      for (var document in snapshot.docs) {
        Map<String, dynamic> documentMap =
        document.data() as Map<String, dynamic>;

        DocumentReference userRef = document['userRef'];
        DocumentSnapshot userSnapshot = await userRef.get();

        documentMap['commentId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = userSnapshot['name'];
        documentMap['userAvatar'] = userSnapshot['avatar'];
        documentMap['documentSnapshot'] = document;

        // Process reply comments if any.
        var replyComments = <String, ReplyCommentPostModel>{};
        if (documentMap['replyComments'] != null) {
          for (var key
          in (documentMap['replyComments'] as Map<String, dynamic>).keys) {
            Map<String, dynamic> replyData =
            documentMap['replyComments'][key] as Map<String, dynamic>;
            DocumentReference replyUserRef = replyData['userRef'];
            DocumentSnapshot replyUserSnapshot = await replyUserRef.get();

            replyData['order'] = key;
            replyData['userId'] = replyUserRef.id;
            replyData['username'] = replyUserSnapshot['name'];
            replyData['userAvatar'] = replyUserSnapshot['avatar'];
            replyComments[key] = ReplyCommentPostModel.fromMap(replyData);
          }
        }
        documentMap['replyComments'] = replyComments;

        comments.add(CommentPostModel.fromMap(documentMap));
      }
      return comments;
    });
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
            await _sendReplyInteractionPostNotification(
                commentData['userRef'].id, NotificationType.commentLike, postId);
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

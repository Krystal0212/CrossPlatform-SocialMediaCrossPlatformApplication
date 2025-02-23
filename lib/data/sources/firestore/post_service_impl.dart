// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';
import 'package:path/path.dart' as p;
import 'package:universal_html/html.dart' as html;

abstract class PostService {
  Future<List<OnlinePostModel>?> getAssetPostsByUserId(String userId);

  Stream<List<PreviewAssetPostModel>?> getAssetPostsByUserIdRealTime(
      String userId);

  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(String postId);

  Future<List<PreviewSoundPostModel>> getSoundPostsByUserId(String userId);

  Stream<List<PreviewSoundPostModel>?> getSoundPostsByUserIdRealTime(
      String userId);

  Future<PreviewSoundPostModel> getPostSoundsByPostId(String postId);

  Future<List<OnlinePostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false});

  Future<List<OnlinePostModel>> getExplorePostsData(
      {required bool isOffline,
      bool skipLocalFetch = false,
      List<OnlinePostModel>? lastFetchedModels});

  Future<List<OnlinePostModel>> getTrendyPostsData({
    required bool isOffline,
    bool skipLocalFetch = false,
    List<OnlinePostModel>? lastFetchedModels,
  });

  Future<List<OnlinePostModel>> getFollowingPostsData({
    required bool isOffline,
    bool skipLocalFetch = false,
    OnlinePostModel? lastFetchedPost,
  });

  Stream<List<CommentPostModel>> getCommentsOfPost(String postId);

  Future<void> syncLikesToFirestore(Map<String, bool> likedPostsCache);

  Future<void> syncViewsToFirestore(Map<String, bool> viewedPostsCache);

  Future<void> createSoundPost(String content, String filePath);

  Future<OnlinePostModel> getPostDataFromPostId(String postId);

  Future<void> createAssetPost(String content,
      List<Map<String, dynamic>> imagesAndVideos, List<TopicModel> topics);

  Future<OnlinePostModel> getDataFromPostId(String postId);


  Future<List<OnlinePostModel>> searchPost(String query);

  Future<void> reduceTopicRanksOfPostForCurrentUser(String postId);

  Future<void> updatePostContent(String newContent, String postId);

  Future<void> deletePost(String postId);
}

class PostServiceImpl extends PostService
    with ImageAndVideoProcessingHelper, ClassificationMixin {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final CacheManager cacheManager = DefaultCacheManager();
  Connectivity connectivity = Connectivity();
  Set<int> randomIndexes = {};
  Random random = Random();

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  String get currentUserId => currentUser?.uid ?? '';

  CollectionReference get _topicRankBoardRef =>
      _firestoreDB.collection('TopicRankBoard');

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _topicRef => _firestoreDB.collection('Topic');

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  Query<Object?> get _latestPostsQuery =>
      _postRef.orderBy('timestamp', descending: true);

  CollectionReference _usersFollowersRef(String uid) {
    return _usersRef.doc(uid).collection('followers');
  }

  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }

  CollectionReference _usersPostsRef(String uid) {
    return _usersRef.doc(uid).collection('posts');
  }

  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  // ToDo: Offline Service Functions

  // Future<List<OnlinePostModel>> _getLocalPostsData(String tabName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String>? postStrings = prefs.getStringList('offline_${tabName}_posts');
  //
  //   if (postStrings == null) {
  //     return [];
  //   }
  //
  //   List<OnlinePostModel> posts = postStrings.map((postString) {
  //     // Deserialize the string back into a map
  //     Map<String, dynamic> postMap = jsonDecode(postString);
  //     return OnlinePostModel.fromMap(postMap);
  //   }).toList();
  //
  //   return posts;
  // }
  //
  // Future<void> _savePostsLocally(List<OnlinePostModel> posts,
  //     String tabName) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //     // Convert list of posts to JSON string list
  //     List<String> postStrings =
  //     posts.map((post) => jsonEncode(post.toMap())).toList();
  //
  //     await prefs.setStringList('offline_${tabName}_posts', postStrings);
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print('Error saving posts locally: $error');
  //     }
  //   }
  // }

  // ToDo: Service Functions

  Future<List<String>> _fetchSubCollection(
      DocumentSnapshot postDoc, String subCollectionName) async {
    try {
      QuerySnapshot subCollectionSnapshot =
          await postDoc.reference.collection(subCollectionName).get();
      return subCollectionSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching $subCollectionName: $e');
      }
      return [];
    }
  }

  @override
  Future<List<OnlinePostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false}) async {
    List<OnlinePostModel> posts = [];

    try {
      if (isOffline && !skipLocalFetch) {
        // Fetch from local storage when offline
        // posts = await _getLocalPostsData();
      } else {
        // Fetch from Firestore when online
        Query<Object?> postsQuery =
            _postRef.orderBy('timestamp', descending: true);

        AggregateQuerySnapshot aggregateSnapshot =
            await postsQuery.count().get();
        int? count = aggregateSnapshot.count ?? 0;

        if (count == 0) {
          throw CustomFirestoreException(
            code: 'no-posts',
            message: 'No posts exist in Firestore',
          );
        }

        while (randomIndexes.length < 2) {
          randomIndexes.add(random.nextInt(count));
        }
      }
      return posts;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OnlinePostModel>> getExplorePostsData({
    required bool isOffline,
    bool skipLocalFetch = false,
    List<OnlinePostModel>? lastFetchedModels,
  }) async {
    try {
      const int amountOfTopicPostInBatch = 13;
      const int amountOfFollowingPostInBatch = 13;
      int amountOfRandomPostInBatch = (currentUserId.isEmpty) ? 30 : 4;
      bool isNSFWTurnOn = true;

      List<QueryDocumentSnapshot<Object?>> topicPosts = [];
      List<QueryDocumentSnapshot<Object?>> followingPosts = [];
      List<QueryDocumentSnapshot<Object?>> randomPosts = [];

      if (currentUser != null) {
        // Fetch topic posts
        DocumentSnapshot userTopics = await _usersRef.doc(currentUserId).get();
        DocumentSnapshot topicRankBoardSnapshot =
            await userTopics['topicRankBoardRef'].get();
        isNSFWTurnOn = userTopics['isNSFWFilterTurnOn'] ?? true;

        Map<String, String> preferredTopics = {};

        if (topicRankBoardSnapshot.exists) {
          Map<String, dynamic> rank =
              Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

          List<MapEntry<String, int>> sortedTopics = rank.entries
              .map((entry) => MapEntry(entry.key, entry.value as int))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Convert sorted list into preferred-topics (Map<String, String>)
          for (int i = 0; i < 5; i++) {
            preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
          }
        }

        Map<String, String> userTopicRefs = preferredTopics;
        List topicIds = userTopicRefs.values.toList();
        final topicRefs = topicIds.map((id) => _topicRef.doc(id)).toList();

        Query topicQuery = _postRef
            .where('topicRefs', arrayContainsAny: topicRefs)
            .orderBy('timestamp', descending: true)
            .limit(amountOfTopicPostInBatch);

        if (lastFetchedModels != null) {
          topicQuery = topicQuery
              .startAfterDocument(lastFetchedModels.last.documentSnapshot!);
        }

        QuerySnapshot topicPostsQuery = await topicQuery.get();
        topicPosts = topicPostsQuery.docs;

        // Fetch following posts
        QuerySnapshot followingsRef =
            await _usersFollowingsRef(currentUserId).get();
        List<String> followingIds =
            followingsRef.docs.map((doc) => doc.id).toList();
        final userRefs = followingIds.map((id) => _usersRef.doc(id)).toList();

        if (userRefs.isNotEmpty) {
          Query followingQuery = _postRef
              .where('userRef', whereIn: userRefs)
              .orderBy('timestamp', descending: true)
              .limit(amountOfFollowingPostInBatch);

          if (lastFetchedModels != null) {
            followingQuery = followingQuery
                .startAfterDocument(lastFetchedModels.last.documentSnapshot!);
          }

          QuerySnapshot followingPostsQuery = await followingQuery.get();
          followingPosts = followingPostsQuery.docs;
        } else {
          if (kDebugMode) {
            print("No userRefs available, skipping query.");
          }
        }
      }

      // Fetch random posts
      Query randomQuery = _postRef
          .orderBy('timestamp', descending: true)
          .limit(amountOfRandomPostInBatch);

      if (lastFetchedModels != null) {
        randomQuery = randomQuery
            .startAfterDocument(lastFetchedModels.last.documentSnapshot!);
      }

      QuerySnapshot randomPostsQuery = await randomQuery.get();
      randomPosts = randomPostsQuery.docs;

      // Combine and filter unique posts
      final List<QueryDocumentSnapshot<Object?>> allPosts = [
        ...topicPosts,
        ...followingPosts,
        ...randomPosts,
      ];

      if (lastFetchedModels?.length == (await _postRef.count().get()).count) {
        throw CustomFirestoreException(
            code: 'no-more', message: 'No more posts');
      }

      try {
        final Set<String> uniquePostIds = {};
        final List<QueryDocumentSnapshot<Object?>> uniquePosts = [];

        for (var postElement in allPosts) {
          if (!uniquePostIds.contains(postElement.id)) {
            if (lastFetchedModels != null &&
                lastFetchedModels
                    .any((post) => post.postId == postElement.id)) {
              continue;
            } else {
              uniquePostIds.add(postElement.id);
              uniquePosts.add(postElement);
            }
          }
        }

        DocumentReference userRef;
        Future<DocumentSnapshot<Object?>> userData;
        String username = '';
        String userAvatar = '';
        List<String> comments, likes;
        List<OnlinePostModel> newPosts = [];

        for (QueryDocumentSnapshot document in uniquePosts) {
          likes = await _fetchSubCollection(document, 'likes');
          userRef = document['userRef'];
          userData = userRef.get();

          await userData.then((value) {
            username = value['name'];
            userAvatar = value['avatar'];
          });

          Map<String, dynamic> documentMap =
              document.data() as Map<String, dynamic>;

          bool isPostNSFW = false;
          if (documentMap['media'] != null &&
              documentMap['media'] is Map<String, dynamic>) {
            documentMap['media'].forEach((key, value) {
              if (value is Map<String, dynamic> && value['isNSFW'] == true) {
                isPostNSFW = true;
              }
            });
          }

          // Skip the post if it's NSFW and isNSFWTurnOn is true
          if (isPostNSFW && isNSFWTurnOn) {
            continue;
          }

          documentMap['postId'] = document.id;
          documentMap['userId'] = userRef.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['documentSnapshot'] = document;
          documentMap['comments'] = <String>{};
          documentMap['likes'] = likes.toSet();

          OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
          newPosts.add(post);
        }

        return newPosts;
      } catch (error) {
        if (kDebugMode) {
          print('Error during get explore posts: $error');
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during get explore posts for user: $error');
      }
      if (e is CustomFirestoreException &&
          (e as CustomFirestoreException).code == 'no-more') {
        rethrow;
      }
      return [];
    }
  }

  @override
  Future<List<OnlinePostModel>> getTrendyPostsData({
    bool isOffline = false,
    bool skipLocalFetch = false,
    List<OnlinePostModel>? lastFetchedModels,
  }) async {
    try {
      const int postsPerFetch = 30;
      const int amountOfBatch = 30;

      List<OnlinePostModel> posts = [];
      int timeGap = 24 * 7, loopNumber = 1;
      bool hasMorePosts = true;
      DocumentSnapshot? latestPostSnapshot;
      OnlinePostModel? lastFetchedPost;

      DateTime now = DateTime.now();
      DateTime pastTimeWindow = now.subtract(const Duration(hours: 48));
      Timestamp timeAgo = Timestamp.fromDate(pastTimeWindow);

      String oldestPostId = (await _postRef
              .orderBy('timestamp', descending: false)
              .limit(1)
              .snapshots()
              .first)
          .docs
          .first
          .id;

      Query query;

      if (lastFetchedModels != null) {
        if (lastFetchedModels.any((post) => post.postId == oldestPostId)) {
          throw CustomFirestoreException(
              code: 'no-more', message: 'No more posts');
        } else {
          lastFetchedPost = lastFetchedModels.last;
          timeAgo = lastFetchedPost.timestamp;
          Duration gap =
              DateTime.now().difference(lastFetchedPost.timestamp.toDate());
          timeGap += gap.inHours;
          query = _postRef
              .where('timestamp', isGreaterThanOrEqualTo: timeAgo)
              .orderBy('timestamp', descending: true)
              .limit(postsPerFetch);
          query = query.startAfterDocument(lastFetchedPost.documentSnapshot!);
        }
      } else {
        query = _postRef
            .where('timestamp', isGreaterThanOrEqualTo: timeAgo)
            .orderBy('timestamp', descending: true)
            .limit(postsPerFetch);
      }
      QuerySnapshot trendingPostsQuery = await query.get();

      while (posts.length < amountOfBatch && hasMorePosts) {
        try {
          trendingPostsQuery = await query.get();
          final List<QueryDocumentSnapshot> batchProcessingPosts =
              trendingPostsQuery.docs;

          if (batchProcessingPosts.isNotEmpty) {
            List<OnlinePostModel> newestPosts = (await _processTrendingPosts(
              newFetchedPosts: batchProcessingPosts,
              now: now,
              amountOfBatch: amountOfBatch,
              currentPosts: posts,
            ))
                .toList();

            latestPostSnapshot = newestPosts.last.documentSnapshot;
            if (latestPostSnapshot != null &&
                newestPosts.length < amountOfBatch) {
              if (batchProcessingPosts.last.id == oldestPostId &&
                  newestPosts.any((post) => post.postId == oldestPostId)) {
                hasMorePosts = false;
              }
            }
          }

          timeGap = (timeGap * loopNumber++).toInt();
          pastTimeWindow = now.subtract(Duration(hours: timeGap));
          timeAgo = Timestamp.fromDate(pastTimeWindow);

          query = _postRef
              .where('timestamp', isGreaterThanOrEqualTo: timeAgo)
              .orderBy('timestamp', descending: true)
              .limit(postsPerFetch);

          // For empty batch
          if (lastFetchedPost != null) {
            query = query.startAfterDocument(lastFetchedPost.documentSnapshot!);
          }

          // For not empty batch
          if (latestPostSnapshot != null) {
            query = query.startAfterDocument(latestPostSnapshot);
          }
        } catch (e) {
          if (kDebugMode) {
            print("An error occurred: $e");
          }
          break;
        }
      }
      posts.sort((a, b) => b.trendingScore!.compareTo(a.trendingScore!));

      posts = posts.toSet().toList();

      return posts;
    } catch (error) {
      if (e is CustomFirestoreException &&
          (e as CustomFirestoreException).code == 'no-more') {
        rethrow;
      }
      if (kDebugMode) {
        print('Error during get trendy posts for user: $error');
      }
      return [];
    }
  }

  Future<Set<OnlinePostModel>> _processTrendingPosts(
      {required List<QueryDocumentSnapshot> newFetchedPosts,
      required DateTime now,
      required int amountOfBatch,
      required List<OnlinePostModel> currentPosts}) async {
    const double likeWeight = 2.0;
    const double viewWeight = 1.0;
    const double commentWeight = 4.0;
    const double timeDecayFactor = 50.0;

    try {
      bool isNSFWTurnOn = true;
      if (currentUser != null) {
        // Fetch topic posts
        DocumentSnapshot currentUserDocumentSnapshot = await _usersRef.doc(currentUserId).get();
        isNSFWTurnOn = currentUserDocumentSnapshot['isNSFWFilterTurnOn'];
      }

      List<Map<String, dynamic>> postDataList = [];

      for (QueryDocumentSnapshot postDoc in newFetchedPosts) {
        Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
        int likeAmount = 0;
        int viewAmount = 0;
        int commentAmount = 0;
        double hoursSincePost = 0;
        try {
          DateTime postTimestamp =
              (postData['timestamp'] as Timestamp).toDate();

          hoursSincePost = now.difference(postTimestamp).inSeconds / 3600.0;

          likeAmount = postData['likeAmount'] ?? 0;
          viewAmount = postData['viewAmount'] ?? 0;
          commentAmount = postData['commentAmount'] ?? 0;

          bool isPostNSFW = false;
          if (postData['media'] != null &&
              postData['media'] is Map<String, dynamic>) {
            postData['media'].forEach((key, value) {
              if (value is Map<String, dynamic> && value['isNSFW'] == true) {
                isPostNSFW = true;
              }
            });
          }

          // Skip the post if it's NSFW and isNSFWTurnOn is true
          if (isPostNSFW && isNSFWTurnOn) {
            continue;
          }
        } catch (error) {
          if (kDebugMode) {
            print("Error in processing post data: $error");
          }
        }
        try {
          List<String> likes = await _fetchSubCollection(postDoc, 'likes');
          DocumentReference userRef = postData['userRef'];
          DocumentSnapshot userData = await userRef.get();
          String username = userData['name'] ?? '';
          String userAvatar = userData['avatar'] ?? '';

          // Logarithms grow slower than linear functions, reducing the impact of recency over time.
          double trendScore = (likeAmount * likeWeight) +
              (viewAmount * viewWeight) +
              (commentAmount * commentWeight) +
              (timeDecayFactor / (1 + log(1 + hoursSincePost)));

          postData['postId'] = postDoc.id;
          postData['userId'] = userRef.id;
          postData['username'] = username;
          postData['userAvatar'] = userAvatar;
          postData['comments'] = <String>{};
          postData['likes'] = likes.toSet();
          postData['trendingScore'] = trendScore;
          postData['documentSnapshot'] = postDoc;

          postDataList.add(postData);
        } catch (e) {
          if (kDebugMode) {
            print("Error in fetching user data: $e");
          }
        }
      }

      int postsToTake = (postDataList.length < amountOfBatch)
          ? postDataList.length
          : amountOfBatch - currentPosts.length;
      List<OnlinePostModel> newPosts = postDataList
          .sublist(0, postsToTake)
          .map((postData) => OnlinePostModel.fromMap(postData))
          .toList();

      currentPosts.addAll(newPosts);

      return currentPosts.toSet();
    } catch (error) {
      if (kDebugMode) {
        print('Error during process trending posts: $error');
      }
      return {};
    }
  }

  @override
  Future<List<OnlinePostModel>> getFollowingPostsData(
      {bool isOffline = false,
      bool skipLocalFetch = false,
      OnlinePostModel? lastFetchedPost}) async {
    try {
      List<QueryDocumentSnapshot<Object?>> topicPosts = [];
      List<QueryDocumentSnapshot<Object?>> followingPosts = [];
      const int amountOfBatch = 30;
      bool isNSFWTurnOn = true;

      if (currentUser != null) {
        QuerySnapshot followingsRef =
            await _usersFollowingsRef(currentUserId).get();
        DocumentSnapshot userTopics = await _usersRef.doc(currentUserId).get();
        isNSFWTurnOn = userTopics['isNSFWFilterTurnOn'];

        List<String> followingIds = [];
        if (followingsRef.docs.isNotEmpty) {
          followingIds = followingsRef.docs.map((doc) => doc.id).toList();
        }

        final userRefs = followingIds.map((id) => _usersRef.doc(id)).toList();

        if (userRefs.isNotEmpty) {
          Query followingQuery = _postRef
              .where('userRef', whereIn: userRefs)
              .orderBy('timestamp', descending: true)
              .limit(amountOfBatch);

          if (lastFetchedPost != null) {
            followingQuery = followingQuery
                .startAfterDocument(lastFetchedPost.documentSnapshot!);
          }

          QuerySnapshot followingPostsQuery = await followingQuery.get();
          followingPosts = followingPostsQuery.docs;
        } else {
          if (kDebugMode) {
            print("No userRefs available, skipping query for get following.");
          }
        }
      }

      if (followingPosts.isEmpty) {
        throw CustomFirestoreException(
            code: 'no-more', message: 'No more posts');
      }

      DocumentReference userRef;
      Future<DocumentSnapshot<Object?>> userData;
      String username = '';
      String userAvatar = '';
      List<String> comments, likes;
      List<OnlinePostModel> posts = [];

      for (QueryDocumentSnapshot document in followingPosts) {
        likes = await _fetchSubCollection(document, 'likes');
        userRef = document['userRef'];
        userData = userRef.get();

        await userData.then((value) {
          username = value['name'];
          userAvatar = value['avatar'];
        });

        Map<String, dynamic> documentMap =
            document.data() as Map<String, dynamic>;

        bool isPostNSFW = false;
        if (documentMap['media'] != null &&
            documentMap['media'] is Map<String, dynamic>) {
          documentMap['media'].forEach((key, value) {
            if (value is Map<String, dynamic> && value['isNSFW'] == true) {
              isPostNSFW = true;
            }
          });
        }

        // Skip the post if it's NSFW and isNSFWTurnOn is true
        if (isPostNSFW && isNSFWTurnOn) {
          continue;
        }

        documentMap['postId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = username;
        documentMap['userAvatar'] = userAvatar;
        documentMap['comments'] = likes.toSet();
        documentMap['likes'] = <String>{};

        OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

        posts.add(post);
      }

      return posts;
    } catch (e) {
      if (kDebugMode) {
        print('Error during get following posts for user: $e');
      }
      if (e is CustomFirestoreException && e.code == 'no-more') {
        rethrow;
      }
      return [];
    }
  }

  Future<File> _downloadAndSaveLocalImage(String url) async {
    Uri uri = Uri.parse(url);
    String cleanedUrl = uri.origin + uri.path;

    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/${cleanedUrl.split('/').last}');

    final downloadFile = await cacheManager.getSingleFile(url);

    // Save the downloaded file to a local file
    await downloadFile.copy(file.path);

    return file;
  }

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
        await userNotificationsRef.set({'list': []});
      }

      Timestamp fifteenMinutesAgo = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch - (15 * 60 * 1000));

      QuerySnapshot querySnapshot = await notificationsRef
          .where('fromUserRef', isEqualTo: _usersRef.doc(currentUserId))
          .where('postId', isEqualTo: postId)
          .where('timestamp',
              isGreaterThan: fifteenMinutesAgo) // Check last 15 min
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      NotificationModel newNotification = NotificationModel.newNotification(
        type: type.name,
        fromUserRef: _usersRef.doc(currentUserId),
        toUserId: receiverId,
        postId: postId,
        timestamp: Timestamp.now(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.set(newNotification.toMap());
      } else {
        await notificationsRef.add(newNotification.toMap());
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during sending notification: $error');
      }
    }
  }

  bool isLikeSyncing = false;

  @override
  Future<void> syncLikesToFirestore(Map<String, bool> likedPostsCache) async {
    if (likedPostsCache.isEmpty || isLikeSyncing) {
      return;
    }

    WriteBatch batch = _firestoreDB.batch();
    isLikeSyncing = true;

    try {
      String userId = currentUserId;
      int topicScoreChange = 2;

      DocumentReference userRef = _usersRef.doc(userId);
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

      // Iterate over liked posts and update rank map
      for (var entry in likedPostsCache.entries) {
        String postId = entry.key;
        bool isLiked = entry.value;

        DocumentReference postRef = _postRef.doc(postId);
        DocumentSnapshot postSnapshot = await postRef.get();

        if (!postSnapshot.exists) continue;

        List<DocumentReference> topicRefs =
            List.from(postSnapshot['topicRefs']);

        for (DocumentReference topicRef in topicRefs) {
          String topicId = topicRef.id;

          // Update rank values
          rank[topicId] = (rank[topicId] ?? 0) +
              (isLiked ? topicScoreChange : -topicScoreChange);
        }

        // Like system updates
        DocumentReference likeRef = postRef.collection('likes').doc(userId);
        DocumentSnapshot likeSnapshot = await likeRef.get();
        String receiverId = postSnapshot['userRef'].id;

        if (isLiked) {
          if (!likeSnapshot.exists) {
            batch.set(likeRef, {'userId': userId});
            batch.update(postRef, {
              'likeAmount': FieldValue.increment(1),
            });
            await _sendPostInteractionNotification(
              receiverId,
              NotificationType.like,
              postId,
            );
          }
        } else {
          if (likeSnapshot.exists) {
            batch.delete(likeRef);
            batch.update(postRef, {
              'likeAmount': FieldValue.increment(-1),
            });
          }
        }
      }

      // Update Firestore with accumulated rank changes **only once**
      batch.update(topicRankBoardRef, {'rank': rank});

      // Commit batch updates
      await batch.commit();

      if (kDebugMode) {
        print('Likes synced to Firestore successfully.');
      }

      likedPostsCache.clear(); // Clear the cache after successful sync
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing likes: $e');
      }
    } finally {
      isLikeSyncing = false;
    }
  }

  bool isViewSyncing = false;

  @override
  Future<void> syncViewsToFirestore(Map<String, bool> viewedPostsCache) async {
    if (viewedPostsCache.isEmpty || isViewSyncing) {
      return;
    }

    WriteBatch batch = _firestoreDB.batch();
    isViewSyncing = true;

    try {
      String userId = currentUserId;
      int topicScoreChange = 1;

      if (userId.isEmpty) return;

      DocumentReference userRef = _usersRef.doc(userId);
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

      for (var entry in viewedPostsCache.entries) {
        String postId = entry.key;

        DocumentReference postRef = _postRef.doc(postId);
        DocumentSnapshot postSnapshot = await postRef.get();

        if (!postSnapshot.exists) continue;

        List<DocumentReference> topicRefs =
        List.from(postSnapshot['topicRefs']);

        for (DocumentReference topicRef in topicRefs) {
          String topicId = topicRef.id;

          // Update rank values
          rank[topicId] = (rank[topicId] ?? 0) + topicScoreChange;
        }

        batch.update(postRef, {
          'viewAmount': FieldValue.increment(1),
        });
      }

      // Update Firestore with accumulated rank changes **only once**
      batch.update(topicRankBoardRef, {'rank': rank});

      // Commit batch updates
      await batch.commit();

      if (kDebugMode) {
        print('Views synced to Firestore successfully.');
      }

      viewedPostsCache.clear();
    } catch (error) {
      if (kDebugMode) {
        print('Error adding view count: $error');
      }
    } finally {
      isViewSyncing = false;
    }
  }


  @override
  Future<List<OnlinePostModel>?> getAssetPostsByUserId(String userId) async {
    List<OnlinePostModel> posts = [];

    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';
    List<String> comments, likes;

    try {
      QuerySnapshot postsSnapshot = await _usersPostsRef(userId).get();

      if (postsSnapshot.docs.isEmpty) {
        return [];
      }

      List<String> postIds = postsSnapshot.docs.map((doc) => doc.id).toList();

      for (var postId in postIds) {
        DocumentSnapshot document = await _postRef.doc(postId).get();
        comments = await _fetchSubCollection(document, 'comments');
        likes = await _fetchSubCollection(document, 'likes');

        Map<String, dynamic> documentMap =
            document.data() as Map<String, dynamic>;

        if (documentMap['media'] != null) {
          userRef = documentMap['userRef'];
          userData = userRef.get();
          await userData.then((value) {
            username = value['name'];
            userAvatar = value['avatar'];
          });

          documentMap['postId'] = document.id;
          documentMap['userId'] = userRef.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['comments'] = comments.toSet();
          documentMap['likes'] = likes.toSet();

          OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

          posts.add(post);
        }
      }

      return posts;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts for user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<OnlinePostModel> getDataFromPostId(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>;

      if (postData.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist for this user in Firestore',
        );
      }

      List<String> comments =
          await _fetchSubCollection(postSnapshot, 'comments');
      List<String> likes = await _fetchSubCollection(postSnapshot, 'likes');

      DocumentReference userRef = postData['userRef'];
      DocumentSnapshot userData = await userRef.get();
      String username = userData['name'];
      String userAvatar = userData['avatar'];

      postData['postId'] = postSnapshot.id;
      postData['userId'] = userRef.id;
      postData['username'] = username;
      postData['userAvatar'] = userAvatar;
      postData['comments'] = comments.toSet();
      postData['likes'] = likes.toSet();

      OnlinePostModel post = OnlinePostModel.fromMap(postData);

      return post;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching post for user by post id: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<PreviewAssetPostModel>?> getAssetPostsByUserIdRealTime(
      String userId) {
    try {
      // Listen to realtime changes for posts matching the user's reference
      return _usersPostsRef(userId)
          .snapshots()
          .asyncMap((QuerySnapshot userPostsSnapshot) async {
        try {
          if (userPostsSnapshot.docs.isEmpty) {
            return [];
          }

          List<String> postIds =
              userPostsSnapshot.docs.map((doc) => doc.id).toList();

          List<OnlinePostModel> posts = [];

          for (var postId in postIds) {
            DocumentSnapshot document = await _postRef.doc(postId).get();

            List<String> comments =
                await _fetchSubCollection(document, 'comments');
            List<String> likes = await _fetchSubCollection(document, 'likes');

            Map<String, dynamic> documentMap =
                document.data() as Map<String, dynamic>;

            if (documentMap['media'] != null) {
              // Fetch user data from the user reference stored in the document
              DocumentReference userRef = documentMap['userRef'];
              DocumentSnapshot userSnapshot = await userRef.get();
              String username = userSnapshot['name'];
              String userAvatar = userSnapshot['avatar'];

              // Get the document data and add extra fields
              documentMap['postId'] = document.id;
              documentMap['userId'] = userRef.id;
              documentMap['username'] = username;
              documentMap['userAvatar'] = userAvatar;
              documentMap['comments'] = comments.toSet();
              documentMap['likes'] = likes.toSet();

              OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
              posts.add(post);
            }
          }

          List<PreviewAssetPostModel> imageUrls = [];

          for (var post in posts) {
            List<PreviewAssetPostModel> imageUrlsForPost =
                await getPostImagesByPostId(post.postId);
            if (imageUrlsForPost.isNotEmpty) {
              imageUrls.addAll(imageUrlsForPost);
            }
          }

          return imageUrls;
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching posts stream for user - sub step: $e');
          }
          rethrow;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts stream for user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(
      String postId) async {
    try {
      List<PreviewAssetPostModel> imagePreviews = [];
      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();

      Map<String, dynamic>? postData =
          postSnapshot.data() as Map<String, dynamic>?;
      Map<String, dynamic>? medias = postData?['media'];

      if (medias != null) {
        for (var media in medias.entries) {
          if (media.value['type'] == 'image' &&
              media.value['imageUrl'] != null) {
            try {
              imagePreviews.add(PreviewAssetPostModel(
                postId: postId,
                mediasOrThumbnailUrl: media.value['imageUrl'],
                mediaOrder: int.parse(media.key),
                width: (media.value['width'] as num).toDouble(),
                height: (media.value['height'] as num).toDouble(),
                isVideo: false,
                isNSFW: media.value['isNSFW'],
                dominantColor: media.value['dominantColor'],
                videoUrl: null,
              ));
            } catch (error) {
              if (kDebugMode) {
                print('Error getting image preview for post: $error');
              }
            }
          } else if (media.value['type'] == 'video' &&
              media.value['thumbnailUrl'] != null) {
            try {
              imagePreviews.add(PreviewAssetPostModel(
                postId: postId,
                mediasOrThumbnailUrl: media.value['thumbnailUrl'],
                mediaOrder: int.parse(media.key),
                width: (media.value['width'] as num).toDouble(),
                height: (media.value['height'] as num).toDouble(),
                isVideo: true,
                isNSFW: media.value['isNSFW'],
                dominantColor: media.value['dominantColor'],
                videoUrl: media.value['imageUrl'],
              ));
            } catch (error) {
              if (kDebugMode) {
                print('Error getting video preview for post: $error');
              }
            }
          }
        }
      }

      return imagePreviews;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PreviewSoundPostModel>> getSoundPostsByUserId(
      String userId) async {
    try {
      QuerySnapshot postsSnapshot = await _usersPostsRef(userId).get();

      if (postsSnapshot.docs.isEmpty) {
        return [];
      }

      List<String> postIds = postsSnapshot.docs.map((doc) => doc.id).toList();

      List<OnlinePostModel> posts = [];

      for (var postId in postIds) {
        DocumentSnapshot document = await _postRef.doc(postId).get();
        List<String> comments = await _fetchSubCollection(document, 'comments');
        List<String> likes = await _fetchSubCollection(document, 'likes');

        Map<String, dynamic> documentMap =
            document.data() as Map<String, dynamic>;

        if (documentMap['record'] != null) {
          // Fetch user data from the user reference stored in the document
          DocumentReference userRef = document['userRef'];
          DocumentSnapshot userSnapshot = await userRef.get();
          String username = userSnapshot['name'];
          String userAvatar = userSnapshot['avatar'];

          // Get the document data and add extra fields
          documentMap['postId'] = document.id;
          documentMap['userId'] = userRef.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['comments'] = comments.toSet();
          documentMap['likes'] = likes.toSet();

          OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
          posts.add(post);
        }
      }

      List<PreviewSoundPostModel> soundUrls = [];

      // Fetch sound URLs for each post
      for (OnlinePostModel post in posts) {
        try {
          PreviewSoundPostModel soundUrlsForPost =
              await getPostSoundsByPostId(post.postId);
          soundUrls.add(soundUrlsForPost);
        } catch (error) {
          if (error is CustomFirestoreException && error.code == 'no-sound') {
            continue; // Skip posts without sound
          } else {
            rethrow; // Rethrow unexpected errors
          }
        }
      }

      return soundUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts for user: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<PreviewSoundPostModel>?> getSoundPostsByUserIdRealTime(
      String userId) {
    try {
      // Listen to realtime changes for posts matching the user's reference
      return _usersPostsRef(userId)
          .snapshots()
          .asyncMap((QuerySnapshot userPostsSnapshot) async {
        try {
          if (userPostsSnapshot.docs.isEmpty) {
            return [];
          }

          List<String> postIds =
              userPostsSnapshot.docs.map((doc) => doc.id).toList();

          List<OnlinePostModel> posts = [];

          for (var postId in postIds) {
            DocumentSnapshot document = await _postRef.doc(postId).get();

            List<String> comments =
                await _fetchSubCollection(document, 'comments');
            List<String> likes = await _fetchSubCollection(document, 'likes');
            Map<String, dynamic> documentMap =
                document.data() as Map<String, dynamic>;

            if (documentMap['record'] != null) {
              // Fetch user data from the user reference stored in the document
              DocumentReference userRef = documentMap['userRef'];
              DocumentSnapshot userSnapshot = await userRef.get();
              String username = userSnapshot['name'];
              String userAvatar = userSnapshot['avatar'];

              // Get the document data and add extra fields
              documentMap['postId'] = document.id;
              documentMap['userId'] = userRef.id;
              documentMap['username'] = username;
              documentMap['userAvatar'] = userAvatar;
              documentMap['comments'] = comments.toSet();
              documentMap['likes'] = likes.toSet();

              OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
              posts.add(post);
            }
          }

          List<PreviewSoundPostModel> soundUrls = [];

          for (var post in posts) {
            try {
              PreviewSoundPostModel soundUrlsForPost =
                  await getPostSoundsByPostId(post.postId);

              soundUrls.add(soundUrlsForPost);
            } catch (error) {
              if (error is CustomFirestoreException &&
                  error.code == 'no-sound') {
                continue;
              } else {
                rethrow;
              }
            }
          }

          return soundUrls;
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching sound posts stream for user - sub step: $e');
          }
          rethrow;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching sound posts stream for user: $error');
      }
      rethrow;
    }
  }

  @override
  Future<PreviewSoundPostModel> getPostSoundsByPostId(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();

      Map<String, dynamic>? postData =
          postSnapshot.data() as Map<String, dynamic>?;
      String? recordUrl = postData?['record'];

      if (recordUrl != null && recordUrl.isNotEmpty) {
        PreviewSoundPostModel soundUrl = PreviewSoundPostModel(
          postId: postId,
          recordUrl: recordUrl,
        );

        return soundUrl;
      } else {
        throw CustomFirestoreException(
          code: 'no-sound',
          message: 'No sound found for this post',
        );
      }
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-sound') {
        rethrow;
      }
      if (kDebugMode) {
        print('Error getting sound url for post: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<CommentPostModel>> getCommentsOfPost(String postId) {
    return _postRef.doc(postId).collection('comments').snapshots().asyncMap(
      (QuerySnapshot commentListSnapshot) async {
        if (commentListSnapshot.docs.isEmpty) {
          throw CustomFirestoreException(
            code: 'no-comments',
            message: 'Not any comments yet',
          );
        }

        List<CommentPostModel> comments = [];
        for (var document in commentListSnapshot.docs) {
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

          // Convert to CommentPostModel and add to list
          comments.add(CommentPostModel.fromMap(documentMap));
        }
        return comments;
      },
    );
  }

  Future<String> _uploadImageAndGetUrl(Uint8List compressedImage,
      DocumentReference newPostRef, String mediaKey) async {
    final storageRef =
        _storage.ref().child('posts/${newPostRef.id}/$mediaKey.webp');

    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/webp');

    await storageRef.putData(compressedImage, metadata);

    String imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  Future<String> _uploadVideoAndGetUrl(Uint8List videoData,
      DocumentReference newPostRef, String mediaKey) async {
    final storageRef =
        _storage.ref().child('posts/${newPostRef.id}/$mediaKey.webm');

    final SettableMetadata metadata =
        SettableMetadata(contentType: 'video/mp4');

    await storageRef.putData(videoData, metadata);

    String videoUrl = await storageRef.getDownloadURL();
    return videoUrl;
  }

  @override
  Future<void> createAssetPost(
      String content,
      List<Map<String, dynamic>> imagesAndVideos,
      List<TopicModel> topics) async {
    final Timestamp timestamp = Timestamp.now();
    Map<String, OnlineMediaItem> mediaMap = {};
    List<String> mediaKeys = [];

    try {
      NewPostModel newPost = NewPostModel(
          content: content,
          timestamp: timestamp,
          topicRefs: topics
              .map((topics) => _topicRef.doc(topics.topicId))
              .toList()
              .toSet(),
          media: {},
          userRef: _usersRef.doc(currentUserId));

      DocumentReference newPostRef = await _postRef.add(newPost.toMap());

      for (Map<String, dynamic> asset in imagesAndVideos) {
        final String mediaKey = asset['index'].toString();
        mediaKeys.add(mediaKey);

        if (asset['type'] == 'image') {
          Uint8List assetData = asset['data'];
          final String dominantColor =
              await getDominantColorFromImage(assetData);
          final String assetUrl =
              await _uploadImageAndGetUrl(assetData, newPostRef, mediaKey);

          mediaMap[mediaKey] = OnlineMediaItem(
              dominantColor: dominantColor,
              height: asset['height'].toDouble(),
              width: asset['width'].toDouble(),
              type: 'image',
              imageUrl: assetUrl,
              isNSFW: await classifyNSFW(assetData),
              thumbnailUrl: null);

          await newPostRef.update({
            'media.$mediaKey': mediaMap[mediaKey]!.toMap(),
          });
        } else if (asset['type'] == 'video') {
          Uint8List? thumbnailData;
          if (kIsWeb) {
            final blob = html.Blob([asset['data']]);
            final videoUrl = html.Url.createObjectUrlFromBlob(blob);

            thumbnailData = await (await VideoThumbnail.thumbnailFile(
              video: videoUrl, // Use the Blob URL here
              imageFormat: ImageFormat.WEBP,
              maxHeight: 800, // Specify the height of the thumbnail
              quality: 80,
            ))
                .readAsBytes();
          } else {
            try {
              final Directory directory = await getTemporaryDirectory();
              final String filePath = '${directory.path}/temp_file.mp4';

              final file = File(filePath);
              await file.writeAsBytes(asset['data']);
              thumbnailData = await VideoThumbnail.thumbnailData(
                video: filePath,
                imageFormat: ImageFormat.JPEG,
                maxWidth: 1000,
                quality: 50,
              );
            } catch (e) {
              if (kDebugMode) {
                print("Error getting temporary directory: $e");
              }
            }
          }

          if (thumbnailData != null) {
            final String dominantColor = (kIsWeb)
                ? 'ff000000'
                : await getDominantColorFromImage(thumbnailData);
            Uint8List videoData = kIsWeb
                ? asset['data']
                : await compressVideo(asset['data'], asset['index'].toString());

            final String thumbnailUrl = await _uploadImageAndGetUrl(
                thumbnailData, newPostRef, mediaKey);
            final String videoUrl =
                await _uploadVideoAndGetUrl(videoData, newPostRef, mediaKey);

            mediaMap[mediaKey] = OnlineMediaItem(
              dominantColor: dominantColor,
              // Default color for videos
              height: asset['height'].toDouble(),
              width: asset['width'].toDouble(),
              type: 'video',
              imageUrl: videoUrl,
              isNSFW: await classifyNSFW(thumbnailData),
              thumbnailUrl: thumbnailUrl,
            );

            await newPostRef.update({
              'media.$mediaKey': mediaMap[mediaKey]!.toMap(),
            });
          } else {
            throw Exception('Thumbnail data is null');
          }
        }
      }

      // Trigger stream update
      _usersRef
          .doc(currentUserId)
          .collection('posts')
          .doc(newPostRef.id)
          .set({});

    } catch (error) {
      if (kDebugMode) {
        print('Error uploading media: $error');
      }
    }
  }

  Future<String> _uploadSoundAndGetUrl(
      String filePath, DocumentReference newPostRef) async {
    try {
      final storageRef = _storage
          .ref()
          .child('posts/${newPostRef.id}/${p.basename(filePath)}');

      final SettableMetadata metadata =
          SettableMetadata(contentType: "audio/wav");

      await storageRef.putFile(File(filePath), metadata);

      String soundUrl = await storageRef.getDownloadURL();
      return soundUrl;
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading sound: $error');
      }
      rethrow;
    }
  }

  @override
  Future<void> createSoundPost(String content, String filePath) async {
    final Timestamp timestamp = Timestamp.now();

    try {
      NewPostModel newPost = NewPostModel(
          content: content,
          timestamp: timestamp,
          topicRefs: {_topicRef.doc('EvsBU0MQHKWEFrtLzJnn')},
          media: null,
          record: "",
          userRef: _usersRef.doc(currentUserId));

      DocumentReference newPostRef = await _postRef.add(newPost.toMap());

      final String assetUrl = await _uploadSoundAndGetUrl(filePath, newPostRef);

      await newPostRef.update({
        'record': assetUrl,
      });

      await _usersRef
          .doc(currentUserId)
          .collection('posts')
          .doc(newPostRef.id)
          .set({});
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading sound post: $error');
      }
    }
  }

  @override
  Future<List<OnlinePostModel>> searchPost(String query) async {
    List<OnlinePostModel> posts = [];
    try {
      QuerySnapshot snapshot = await _postRef
          .where('contentLowercase',
              isGreaterThanOrEqualTo: query.toLowerCase())
          .limit(20)
          .get();

      bool isNSFWTurnOn = true;

      if (currentUser != null) {
        DocumentSnapshot userTopics = await _usersRef.doc(currentUserId).get();
        isNSFWTurnOn = userTopics['isNSFWFilterTurnOn'];
      }

      for (QueryDocumentSnapshot document in snapshot.docs) {
        Map<String, dynamic> documentMap =
            document.data() as Map<String, dynamic>;

        String content = documentMap['content'] ?? '';
        if (!content.toLowerCase().contains(query.toLowerCase())) {
          continue; // Skip if content does not match
        }

        // Fetch user data
        DocumentReference userRef = document['userRef'];
        var userData = await userRef.get();
        String username = userData['name'];
        String userAvatar = userData['avatar'];

        // Fetch likes
        var likes = await _fetchSubCollection(document, 'likes');

        // Check if post contains NSFW media
        bool isPostNSFW = false;
        if (documentMap['media'] != null &&
            documentMap['media'] is Map<String, dynamic>) {
          documentMap['media'].forEach((key, value) {
            if (value is Map<String, dynamic> && value['isNSFW'] == true) {
              isPostNSFW = true;
            }
          });
        }

        // Skip the post if it's NSFW and user has NSFW filter enabled
        if (isPostNSFW && isNSFWTurnOn) {
          continue;
        }

        // Add additional data to the documentMap
        documentMap['postId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = username;
        documentMap['userAvatar'] = userAvatar;
        documentMap['comments'] = likes.toSet();
        documentMap['likes'] = <String>{};

        // Create a model from the document map and add it to the posts list
        OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
        posts.add(post);
      }

      return posts;
    } catch (error) {
      if (kDebugMode) {
        print('Error finding posts: $error');
      }
      return [];
    }
  }

  @override
  Future<OnlinePostModel> getPostDataFromPostId(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();

      if (!postSnapshot.exists) {
        throw CustomFirestoreException(
            code: 'no-post', message: 'Post does not exist.');
      }

      Map<String, dynamic> documentMap =
          postSnapshot.data() as Map<String, dynamic>;

      List<String> comments =
          await _fetchSubCollection(postSnapshot, 'comments');
      List<String> likes = await _fetchSubCollection(postSnapshot, 'likes');

      DocumentReference userRef = documentMap['userRef'];
      DocumentSnapshot userData = await userRef.get();

      documentMap['postId'] = postSnapshot.id;
      documentMap['userId'] = userRef.id;
      documentMap['username'] = userData['name'];
      documentMap['userAvatar'] = userData['avatar'];
      documentMap['comments'] = comments.toSet();
      documentMap['likes'] = likes.toSet();

      OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

      return post;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting data from postId: $error');
      }
      rethrow;
    }
  }

  @override
  Future<void> reduceTopicRanksOfPostForCurrentUser(String postId) async {
    try {
      if (currentUserId.isEmpty) return;

      int topicScoreChange = 20;

      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();

      Map<String, dynamic>? postData =
          postSnapshot.data() as Map<String, dynamic>?;

      DocumentReference userRef = _usersRef.doc(currentUserId);
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

      List<DocumentReference> topicRefs = List.from(postSnapshot['topicRefs']);

      for (DocumentReference topicRef in topicRefs) {
        String topicId = topicRef.id;
        rank[topicId] = (rank[topicId] ?? 0) - topicScoreChange;
      }

      await topicRankBoardRef.update({'rank': rank});
    } catch (e) {
      if (kDebugMode) {
        print('Error update topic rank for user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updatePostContent(String newContent, String postId) async {
    try {
      DocumentReference postRef = _postRef.doc(postId);

      await postRef.update({
        'content': newContent,
        'contentLowercase': newContent.toLowerCase(),
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error updating post content: $error');
      }
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      if (currentUserId.isEmpty) return;

      await _usersRef
          .doc(currentUserId)
          .collection('posts')
          .doc(postId)
          .delete();

      DocumentReference postRef = _postRef.doc(postId);

      await postRef.delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting post: $error');
      }
    }
  }
}

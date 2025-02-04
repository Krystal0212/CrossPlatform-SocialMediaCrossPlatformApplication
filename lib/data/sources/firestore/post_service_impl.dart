// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:socialapp/utils/import.dart';
import 'package:path/path.dart' as p;
import 'package:universal_html/html.dart' as html;

abstract class PostService {
  Future<List<OnlinePostModel>?> getPostsByUserId(String userId);

  Future<List<PreviewAssetPostModel>> getPostImagesByPostId(String postId);

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

  Future<void> createSoundPost(String content, String filePath);

  Future<void> createAssetPost(String content,
      List<Map<String, dynamic>> imagesAndVideos, List<TopicModel> topics);
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

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _topicRef => _firestoreDB.collection('Topic');

  Query<Object?> get _latestPostsQuery =>
      _postRef.orderBy('timestamp', descending: true);

  CollectionReference _usersFollowersRef(String uid) {
    return _usersRef.doc(uid).collection('followers');
  }

  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }

  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  // ToDo: Global variables
  Set<OnlinePostModel> processedPostModels = {};

  // ToDo: Offline Service Functions

  Future<List<OnlinePostModel>> _getLocalPostsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? postStrings = prefs.getStringList('offline_posts');

    if (postStrings == null) {
      return [];
    }

    List<OnlinePostModel> posts = postStrings.map((postString) {
      // Deserialize the string back into a map
      Map<String, dynamic> postMap = jsonDecode(postString);
      return OnlinePostModel.fromMap(postMap);
    }).toList();

    return posts;
  }

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

  Future<List<OnlinePostModel>> _fetchPostWithSubCollections(
      Set<int> randomIndexes) async {
    List<OnlinePostModel> posts = [];

    try {
      DocumentReference userRef;
      Future<DocumentSnapshot<Object?>> userData;
      String username = '', userAvatar = '';
      List<String> comments, likes;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      for (int randomIndex in randomIndexes) {
        // QuerySnapshot postsSnapshot = await _postRef
        //     .startAtDocument(await _getDocumentAtIndex(randomIndex))
        //     .limit(1)
        //     .get();
        // if (postsSnapshot.docs.isEmpty) {
        //   throw CustomFirestoreException(
        //       code: 'no-post-found', message: 'No post found');
        // }

        // for (QueryDocumentSnapshot document in postsSnapshot.docs) {
        //   comments = await _fetchSubCollection(document, 'comments');
        //   likes = await _fetchSubCollection(document, 'likes');
        //
        //   userRef = document['userRef'];
        //   userData = userRef.get();
        //
        //   await userData.then((value) {
        //     username = value['name'];
        //     userAvatar = value['avatar'];
        //   });
        //
        //   List<Map<String, String>> mediaOffline = [];

        if (!kIsWeb) {
          // for (var item in document['media']) {
          //   String mediaUrl = item['url'];
          //
          //   String? cachedFilePath = prefs.getString(mediaUrl);
          //
          //   if (cachedFilePath == null ||
          //       !File(cachedFilePath).existsSync()) {
          //     File cachedFile = await _downloadAndSaveLocalImage(mediaUrl);
          //     await prefs.setString(mediaUrl, cachedFile.path);
          //     cachedFilePath = cachedFile.path;
          //   }
          //
          //   mediaOffline.add({
          //     'uri': cachedFilePath,
          //     'dominantColor': item['dominantColor'],
          //     'type': item['type'],
          //   });
          // }
        }

        // Map<String, dynamic> documentMap =
        //     document.data() as Map<String, dynamic>;
        //
        // documentMap['postId'] = document.id;
        // documentMap['username'] = username;
        // documentMap['userAvatar'] = userAvatar;
        // documentMap['comments'] = comments.toSet();
        // documentMap['likes'] = likes.toSet();
        //
        // OnlinePostModel post = OnlinePostModel.fromMap(documentMap);
        //
        // posts.add(post);
        // }
      }

      // List<String> postStrings =
      //     posts.map((post) => jsonEncode(post.toMap())).toList();
      // await prefs.setStringList('offline_posts', postStrings);

      return posts;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching post with sub collections: $e');
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
        posts = await _getLocalPostsData();
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

        posts = await _fetchPostWithSubCollections(randomIndexes);
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
      const int amountOfTopicPostInBatch = 9;
      const int amountOfFollowingPostInBatch = 9;
      int amountOfRandomPostInBatch = (currentUserId.isEmpty) ? 20 : 2;

      List<QueryDocumentSnapshot<Object?>> topicPosts = [];
      List<QueryDocumentSnapshot<Object?>> followingPosts = [];
      List<QueryDocumentSnapshot<Object?>> randomPosts = [];

      if (currentUser != null) {
        // Fetch topic posts
        DocumentSnapshot userTopics = await _usersRef.doc(currentUserId).get();
        Map<String, dynamic> userTopicRefs =
            userTopics['preferred-topics'] as Map<String, dynamic>;
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
        print('Error during get posts for user: $error');
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
      const int amountOfBatch = 5;

      List<OnlinePostModel> posts = [];
      int timeGap = 48, loopNumber = 1;
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
        if (lastFetchedModels.any((post) => post.postId == oldestPostId) &&
            processedPostModels.isEmpty) {
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

      if (processedPostModels.isNotEmpty) {
        bool remainingLessPosts =
            (processedPostModels.length - amountOfBatch) < amountOfBatch;
        List<OnlinePostModel> postsToAdd = (!remainingLessPosts)
            ? processedPostModels.take(amountOfBatch).toList()
            : processedPostModels.toList();

        posts.addAll(postsToAdd);

        processedPostModels.removeAll(postsToAdd);
      } else {
        while (posts.length < amountOfBatch && hasMorePosts) {
          try {
            trendingPostsQuery = await query.get();
            final List<QueryDocumentSnapshot> batchProcessingPosts =
                trendingPostsQuery.docs;

            if (batchProcessingPosts.isNotEmpty) {
              List<OnlinePostModel> newestPosts = (await _processTrendingPosts(
                posts: batchProcessingPosts,
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
              query =
                  query.startAfterDocument(lastFetchedPost.documentSnapshot!);
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
      }

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
      {required List<QueryDocumentSnapshot> posts,
      required DateTime now,
      required int amountOfBatch,
      required List<OnlinePostModel> currentPosts}) async {
    const double likeWeight = 2.0;
    const double viewWeight = 1.0;
    const double commentWeight = 4.0;
    const double timeDecayFactor = 50.0;

    try {
      List<Map<String, dynamic>> postDataList = [];

      for (QueryDocumentSnapshot postDoc in posts) {
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

      postDataList
          .sort((a, b) => b['trendingScore']!.compareTo(a['trendingScore']!));

      int postsToTake = (postDataList.length < amountOfBatch)
          ? postDataList.length
          : amountOfBatch - currentPosts.length;
      List<OnlinePostModel> newPosts = postDataList
          .sublist(0, postsToTake)
          .map((postData) => OnlinePostModel.fromMap(postData))
          .toList();

      processedPostModels.addAll(postDataList
          .sublist(postsToTake)
          .map((postData) => OnlinePostModel.fromMap(postData))
          .toList());

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

      if (currentUser != null) {
        QuerySnapshot followingsRef =
            await _usersFollowingsRef(currentUserId).get();
        List<String> followingIds = [];
        if (followingsRef.docs.isNotEmpty) {
          followingIds = followingsRef.docs.map((doc) => doc.id).toList();
        }
        final userRefs = followingIds.map((id) {
          return _usersRef.doc(id);
        }).toList();

        Query query = _postRef
            .where('userRef', whereIn: userRefs)
            .orderBy('timestamp', descending: true)
            .limit(10);
        if (lastFetchedPost != null) {
          query = query.startAfterDocument(lastFetchedPost.documentSnapshot!);
        }
        QuerySnapshot followingPostsQuery = await query.get();

        followingPosts = followingPostsQuery.docs;
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

  @override
  Future<void> syncLikesToFirestore(Map<String, bool> likedPostsCache) async {
    if (likedPostsCache.isEmpty) {
      // if (kDebugMode) {
      //   print('No likes to sync.');
      // }
      return;
    }

    WriteBatch batch = _firestoreDB.batch();

    try {
      List<Future<void>> operations = [];
      String userId = currentUserId;
      int topicScoreChange = 1;

      likedPostsCache.forEach((postId, isLiked) {
        DocumentReference postRef = _postRef.doc(postId);

        operations.add(() async {
          DocumentReference likeRef = postRef.collection('likes').doc(userId);
          DocumentSnapshot likeSnapshot = await likeRef.get();

          DocumentSnapshot postSnapshot = await postRef.get();
          List<DocumentReference> topicRefs =
              List.from(postSnapshot['topicRefs']);

          DocumentReference userRef = _usersRef.doc(userId);
          DocumentReference? topicRankBoardRef = await userRef.get().then(
              (snapshot) => snapshot.exists
                  ? snapshot.get('topicRankBoardRef') as DocumentReference?
                  : null);

          if (topicRankBoardRef == null) {
            throw Exception("User does not have a topicRankBoardRef");
          }

          DocumentSnapshot topicRankBoardSnapshot =
              await topicRankBoardRef.get();
          Map<String, dynamic> rank = topicRankBoardSnapshot.exists
              ? Map.from(topicRankBoardSnapshot['rank'])
              : {};

          // Iterate over topicRefs to update rank map
          for (DocumentReference topicRef in topicRefs) {
            String topicId = topicRef.id;

            rank[topicId] = (rank[topicId] ?? 0) +
                (isLiked ? topicScoreChange : -topicScoreChange);
          }

          batch.update(topicRankBoardRef, {'rank': rank});

          if (isLiked) {
            if (!likeSnapshot.exists) {
              batch.set(likeRef, {'userId': userId});
              batch.update(postRef, {
                'likeAmount': FieldValue.increment(1),
              });
            }
          } else {
            if (likeSnapshot.exists) {
              batch.delete(likeRef);
              batch.update(postRef, {
                'likeAmount': FieldValue.increment(-1),
              });
            }
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
      likedPostsCache.clear(); // Clear the cache after successful sync
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing likes: $e');
      }
    }
  }

  @override
  Future<List<OnlinePostModel>?> getPostsByUserId(String userId) async {
    List<OnlinePostModel> posts = [];

    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';
    List<String> comments, likes;

    try {
      DocumentReference tempUserRef = _usersRef.doc(userId);

      QuerySnapshot postsSnapshot =
          await _postRef.where('userRef', isEqualTo: tempUserRef).get();

      if (postsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist for this user in Firestore',
        );
      }

      for (QueryDocumentSnapshot document in postsSnapshot.docs) {
        comments = await _fetchSubCollection(document, 'comments');
        likes = await _fetchSubCollection(document, 'likes');

        userRef = document['userRef'];
        userData = userRef.get();
        await userData.then((value) {
          username = value['name'];
          userAvatar = value['avatar'];
        });

        Map<String, dynamic> documentMap =
            document.data() as Map<String, dynamic>;

        documentMap['postId'] = document.id;
        documentMap['userId'] = userRef.id;
        documentMap['username'] = username;
        documentMap['userAvatar'] = userAvatar;
        documentMap['comments'] = comments.toSet();
        documentMap['likes'] = likes.toSet();

        OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

        posts.add(post);
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
            imagePreviews.add(PreviewAssetPostModel(
                postId: postId, mediasOrThumbnailUrl: media.value['imageUrl']));
          } else if (media.value['type'] == 'video' &&
              media.value['thumbnailUrl'] != null) {
            imagePreviews.add(PreviewAssetPostModel(
                postId: postId,
                mediasOrThumbnailUrl: media.value['thumbnailUrl']));
          }
        }
      }

      return imagePreviews;
    } catch (e) {
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
          Map<String, dynamic> documentMap = document.data() as Map<String, dynamic>;

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
              final Uint8List thumbnailData =
                  await VideoThumbnail.thumbnailData(
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
            Uint8List videoDate = kIsWeb
                ? asset['data']
                : await compressVideo(asset['data'], asset['index'].toString());

            final String thumbnailUrl = await _uploadImageAndGetUrl(
                thumbnailData, newPostRef, mediaKey);
            final String videoUrl =
                await _uploadVideoAndGetUrl(videoDate, newPostRef, mediaKey);

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
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading media: $error');
      }
    }
  }

  Future<String> _uploadSoundAndGetUrl(
      String filePath, DocumentReference newPostRef) async {
    final storageRef =
        _storage.ref().child('posts/${newPostRef.id}/${p.basename(filePath)}');

    final SettableMetadata metadata =
        SettableMetadata(contentType: "audio/wav");

    await storageRef.putFile(File(filePath), metadata);

    String soundUrl = await storageRef.getDownloadURL();
    return soundUrl;
  }

  @override
  Future<void> createSoundPost(String content, String filePath) async {
    final Timestamp timestamp = Timestamp.now();

    try {
      NewPostModel newPost = NewPostModel(
          content: content,
          timestamp: timestamp,
          topicRefs: null,
          media: {},
          record: "",
          userRef: _usersRef.doc(currentUserId));

      DocumentReference newPostRef = await _postRef.add(newPost.toMap());

      final String assetUrl = await _uploadSoundAndGetUrl(filePath, newPostRef);

      await newPostRef.update({
        'record': assetUrl,
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading sound post: $error');
      }
    }
  }
}

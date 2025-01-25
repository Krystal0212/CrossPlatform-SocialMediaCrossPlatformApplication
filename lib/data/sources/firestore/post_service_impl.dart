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
      {required bool isOffline, bool skipLocalFetch = false});

  Future<List<OnlinePostModel>> loadMorePostsData();

  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post);

  Future<void> syncLikesToFirestore(
      Map<String, Map<String, bool>> likedPostsCache);

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

  Query<Object?> get _postsQuery =>
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
  Future<DocumentSnapshot> _getDocumentAtIndex(int index) async {
    QuerySnapshot snapshot = await _postRef.limit(index + 1).get();
    return snapshot.docs[index];
  }

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
      String username = '';
      String userAvatar = '';
      List<String> comments, likes;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      for (int randomIndex in randomIndexes) {
        QuerySnapshot postsSnapshot = await _postRef
            .startAtDocument(await _getDocumentAtIndex(randomIndex))
            .limit(1)
            .get();
        if (postsSnapshot.docs.isEmpty) {
          throw CustomFirestoreException(
              code: 'no-post-found', message: 'No post found');
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

          List<Map<String, String>> mediaOffline = [];

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

          Map<String, dynamic> documentMap =
              document.data() as Map<String, dynamic>;

          documentMap['postId'] = document.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['comments'] = comments.toSet();
          documentMap['likes'] = likes.toSet();

          OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

          posts.add(post);
        }
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
  Future<List<OnlinePostModel>> getExplorePostsData(
      {required bool isOffline, bool skipLocalFetch = false}) async {
    try {
      List<QueryDocumentSnapshot<Object?>> topicPosts = [];
      List<QueryDocumentSnapshot<Object?>> followingPosts = [];

      if (currentUser != null) {
        DocumentSnapshot userTopics = await _usersRef.doc(currentUserId).get();
        Map<String, dynamic> userTopicRefs =
        userTopics['preferred-topics'] as Map<String, dynamic>;
        List topicIds = userTopicRefs.values.toList();
        final topicRefs = topicIds.map((id) {
          return _topicRef.doc(id);
        }).toList();
        QuerySnapshot topicPostsQuery = await _postRef
            .where('topicRefs', arrayContainsAny: topicRefs)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        topicPosts = topicPostsQuery.docs;


        QuerySnapshot followingsRef =
        await _usersFollowingsRef(currentUserId).get();
        List<String> followingIds = [];
        if (followingsRef.docs.isNotEmpty) {
          followingIds = followingsRef.docs.map((doc) => doc.id).toList();
        }
        final userRefs = followingIds.map((id) {
          return _usersRef.doc(id);
        }).toList();
        final QuerySnapshot followingPostsQuery = await _postRef
            .where('userRef', whereIn: userRefs)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        followingPosts = followingPostsQuery.docs;
      }
      final randomPostsQuery =
          await _postRef.orderBy('timestamp', descending: true).limit(5).get();
      final List<QueryDocumentSnapshot<Object?>> randomPosts =
          randomPostsQuery.docs;

      final List<QueryDocumentSnapshot<Object?>> allPosts = [
        ...topicPosts,
        ...followingPosts,
        ...randomPosts,
      ];

      final Set<String> uniquePostIds = {};
      final List<QueryDocumentSnapshot<Object?>> uniquePosts = [];

      for (var post in allPosts) {
        if (!uniquePostIds.contains(post.id)) {
          uniquePostIds.add(post.id);
          uniquePosts.add(post);
        }
      }

      DocumentReference userRef;
      Future<DocumentSnapshot<Object?>> userData;
      String username = '';
      String userAvatar = '';
      List<String> comments, likes;
      List<OnlinePostModel> posts = [];

      for (QueryDocumentSnapshot document in uniquePosts) {
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
        documentMap['username'] = username;
        documentMap['userAvatar'] = userAvatar;
        documentMap['comments'] = comments.toSet();
        documentMap['likes'] = likes.toSet();

        OnlinePostModel post = OnlinePostModel.fromMap(documentMap);

        posts.add(post);
      }

      return posts;
    } catch (error) {
      if (kDebugMode) {
        print('Error during get posts for user: $error');
      }
      return [];
    }
  }

  @override
  Future<List<OnlinePostModel>> loadMorePostsData() async {
    List<OnlinePostModel> posts = [];

    try {
      AggregateQuerySnapshot aggregateSnapshot =
          await _postsQuery.count().get();
      int? count = aggregateSnapshot.count ?? 0;

      if (count == 0) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist in Firestore',
        );
      }
      Set<int> newRandomIndexes = {};

      if (randomIndexes.length != count) {
        while (newRandomIndexes.length < 2 &&
            randomIndexes.length + newRandomIndexes.length < count) {
          int newIndex = random.nextInt(count);
          if (!randomIndexes.contains(newIndex)) {
            newRandomIndexes.add(newIndex);
          }
        }

        randomIndexes.addAll(newRandomIndexes);
        posts = await _fetchPostWithSubCollections(newRandomIndexes);
      } else {
        throw CustomFirestoreException(
            code: 'no-more', message: 'No more posts');
      }

      return posts;
    } catch (e) {
      rethrow;
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
  Future<void> syncLikesToFirestore(
      Map<String, Map<String, bool>> likedPostsCache) async {
    if (likedPostsCache.isEmpty) {
      // if (kDebugMode) {
      //   print('No likes to sync.');
      // }
      return;
    }

    WriteBatch batch = _firestoreDB.batch();

    try {
      List<Future<void>> operations = [];

      likedPostsCache.forEach((postId, userIdsMap) {
        DocumentReference postRef = _postRef.doc(postId);

        userIdsMap.forEach((userId, isAdded) {
          operations.add(() async {
            DocumentReference likeRef = postRef.collection('likes').doc(userId);
            DocumentSnapshot likeSnapshot = await likeRef.get();

            if (isAdded) {
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
  Future<List<CommentModel>?> getCommentPost(OnlinePostModel post) async {
    if (kDebugMode) {
      print('check');
    }
    List<CommentModel> comments = [];
    DocumentReference commentRef;
    Future<DocumentSnapshot<Object?>> commentData;

    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';

    try {
      QuerySnapshot commentListSnapshot = await _firestoreDB
          .collection('Post')
          .doc(post.postId)
          .collection('comments')
          .get();

      if (kDebugMode) {
        print(commentListSnapshot.docs);
      }
      // Future<Map<String, dynamic>> userData = userRef.get().then((value) => value.data() as Map<String, dynamic>);
      if (commentListSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist in Firestore',
        );
      }
      for (var doc in commentListSnapshot.docs) {
        // print(doc.id);
        // print(doc.data());
        // print(doc['commentRef']);
        commentRef = doc['commentRef'];
        commentData = commentRef.get();
        await commentData.then((comment) {
          if (kDebugMode) {
            print(comment['content']);
          }

          userRef = comment['userRef'];
          userData = userRef.get();

          userData.then((user) {
            username = user['name'];
            userAvatar = user['avatar'];

            CommentModel singleComment = CommentModel(
              commentId: doc.id,
              username: username,
              userAvatar: userAvatar,
              content: comment['content'],
              timestamp: (comment['timestamp'] as Timestamp).toDate(),
              likes: null,
            );

            comments.add(singleComment);
          });
        });
        // commentRef = doc.reference;
        // commentRef = commentListSnapshot
        // print(doc['comments']);
        // for (var comment in doc['comments']) {
        //   print('1');
        //   print(comment);
        //   // commentRef = comment;
        //   // commentData = commentRef.get();
        //   // await commentData.then((comment) {
        //   //   print(comment['content']);
        //   //   print(comment['timestamp']);
        //   //   print(comment['user_id']);
        //   //   userRef = comment['user_id'];
        //   //   userData = userRef.get();
        //   //   userData.then((userSnapshot) {
        //   //     username = userSnapshot['name'];
        //   //     userAvatar = userSnapshot['avatar'];
        //   //   });
        //   // });

        // }
        // userRef = doc['user_id'];
        // userData = userRef.get();
        // await userData.then((value) {
        //   // userInfo = value;
        //   username = value['name'];
        //   userAvatar = value['avatar'];
        // });

        // PostModel post = PostModel(
        //   postId: doc.id,
        //   username: username,
        //   userAvatar: userAvatar,
        //   content: doc['content'],
        //   likeAmount: doc['like_amount'],
        //   commentAmount: doc['comment_amount'],
        //   viewAmount: doc['view_amount'],
        //   image: doc['image'],
        //   timestamp: (doc['timestamp'] as Timestamp).toDate(),
        //   comments: null,
        //   likes: null,
        //   views: null,
        // );
        // // print('post: $post');
        // posts.add(post);
        // topics.add(TopicModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      // print('posts: $posts');
      return comments;
      // return postsSnapshot.docs.map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
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
            ;

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

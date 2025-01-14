import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:socialapp/utils/import.dart';

abstract class PostService {
  Future<List<PostModel>?> getPostsByUserId(String userId);

  Future<void> createPost(String content, File image);

  Future<String?> getPostImageById(String postId);

  Future<List<PostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false});

  Future<List<CommentModel>?> getCommentPost(PostModel post);

  Future<void> syncLikesToFirestore(
      Map<String, Map<String, bool>> likedPostsCache);
}

class PostServiceImpl extends PostService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storage = StorageServiceImpl();
  final CacheManager cacheManager = DefaultCacheManager();
  Connectivity connectivity = Connectivity();

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  // ToDo: Offline Service Functions

  Future<List<PostModel>> _getLocalPostsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? postStrings = prefs.getStringList('offline_posts');

    if (postStrings == null) {
      return [];
    }

    List<PostModel> posts = postStrings.map((postString) {
      // Deserialize the string back into a map
      Map<String, dynamic> postMap = jsonDecode(postString);
      return PostModel.fromMap(postMap);
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

  Future<List<PostModel>> _fetchPostWithSubCollections(Set<int> randomIndexes) async {
    List<PostModel> posts = [];

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
            for (var item in document['media']) {
              String mediaUrl = item['url'];

              String? cachedFilePath = prefs.getString(mediaUrl);

              if (cachedFilePath == null ||
                  !File(cachedFilePath).existsSync()) {
                File cachedFile = await _downloadAndSaveLocalImage(mediaUrl);
                await prefs.setString(mediaUrl, cachedFile.path);
                cachedFilePath = cachedFile.path;
              }

              mediaOffline.add({
                'uri': cachedFilePath,
                'dominantColor': item['dominantColor'],
                'type': item['type'],
              });
            }
          }

          Map<String, dynamic> documentMap =
              document.data() as Map<String, dynamic>;



          documentMap['postId'] = document.id;
          documentMap['username'] = username;
          documentMap['userAvatar'] = userAvatar;
          documentMap['mediaOffline'] = mediaOffline;
          documentMap['comments'] = comments.toSet();
          documentMap['likes'] = likes.toSet();

          print('catch me');

          PostModel post = PostModel.fromMap(documentMap);

          posts.add(post);
        }
      }

      List<String> postStrings =
          posts.map((post) => jsonEncode(post.toMap())).toList();
      await prefs.setStringList('offline_posts', postStrings);

      return posts;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching post with sub collections: $e');
      }
      return [];
    }
  }

  @override
  Future<List<PostModel>> getPostsData(
      {required bool isOffline, bool skipLocalFetch = false}) async {
    List<PostModel> posts = [];

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

        Random random = Random();
        Set<int> randomIndexes = {};

        while (randomIndexes.length < 3) {
          randomIndexes.add(random.nextInt(count));
        }

        posts = await _fetchPostWithSubCollections(randomIndexes);
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
      if (kDebugMode) {
        print('No likes to sync.');
      }
      return;
    }

    WriteBatch batch = _firestoreDB.batch();

    try {
      likedPostsCache.forEach((postId, userIdsMap) {
        DocumentReference postRef = _postRef.doc(postId);

        userIdsMap.forEach((userId, isAdded) async {
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
        });
      });

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
  Future<List<PostModel>?> getPostsByUserId(String userId) async {
    List<PostModel> posts = [];

    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';

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

      for (var doc in postsSnapshot.docs) {
        userRef = doc['userRef'];
        userData = userRef.get();
        await userData.then((value) {
          username = value['name'];
          userAvatar = value['avatar'];
        });

        PostModel post = PostModel(
          postId: doc.id,
          username: username,
          userAvatarUrl: userAvatar,
          content: doc['content'],
          likeAmount: doc['likeAmount'],
          commentAmount: doc['commentAmount'],
          viewAmount: doc['viewAmount'],
          media: (doc['media'] as List<dynamic>).map((item) {
            final mapItem = item as Map<String, dynamic>;
            return mapItem.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          }).toList(),
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          comments: {},
          likes: {},
          topicRefs: (doc['topicRef'] as List<dynamic>)
              .map((item) => item.toString())
              .toList(),
        );

        posts.add(post);
      }

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot> getPostDataById(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postRef.doc(postId).get();

      if (!postSnapshot.exists) {
        throw CustomFirestoreException(
          code: 'post-not-found',
          message: 'Post not found in Firestore',
        );
      }

      return postSnapshot;
    } catch (e) {
      rethrow; // Rethrow the error for further handling
    }
  }

  @override
  Future<String?> getPostImageById(String postId) async {
    try {
      DocumentSnapshot documentSnapshot = await getPostDataById(postId);

      Map<String, dynamic>? postData =
          documentSnapshot.data() as Map<String, dynamic>?;

      return postData?["image"] as String?;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CommentModel>?> getCommentPost(PostModel post) async {
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

  @override
  Future<void> createPost(String content, File image) async {
    String? imageUrl = await _storage.uploadPostImage('Post', image);

    if (kDebugMode) {
      print('imageUrl: $imageUrl');
      print('content: $content');
      // print('image: $image');
      print('currentUser: $currentUser');
    }

    if (imageUrl != null) {
      CollectionReference collectionRef = _firestoreDB.collection('Post');
      collectionRef.add(
        {
          'content': content,
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'likeAmount': 0,
          'commentAmount': 0,
          'viewAmount': 0,
          'userRef': _usersRef.doc(currentUser!.uid),
        },
      );
    }
  }
}

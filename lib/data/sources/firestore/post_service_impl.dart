import 'package:socialapp/utils/import.dart';

abstract class PostService {
  Future<List<PostModel>?> getPostsByUserId(String userId);

  Future<void> createPost(String content, File image);

  Future<String?> getPostImageById(String postId);

  Future<List<PostModel>> getPostsData();

  Future<List<CommentModel>?> getCommentPost(PostModel post);
}

class PostServiceImpl extends PostService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storage = StorageServiceImpl();

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  // ToDo: Service Functions
  @override
  Future<List<PostModel>> getPostsData() async {
    List<PostModel> posts = [];
    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';

    try {

      Query<Object?> postsQuery =
          _postRef.orderBy('timestamp', descending: true);

      AggregateQuerySnapshot aggregateSnapshot = await postsQuery.count().get();
      int? count = aggregateSnapshot.count ?? 0;

      if (count == 0) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist in Firestore',
        );
      }
      QuerySnapshot postsSnapshot = await postsQuery.get();

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
          userAvatar: userAvatar,
          content: doc['content'],
          likeAmount: doc['likeAmount'],
          commentAmount: doc['commentAmount'],
          viewAmount: doc['viewAmount'],
          image: doc['imageUrl'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          comments: null,
          likes: null,
          views: null,
        );
        posts.add(post);
      }
      return posts;
    } catch (e) {
      rethrow;
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
      QuerySnapshot aPostsSnapshot = await _postRef.get();
      String userRefString = "User/$userId";
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
          userAvatar: userAvatar,
          content: doc['content'],
          likeAmount: doc['likeAmount'],
          commentAmount: doc['commentAmount'],
          viewAmount: doc['viewAmount'],
          image: doc['imageUrl'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          comments: null,
          likes: null,
          views: null,
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

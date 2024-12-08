// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:socialapp/domain/entities/collection.dart';
import 'package:socialapp/domain/entities/comment.dart';
import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/domain/entities/topic.dart';
import 'package:socialapp/data/sources/storage/storage_service.dart';
import 'package:socialapp/utils/import.dart';

import '../../../domain/entities/user.dart';
import '../../models/user_firestore/add_user_data.dart';
import '../../models/user_firestore/update_user_req.dart';


abstract class FirestoreService {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  // No need add to repository
  Future<UserModel?> fetchUserData(String userID);

  Future<void> addCurrentUserData(AddUserReq addUserReq);

  Future<void> updateCurrentUserData(UpdateUserReq updateUserReq);

  Future<List<Map<String, String>>> fetchCategoriesData();

  Future<List<String>> getUserFollowers(String uid);

  Future<List<String>> getUserFollowings(String uid);

  Future<List<String>> getUserCollectionIDs(String uid);

  Future<TopicModel?>? getTopicData(String topicID);

  Future<List<TopicModel>?>? getTopicsData();

  Future<List<PostModel>?>? getPostsData();

  Future<List<CommentModel>?> getCommentPost(PostModel post);

  Future<List<CollectionModel>> getCollectionsData(List<String> collectionIDsList);

  Future<List<PostModel>?> getPostsByUserId(String userId);

  Future<void> createPost(String content, File image);

  Future<String?> getPostImageById(String postId);

  Future<List<CollectionModel>?>? getCollections();

  Future<List<String>> getCollectionPostsID(String collectionID);
}

class FirestoreServiceImpl extends FirestoreService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storage = StorageServiceImpl();

  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersCollection => _firestoreDB.collection('User');
  // ToDo : Reference Define
  CollectionReference get _usersRef => _firestoreDB.collection('User');
  CollectionReference _usersFollowersRef(String uid) {
    return _usersRef.doc(uid).collection('followers');
  }
  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }
  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  CollectionReference get _categoryRef => _firestoreDB.collection('Category');

  CollectionReference get _collectionRef => _firestoreDB.collection('Collection');
  CollectionReference _collectionPostsRef(String collectionId) {
    return _collectionRef.doc(collectionId).collection('posts');
  }

  CollectionReference get _categoryCollection => _firestoreDB.collection('Category');
  CollectionReference get _postCollection => _firestoreDB.collection('Post');
  CollectionReference get _postRef => _firestoreDB.collection('Post');


  // ToDo: Service Functions
  @override
  Future<UserModel?> getUserData(String userID) async {
    try {
      return await fetchUserData(userID);
    } on CustomFirestoreException catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      return await fetchUserData(currentUser!.uid);
    } on CustomFirestoreException catch (error) {
      if (error.code == 'new-user') {
        rethrow;
      }
      if (kDebugMode) {
        print("${AppStrings.firestoreUserError} ${error.toString()}");
      }
      return null;
    }
  }

  // No need add to repository
  @override
  Future<UserModel?> fetchUserData(String userID) async {
    try {
      DocumentSnapshot userDoc = await _usersRef.doc(userID).get();

      if (!userDoc.exists) {
        throw CustomFirestoreException(
          code: 'new-user',
          message: 'User data does not exist in Firestore',
        );
      }

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addCurrentUserData(AddUserReq addUserReq) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    Map<String, dynamic> userData = addUserReq.newUserData.toMap();
    await _usersRef
        .doc(currentUser?.uid)
        .set(userData)
        .then((value) => print("User Added"))
        .catchError((error) => print("Error pushing user data: $error"));
  }

  @override
  Future<void> updateCurrentUserData(UpdateUserReq updateUserReq) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    try {
      await _usersRef
          .doc(currentUser?.uid)
          .update(updateUserReq.updatedUserData.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
    }
  }

  @override
  Future<List<String>> getUserFollowers(String uid) async {
    List<String> followers = [];

    QuerySnapshot<Map<String, dynamic>> followersSnapshot =
    await _usersFollowersRef(uid).get() as QuerySnapshot<Map<String, dynamic>>;

    for (var doc in followersSnapshot.docs) {
      followers.add(doc.id);
    }

    return followers;
  }

  @override
  Future<List<String>> getUserFollowings(String uid) async {
    List<String> followings = [];

    QuerySnapshot<Map<String, dynamic>> followingsSnapshot =
        await _usersFollowingsRef(uid).get() as QuerySnapshot<Map<String, dynamic>>;

    for (var doc in followingsSnapshot.docs) {
      followings.add(doc.id);
    }

    return followings;
  }

  @override
  Future<List<String>> getUserCollectionIDs(String uid) async {
    List<String> collections = [];

    QuerySnapshot<Map<String, dynamic>> collectionsSnapshot =
    await _usersCollectionsRef(uid).get() as QuerySnapshot<Map<String, dynamic>>;

    for (var doc in collectionsSnapshot.docs) {
      collections.add(doc.id);
    }

    if (kDebugMode) {
      print(collections.toString());
    }

    return collections;
  }

  //////////////////////////////////////////////////////////////////////////

  @override
  Future<TopicModel?> getTopicData(String topicID) async {
    try {
      DocumentSnapshot topicDoc =
          await _firestoreDB.collection('NewTopic').doc(topicID).get();

      if (!topicDoc.exists) {
        throw CustomFirestoreException(
          code: 'topic-not-exist',
          message: 'Topic data does not exist in Firestore',
        );
      }

      return TopicModel.fromMap(topicDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TopicModel>?>? getTopicsData() async {
    try {
      QuerySnapshot topicsSnapshot =
          await _firestoreDB.collection('NewTopic').get();

      if (topicsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      return topicsSnapshot.docs
          .map((doc) => TopicModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, String>>> fetchCategoriesData() async {
    List<Map<String, String>> categories = [];
    try {
      QuerySnapshot snapshot = await _categoryRef.get();

      for (var doc in snapshot.docs) {
        if (doc.exists) {}
        categories.add({
          'id': doc.id, // Lấy ID của tài liệu
          'name': doc['name'], // Lấy trường 'name'
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error get category list: $e");
      }
    }
    return categories;
  }

  @override
  Future<List<PostModel>?>? getPostsData() async {
    List<PostModel> posts = [];
    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';

    try {
      // QuerySnapshot postsSnapshot = await _postRef.get();
      // Future<Map<String, dynamic>> userData = userRef.get().then((value) => value.data() as Map<String, dynamic>);

      QuerySnapshot postsSnapshot = await _postCollection.orderBy('timestamp', descending: true).get();
      if (postsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-posts',
          message: 'No posts exist in Firestore',
        );
      }

      for (var doc in postsSnapshot.docs) {
        userRef = doc['userRef'];
        userData = userRef.get();

        await userData.then((value) {
          // userInfo = value;
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
          image: doc['image'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          comments: null,
          likes: null,
          views: null,
        );
        // print('post: $post');
        posts.add(post);
        // topics.add(TopicModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      // print('posts: $posts');
      return posts;
      // return postsSnapshot.docs.map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
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

      QuerySnapshot postsSnapshot = await _postRef.where('userRef', isEqualTo: tempUserRef ).get();


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
          image: doc['image'],
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

      Map<String, dynamic>? postData = documentSnapshot.data() as Map<String, dynamic>?;

      return postData?["image"] as String?;
    } catch (e) {
      rethrow;
    }
  }



  @override
  Future<List<CommentModel>?> getCommentPost(PostModel post) async {
    print('check');
    List<CommentModel> comments = [];
    DocumentReference commentRef;
    Future<DocumentSnapshot<Object?>> commentData;

    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userData;
    String username = '';
    String userAvatar = '';

    try {
      QuerySnapshot commentListSnapshot = await _firestoreDB.collection('Post').doc(post.postId).collection('comments').get();
      print('check2');
      print(commentListSnapshot.docs);
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
          print(comment['content']);

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

    print('imageUrl: $imageUrl');
    print('content: $content');
    // print('image: $image');
    print('currentUser: $currentUser');

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

  @override
  Future<List<CollectionModel>?>? getCollections() async {
    List<CollectionModel> collections = [];
    try {
      QuerySnapshot collectionSnapshot = await _firestoreDB.collection('NewCollection').get();

      if (collectionSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      for (var doc in collectionSnapshot.docs) {
        // print(doc.id);
        print('name: ${doc['name']}');
        CollectionModel collection = CollectionModel(
          collectionId: doc.id,
          name: doc['name'],
          thumbnail: doc['thumbnail'],
        );
        collections.add(collection);
      }

      return collections.isEmpty ? null : collections;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsData(List<String> collectionIDsList) async {
    List<CollectionModel> collections = [];

    try {
      for (String collectionID in collectionIDsList) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collectionRef.doc(collectionID).get() as DocumentSnapshot<Map<String, dynamic>>;

        if (snapshot.exists && snapshot.data() != null) {
          CollectionModel collection = CollectionModel.fromMap(snapshot.data()!);
          collections.add(collection);  // Add to list of collections
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching collection data: $e");
      }
    }

    return collections;  // Return the list of CollectionModel objects
  }

  @override
  Future<List<String>> getCollectionPostsID(String collectionID) async {
    List<String> postIDs = [];

    QuerySnapshot<Map<String, dynamic>> followingsSnapshot =
        await _collectionPostsRef(collectionID).get() as QuerySnapshot<Map<String, dynamic>>;

    for (var doc in followingsSnapshot.docs) {
      postIDs.add(doc.id);
    }

    return postIDs;
  }
}

class CustomFirestoreException implements Exception {
  final String code;
  final String message;

  CustomFirestoreException({required this.code, required this.message});

  @override
  String toString() {
    return 'CustomFirestoreException($code): $message';
  }
}


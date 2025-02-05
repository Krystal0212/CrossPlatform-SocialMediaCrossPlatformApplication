import 'package:socialapp/utils/import.dart';

abstract class UserService {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  // No need add to repository
  Future<UserModel?> fetchUserData(String userID);

  Future<void> addCurrentUserData(UserModel addUser);

  Future<void> updateCurrentUserData(UserModel updateUser);

  Future<Map<String, dynamic>> getUserRelatedData(String uid);

  Future<String>? uploadAvatar(File image, String uid);

  Future<void> followOrUnfollowUser(String uid, bool? isFollow);
}

class UserServiceImpl extends UserService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  // ToDo : Reference Define
  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  CollectionReference get _topicRankBoardRef =>
      _firestoreDB.collection('TopicRankBoard');

  CollectionReference _usersFollowersRef(String uid) {
    return _usersRef.doc(uid).collection('followers');
  }

  CollectionReference _usersFollowingsRef(String uid) {
    return _usersRef.doc(uid).collection('followings');
  }

  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  CollectionReference _usersPostRef(String uid) {
    return _usersRef.doc(uid).collection('posts');
  }

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  // ToDo: Service Functions
  @override
  Future<UserModel?> getUserData(String userID) async {
    try {
      return await fetchUserData(userID);
    } on CustomFirestoreException catch (error) {
      if (kDebugMode) {
        print("${AppStrings.firestoreUserError}: ${error.toString()}");
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
        print("${AppStrings.firestoreUserError}: ${error.toString()}");
      }
      return null;
    }
  }

  // No need add to repository
  @override
  Future<UserModel?> fetchUserData(String userID) async {
    try {
      DocumentSnapshot userDoc = await _usersRef.doc(userID).get();
      DocumentSnapshot topicRankBoardSnapshot;


      if (!userDoc.exists) {
        throw CustomFirestoreException(
          code: 'new-user',
          message: 'User data does not exist in Firestore',
        );
      }

      Map<String, dynamic> documentMap = userDoc.data() as Map<String, dynamic>;
      documentMap['id'] = userDoc.id;

      topicRankBoardSnapshot = await documentMap['topicRankBoardRef'].get();

      Map<String, String> preferredTopics = {};

      if (topicRankBoardSnapshot.exists) {
        Map<String, dynamic> rank = Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

        List<MapEntry<String, int>> sortedTopics = rank.entries
            .map((entry) => MapEntry(entry.key, entry.value as int))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Convert sorted list into preferred-topics (Map<String, String>)
        for (int i = 0; i < 5; i++) {
          preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
        }
      }

      documentMap['preferred-topics'] = preferredTopics;

      return UserModel.fromMap(documentMap);
    } catch (e) {
      if (kDebugMode) {
        print('Error during fetching user data: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> addCurrentUserData(UserModel addUser) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    try {
      Map<String, dynamic> userData = addUser.toMap();
      await _usersRef.doc(currentUser?.uid).set(userData);
      Map<String, int> rankMap = {
        for (String preferTopic in addUser.preferredTopics.values)
          preferTopic: 10
      };

      DocumentReference docRef = await _topicRankBoardRef.add({
        "rank": rankMap,
      });

      String newDocId = docRef.id;

      await _usersRef.doc(currentUser?.uid).update({
        'topicRankBoardRef': _topicRankBoardRef.doc(newDocId),
      });

      await _notificationRef.doc(currentUser?.uid).set(<String, dynamic>{});
    } catch (error) {
      if (kDebugMode) {
        print("Error adding user data: $error");
      }
    }
  }

  @override
  Future<String>? uploadAvatar(File image, String uid) async {
    try {
      final storageReference = _storage.ref().child('/user_avatars/$uid');

      UploadTask uploadTask = storageReference.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      if (kDebugMode) {
        print('Uploaded Image URL: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCurrentUserData(UserModel updateUser) async {
    if (currentUser == null) {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      return;
    }

    try {
      await _usersRef.doc(currentUser?.uid).update(updateUser.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
    }
  }

  Future<Map<String, int>> updateMediaAndRecordNumber(String uid) async {
    int totalMediaCount = 0;
    int totalRecordCount = 0;

    try {
      final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
          await _usersPostRef(uid).get() as QuerySnapshot<Map<String, dynamic>>;

      for (var post in postsSnapshot.docs) {
        final mediaField = (await _postRef.doc(post.id).get())['media'];
        final recordField = (await _postRef.doc(post.id).get())['record'];

        if (mediaField != null) {
          int mediaLength = mediaField.length ?? 0;
          totalMediaCount += mediaLength;
        } else if (recordField != null) {
          totalRecordCount += 1;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error calculating total media count: $e");
      }
    }
    return {
      'totalRecordCount': totalRecordCount,
      'totalMediaCount': totalMediaCount
    };
  }

  @override
  Future<Map<String, dynamic>> getUserRelatedData(String uid) async {
    final Map<String, dynamic> dataMap = {
      'followers': [],
      'followings': [],
      'collectionsNumber': [],
      'mediasNumber': []
    };

    try {
      // Fetch followers
      final followersSnapshot = await _usersFollowersRef(uid).get()
          as QuerySnapshot<Map<String, dynamic>>;
      for (var doc in followersSnapshot.docs) {
        dataMap['followers']!.add(doc.id);
      }

      // Fetch followings
      final followingsSnapshot = await _usersFollowingsRef(uid).get()
          as QuerySnapshot<Map<String, dynamic>>;
      for (var doc in followingsSnapshot.docs) {
        dataMap['followings']!.add(doc.id);
      }

      dataMap['collectionsNumber'] =
          (await _usersCollectionsRef(uid).get()).size;
      Map<String, int> countDataNumber = await updateMediaAndRecordNumber(uid);
      dataMap['mediasNumber'] = countDataNumber['totalMediaCount'];
      dataMap['recordsNumber'] = countDataNumber['totalRecordCount'];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user-related data: $e');
      }
      rethrow;
    }

    return dataMap;
  }

  @override
  Future<void> followOrUnfollowUser(String uid, bool? isFollow) async {
    if (isFollow == null) {
      if (kDebugMode) {
        print("Nothing to do right now");
      }
      return;
    }

    final currentUserUid = currentUser!.uid;

    final userFollowersRef =
        _usersRef.doc(uid).collection('followers').doc(currentUserUid);
    final currentUserFollowingsRef =
        _usersRef.doc(currentUserUid).collection('followings').doc(uid);

    if (isFollow) {
      final userFollowersDoc = await userFollowersRef.get();
      if (!userFollowersDoc.exists) {
        await userFollowersRef.set({});
      }

      final currentUserFollowingsDoc = await currentUserFollowingsRef.get();
      if (!currentUserFollowingsDoc.exists) {
        await currentUserFollowingsRef.set({});
      }
    } else {
      final userFollowersDoc = await userFollowersRef.get();
      if (userFollowersDoc.exists) {
        await userFollowersRef.delete();
      }

      final currentUserFollowingsDoc = await currentUserFollowingsRef.get();
      if (currentUserFollowingsDoc.exists) {
        await currentUserFollowingsRef.delete();
      }
    }
  }
}

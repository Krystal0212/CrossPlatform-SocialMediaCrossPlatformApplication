import 'package:socialapp/utils/import.dart';

abstract class CollectionService {
  Future<List<CollectionModel>> getCollectionsFromOtherUser(String uid);

  Future<void> createCollection(String collectionName, bool isPublic);

  Future<void> updateAssetsToCollection(CollectionModel collection);

  Future<void> updateTitleToCollection(
      String title, CollectionModel collection);

  Future<void> removeOtherUserCollectionFromCurrentUser(
      CollectionModel collection);

  Future<void> removeCurrentUserCollectionFromCurrentUser(
      CollectionModel collection);

  Future<List<CollectionModel>> getCollectionsFromCurrentUser(String uid);

  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid);

  Future<List<CollectionModel>> getCollectionsFromQuery(String query);

  Future<List<CollectionModel>> getCollectionsOrderByAssets();
}

class CollectionServiceImpl extends CollectionService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _collectionRef =>
      _firestoreDB.collection('Collection');

  CollectionReference _collectionPostsRef(String collectionId) {
    return _collectionRef.doc(collectionId).collection('posts');
  }

  CollectionReference _usersCollectionsRef(String uid) {
    return _usersRef.doc(uid).collection('collections');
  }

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  // ToDo: Service Functions
  @override
  Future<List<CollectionModel>> getCollectionsFromOtherUser(String uid) async {
    List<CollectionModel> collections = [];
    DocumentReference userRef;
    DocumentSnapshot<Object?> userSnapshot;

    try {
      QuerySnapshot userCollectionsSnapshot =
          await _usersCollectionsRef(uid).get();

      if (userCollectionsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      // Extract collection IDs from the user's 'collections' sub-collection
      List<String> collectionIds =
          userCollectionsSnapshot.docs.map((doc) => doc.id).toList();

      if (collectionIds.isEmpty) {
        return [];
      }

      // Loop through the collection IDs to fetch each collection document directly
      for (var collectionId in collectionIds) {
        // Directly reference the collection document using collectionId
        DocumentSnapshot collectionSnapshot =
            await _collectionRef.doc(collectionId).get();

        if (collectionSnapshot.exists && collectionSnapshot.data() != null) {
          userRef = collectionSnapshot['userRef'];

          if (userRef.id != currentUser?.uid) {
            if ((collectionSnapshot['isPublic'] ?? false) &&
                currentUser?.uid != userRef.id) {
              // Fetch user reference and data
              userSnapshot = await userRef.get();
              Map<String, String> preferredTopics = {};

              Map<String, dynamic> documentMap =
                  userSnapshot.data() as Map<String, dynamic>;

              DocumentReference topicRankBoardRef =
                  documentMap['topicRankBoardRef'] as DocumentReference;
              DocumentSnapshot topicRankBoardSnapshot =
                  await topicRankBoardRef.get();

              if (topicRankBoardSnapshot.exists) {
                Map<String, dynamic> rank =
                    Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

                // Sort topics by rank value in descending order
                List<MapEntry<String, int>> sortedTopics = rank.entries
                    .map((entry) => MapEntry(entry.key, entry.value as int))
                    .toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                // Convert sorted list into preferredTopics (Map<String, String>)
                for (int i = 0; i < sortedTopics.length && i < 5; i++) {
                  preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
                }
              }

              // Update documentMap with preferred topics
              documentMap['preferred-topics'] = preferredTopics;
              documentMap['id'] = userRef.id;

              // Convert to UserModel
              UserModel userData = UserModel.fromMap(documentMap);
              List<PreviewAssetPostModel> assets = [];

              // Fetch post references and data
              // Assuming collectionSnapshot is your Firestore document snapshot
              List<dynamic> assetsList =
                  collectionSnapshot['assets'] as List<dynamic>;

              String? presentationUrl, dominantColor;
              bool isNSFW = false;
              double shotsNumber = 0;
              Timestamp? latestTimestamp;

              for (Map<String, dynamic> assetMap
                  in assetsList.map((e) => Map<String, dynamic>.from(e))) {
                PreviewAssetPostModel asset =
                    PreviewAssetPostModel.fromMap(assetMap);
                assets.add(asset);

                DocumentSnapshot postSnapshot =
                    await _postRef.doc(asset.postId).get();
                if (postSnapshot.exists && postSnapshot.data() != null) {
                  Map<String, dynamic> postData =
                      postSnapshot.data() as Map<String, dynamic>;

                  // Check if the post has a timestamp
                  if (postData.containsKey('timestamp') &&
                      postData['timestamp'] is Timestamp) {
                    Timestamp currentTimestamp =
                        postData['timestamp'] as Timestamp;

                    // Check if this is the latest timestamp
                    if (latestTimestamp == null ||
                        currentTimestamp.compareTo(latestTimestamp) > 0) {
                      latestTimestamp = currentTimestamp;

                      // Extract the presentation URL if media is valid
                      if (postData.containsKey('media') &&
                          postData['media'] is Map<String, dynamic>) {
                        Map<String, dynamic> mediaMap =
                            postData['media'] as Map<String, dynamic>;
                        shotsNumber += mediaMap.values.length;

                        // Use the first media item
                        Map<String, dynamic> firstMediaMap =
                            mediaMap.values.first as Map<String, dynamic>;
                        if (firstMediaMap['type'] == 'image' &&
                            firstMediaMap['imageUrl'] != null) {
                          presentationUrl = firstMediaMap['imageUrl'] as String;
                          dominantColor =
                              firstMediaMap['dominantColor'] as String;
                          isNSFW = firstMediaMap['isNSFW'];
                        } else if (firstMediaMap['type'] == 'video' &&
                            firstMediaMap['thumbnailUrl'] != null) {
                          presentationUrl =
                              firstMediaMap['thumbnailUrl'] as String;
                          dominantColor =
                              firstMediaMap['dominantColor'] as String;
                          isNSFW = firstMediaMap['isNSFW'];
                        }
                      }
                    }
                  }
                }
              }

              // Create and add the CollectionModel
              CollectionModel collection = CollectionModel(
                  collectionId: collectionSnapshot.id,
                  title: collectionSnapshot['title'],
                  assets: assets,
                  userData: userData,
                  presentationUrl: presentationUrl,
                  dominantColor: dominantColor,
                  shotsNumber: shotsNumber.toInt(),
                  isPublic: collectionSnapshot['isPublic'],
                  isNSFW: isNSFW);
              collections.add(collection);
            }
          }
        }
      }

      return collections;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collection data: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromCurrentUser(
      String uid) async {
    List<CollectionModel> collections = [];
    DocumentReference userRef;
    DocumentSnapshot<Object?> userSnapshot;

    try {
      QuerySnapshot userCollectionsSnapshot =
          await _usersCollectionsRef(uid).get();

      if (userCollectionsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      // Extract collection IDs from the user's 'collections' sub-collection
      List<String> collectionIds =
          userCollectionsSnapshot.docs.map((doc) => doc.id).toList();

      if (collectionIds.isEmpty) {
        return [];
      }

      // Loop through the collection IDs to fetch each collection document directly
      for (var collectionId in collectionIds) {
        // Directly reference the collection document using collectionId
        DocumentSnapshot collectionSnapshot =
            await _collectionRef.doc(collectionId).get();

        if (collectionSnapshot.exists && collectionSnapshot.data() != null) {
          // Fetch user reference and data
          userRef = collectionSnapshot['userRef'];
          if (currentUser?.uid == userRef.id) {
            userSnapshot = await userRef.get();
            Map<String, String> preferredTopics = {};

            Map<String, dynamic> documentMap =
                userSnapshot.data() as Map<String, dynamic>;

            DocumentReference topicRankBoardRef =
                documentMap['topicRankBoardRef'] as DocumentReference;
            DocumentSnapshot topicRankBoardSnapshot =
                await topicRankBoardRef.get();

            if (topicRankBoardSnapshot.exists) {
              Map<String, dynamic> rank =
                  Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

              // Sort topics by rank value in descending order
              List<MapEntry<String, int>> sortedTopics = rank.entries
                  .map((entry) => MapEntry(entry.key, entry.value as int))
                  .toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // Convert sorted list into preferredTopics (Map<String, String>)
              for (int i = 0; i < sortedTopics.length && i < 5; i++) {
                preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
              }
            }

            // Update documentMap with preferred topics
            documentMap['preferred-topics'] = preferredTopics;
            documentMap['id'] = userRef.id;

            // Convert to UserModel
            UserModel userData = UserModel.fromMap(documentMap);
            List<PreviewAssetPostModel> assets = [];

            // Fetch post references and data
            // Assuming collectionSnapshot is your Firestore document snapshot
            List<dynamic> assetsList =
                collectionSnapshot['assets'] as List<dynamic>;

            String? presentationUrl, dominantColor;
            bool isNSFW = false;
            double shotsNumber = 0;
            Timestamp? latestTimestamp;

            for (Map<String, dynamic> assetMap
                in assetsList.map((e) => Map<String, dynamic>.from(e))) {
              PreviewAssetPostModel asset =
                  PreviewAssetPostModel.fromMap(assetMap);
              assets.add(asset);

              DocumentSnapshot postSnapshot =
                  await _postRef.doc(asset.postId).get();
              if (postSnapshot.exists && postSnapshot.data() != null) {
                Map<String, dynamic> postData =
                    postSnapshot.data() as Map<String, dynamic>;

                // Check if the post has a timestamp
                if (postData.containsKey('timestamp') &&
                    postData['timestamp'] is Timestamp) {
                  Timestamp currentTimestamp =
                      postData['timestamp'] as Timestamp;

                  // Check if this is the latest timestamp
                  if (latestTimestamp == null ||
                      currentTimestamp.compareTo(latestTimestamp) > 0) {
                    latestTimestamp = currentTimestamp;

                    // Extract the presentation URL if media is valid
                    if (postData.containsKey('media') &&
                        postData['media'] is Map<String, dynamic>) {
                      Map<String, dynamic> mediaMap =
                          postData['media'] as Map<String, dynamic>;
                      shotsNumber += mediaMap.values.length;

                      // Use the first media item
                      Map<String, dynamic> firstMediaMap =
                          mediaMap.values.first as Map<String, dynamic>;
                      if (firstMediaMap['type'] == 'image' &&
                          firstMediaMap['imageUrl'] != null) {
                        presentationUrl = firstMediaMap['imageUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      } else if (firstMediaMap['type'] == 'video' &&
                          firstMediaMap['thumbnailUrl'] != null) {
                        presentationUrl =
                            firstMediaMap['thumbnailUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      }
                    }
                  }
                }
              }
            }

            // Create and add the CollectionModel
            CollectionModel collection = CollectionModel(
                collectionId: collectionSnapshot.id,
                title: collectionSnapshot['title'],
                assets: assets,
                userData: userData,
                presentationUrl: presentationUrl,
                dominantColor: dominantColor,
                shotsNumber: shotsNumber.toInt(),
                isPublic: collectionSnapshot['isPublic'],
                isNSFW: isNSFW);
            collections.add(collection);
          }
        }
      }

      return collections;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collection data: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid) {
    try {
      return _usersCollectionsRef(uid)
          .snapshots()
          .asyncMap((QuerySnapshot userCollectionsSnapshot) async {
        List<CollectionModel> collections = [];

        if (userCollectionsSnapshot.docs.isEmpty) {
          return collections;
        }

        // Extract collection IDs from the user's 'collections' sub-collection
        List<String> collectionIds =
            userCollectionsSnapshot.docs.map((doc) => doc.id).toList();

        // Loop through the collection IDs to fetch each collection document directly
        for (var collectionId in collectionIds) {
          // Directly reference the collection document using collectionId
          DocumentSnapshot collectionSnapshot =
              await _collectionRef.doc(collectionId).get();

          if (collectionSnapshot.exists && collectionSnapshot.data() != null) {
            // Fetch user reference and data
            DocumentReference userRef = collectionSnapshot['userRef'];
            DocumentSnapshot userSnapshot = await userRef.get();
            Map<String, dynamic> documentMap =
                userSnapshot.data() as Map<String, dynamic>;

            // Fetch preferred topics from the topicRankBoard document
            Map<String, String> preferredTopics = {};
            DocumentReference topicRankBoardRef =
                documentMap['topicRankBoardRef'] as DocumentReference;
            DocumentSnapshot topicRankBoardSnapshot =
                await topicRankBoardRef.get();

            if (topicRankBoardSnapshot.exists) {
              Map<String, dynamic> rank =
                  Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

              // Sort topics by rank value in descending order
              List<MapEntry<String, int>> sortedTopics = rank.entries
                  .map((entry) => MapEntry(entry.key, entry.value as int))
                  .toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // Convert sorted list into preferredTopics (Map<String, String>)
              for (int i = 0; i < sortedTopics.length && i < 5; i++) {
                preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
              }
            }

            // Update documentMap with preferred topics
            documentMap['preferred-topics'] = preferredTopics;
            documentMap['id'] = userRef.id;

            UserModel userData = UserModel.fromMap(documentMap);
            List<PreviewAssetPostModel> assets = [];

            List<dynamic> assetsList =
                collectionSnapshot['assets'] as List<dynamic>;

            String? presentationUrl, dominantColor;
            bool isNSFW = false;
            double shotsNumber = assetsList.length.toDouble();
            Timestamp? latestTimestamp;

            for (Map<String, dynamic> assetMap
                in assetsList.map((e) => Map<String, dynamic>.from(e))) {
              PreviewAssetPostModel asset =
                  PreviewAssetPostModel.fromMap(assetMap);
              assets.add(asset);

              // Fetch the post document associated with this asset
              DocumentSnapshot postSnapshot =
                  await _postRef.doc(asset.postId).get();
              if (postSnapshot.exists && postSnapshot.data() != null) {
                Map<String, dynamic> postData =
                    postSnapshot.data() as Map<String, dynamic>;

                // Check if the post has a timestamp
                if (postData.containsKey('timestamp') &&
                    postData['timestamp'] is Timestamp) {
                  Timestamp currentTimestamp =
                      postData['timestamp'] as Timestamp;

                  // Check if this is the latest timestamp
                  if (latestTimestamp == null ||
                      currentTimestamp.compareTo(latestTimestamp) > 0) {
                    latestTimestamp = currentTimestamp;

                    // Extract the presentation URL if media is valid
                    if (postData.containsKey('media') &&
                        postData['media'] is Map<String, dynamic>) {
                      Map<String, dynamic> mediaMap =
                          postData['media'] as Map<String, dynamic>;

                      // Use the first media item
                      Map<String, dynamic> firstMediaMap =
                          mediaMap.values.first as Map<String, dynamic>;
                      if (firstMediaMap['type'] == 'image' &&
                          firstMediaMap['imageUrl'] != null) {
                        presentationUrl = firstMediaMap['imageUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      } else if (firstMediaMap['type'] == 'video' &&
                          firstMediaMap['thumbnailUrl'] != null) {
                        presentationUrl =
                            firstMediaMap['thumbnailUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      }
                    }
                  }
                }
              }
            }

            // Create a CollectionModel from the collection document data
            CollectionModel collectionModel = CollectionModel(
                collectionId: collectionSnapshot.id,
                title: collectionSnapshot['title'],
                assets: assets,
                userData: userData,
                presentationUrl: presentationUrl,
                dominantColor: dominantColor,
                shotsNumber: shotsNumber.toInt(),
                isPublic: collectionSnapshot['isPublic'],
                isNSFW: isNSFW);
            collections.add(collectionModel);
          } else {
            await _usersCollectionsRef(uid).doc(collectionId).delete();
            continue;
          }
        }

        return collections;
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching collections stream: $error");
      }
      rethrow;
    }
  }

  Future<UserModel?> _fetchUserData(String userID) async {
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
  Future<void> createCollection(String collectionName, bool isPublic) async {
    try {
      UserModel? userData = await _fetchUserData(currentUser!.uid);

      CollectionModel newCollection = CollectionModel.newCollection(
        title: collectionName,
        userData: userData!,
        isPublic: isPublic,
      );

      DocumentReference docRef =
          await _collectionRef.add(newCollection.toMap());

      String collectionID = docRef.id;
      _usersRef
          .doc(currentUser!.uid)
          .collection('collections')
          .doc(collectionID)
          .set({});
    } catch (error) {
      if (kDebugMode) {
        print("Error creating collection: $error");
      }
    }
  }

  @override
  Future<void> updateAssetsToCollection(CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;
      List<Map<String, dynamic>> assets = collection.assets
          .map((asset) => asset.toMap())
          .toList(); // Get the assets from the collection

      var collectionRef = _collectionRef.doc(collectionId);

      await collectionRef.update({
        'assets': assets,
      });

      var userCollectionRef = _usersRef
          .doc(currentUser!.uid)
          .collection('collections')
          .doc(collectionRef.id);

      await userCollectionRef.set({'dummy': true});

      await userCollectionRef.set({});
    } catch (error) {
      if (kDebugMode) {
        print("Error adding/updating collection: $error");
      }
    }
  }

  @override
  Future<void> updateTitleToCollection(
      String title, CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;

      var collectionRef = _collectionRef.doc(collectionId);

      await collectionRef.update({
        'title': title,
      });

      var userCollectionRef = _usersRef
          .doc(currentUser!.uid)
          .collection('collections')
          .doc(collectionRef.id);

      await userCollectionRef.set({'dummy': true});

      await userCollectionRef.set({});
    } catch (error) {
      if (kDebugMode) {
        print("Error adding/updating collection: $error");
      }
    }
  }

  @override
  Future<void> removeOtherUserCollectionFromCurrentUser(
      CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;

      var collectionRef = _collectionRef.doc(collectionId);

      var userCollectionRef = _usersRef
          .doc(currentUser!.uid)
          .collection('collections')
          .doc(collectionRef.id);

      await userCollectionRef.delete();
    } catch (error) {
      if (kDebugMode) {
        print("Error removing collection: $error");
      }
    }
  }

  @override
  Future<void> removeCurrentUserCollectionFromCurrentUser(
      CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;

      var collectionRef = _collectionRef.doc(collectionId);

      await collectionRef.delete();

      var userCollectionRef = _usersRef
          .doc(currentUser!.uid)
          .collection('collections')
          .doc(collectionRef.id);

      await userCollectionRef.delete();
    } catch (error) {
      if (kDebugMode) {
        print("Error removing collection: $error");
      }
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromQuery(String query) async {
    List<CollectionModel> collections = [];
    DocumentReference userRef;
    DocumentSnapshot<Object?> userSnapshot;

    try {
      QuerySnapshot collectionSnapshot = await _collectionRef
          .where('isPublic', isEqualTo: true)
          .where('titleLowercase', isGreaterThanOrEqualTo: query)
          .where('titleLowercase', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      if (collectionSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-result-match',
          message: 'No result matches',
        );
      }

      for (var collectionDoc in collectionSnapshot.docs) {
        if (!collectionDoc['title']
            .toLowerCase()
            .contains(query.toLowerCase())) {
          continue;
        }
        userRef = collectionDoc['userRef'];

        // Fetch user reference and data
        userSnapshot = await userRef.get();
        Map<String, String> preferredTopics = {};

        Map<String, dynamic> documentMap =
            userSnapshot.data() as Map<String, dynamic>;

        DocumentReference topicRankBoardRef =
            documentMap['topicRankBoardRef'] as DocumentReference;
        DocumentSnapshot topicRankBoardSnapshot = await topicRankBoardRef.get();

        if (topicRankBoardSnapshot.exists) {
          Map<String, dynamic> rank =
              Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

          // Sort topics by rank value in descending order
          List<MapEntry<String, int>> sortedTopics = rank.entries
              .map((entry) => MapEntry(entry.key, entry.value as int))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Convert sorted list into preferredTopics (Map<String, String>)
          for (int i = 0; i < sortedTopics.length && i < 5; i++) {
            preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
          }
        }

        // Update documentMap with preferred topics
        documentMap['preferred-topics'] = preferredTopics;
        documentMap['id'] = userRef.id;

        // Convert to UserModel
        UserModel userData = UserModel.fromMap(documentMap);
        List<PreviewAssetPostModel> assets = [];

        List<dynamic> assetsList = collectionDoc['assets'] as List<dynamic>;

        String? presentationUrl, dominantColor;
        bool isNSFW = false;
        double shotsNumber = assetsList.length.toDouble();
        ;
        Timestamp? latestTimestamp;

        for (Map<String, dynamic> assetMap
            in assetsList.map((e) => Map<String, dynamic>.from(e))) {
          PreviewAssetPostModel asset = PreviewAssetPostModel.fromMap(assetMap);
          assets.add(asset);

          // Fetch the post document associated with this asset
          DocumentSnapshot postSnapshot =
              await _postRef.doc(asset.postId).get();
          if (postSnapshot.exists && postSnapshot.data() != null) {
            Map<String, dynamic> postData =
                postSnapshot.data() as Map<String, dynamic>;

            // Check if the post has a timestamp
            if (postData.containsKey('timestamp') &&
                postData['timestamp'] is Timestamp) {
              Timestamp currentTimestamp = postData['timestamp'] as Timestamp;

              // Check if this is the latest timestamp
              if (latestTimestamp == null ||
                  currentTimestamp.compareTo(latestTimestamp) > 0) {
                latestTimestamp = currentTimestamp;

                // Extract the presentation URL if media is valid
                if (postData.containsKey('media') &&
                    postData['media'] is Map<String, dynamic>) {
                  Map<String, dynamic> mediaMap =
                      postData['media'] as Map<String, dynamic>;

                  // Use the first media item
                  Map<String, dynamic> firstMediaMap =
                      mediaMap.values.first as Map<String, dynamic>;
                  if (firstMediaMap['type'] == 'image' &&
                      firstMediaMap['imageUrl'] != null) {
                    presentationUrl = firstMediaMap['imageUrl'] as String;
                    dominantColor = firstMediaMap['dominantColor'] as String;
                    isNSFW = firstMediaMap['isNSFW'];
                  } else if (firstMediaMap['type'] == 'video' &&
                      firstMediaMap['thumbnailUrl'] != null) {
                    presentationUrl = firstMediaMap['thumbnailUrl'] as String;
                    dominantColor = firstMediaMap['dominantColor'] as String;
                    isNSFW = firstMediaMap['isNSFW'];
                  }
                }
              }
            }
          }
        }
        CollectionModel collection = CollectionModel(
            collectionId: collectionDoc.id,
            title: collectionDoc['title'],
            assets: assets,
            userData: userData,
            presentationUrl: presentationUrl,
            dominantColor: dominantColor,
            shotsNumber: shotsNumber.toInt(),
            isPublic: collectionDoc['isPublic'],
            isNSFW: isNSFW);
        collections.add(collection);
      }
      return collections;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collection data: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsOrderByAssets() async {
    List<CollectionModel> collections = [];

    try {
      QuerySnapshot collectionSnapshot = await _collectionRef.limit(20).get();

      if (collectionSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-collection-created',
          message: 'No collection created',
        );
      }

      List<QueryDocumentSnapshot> sortedDocuments =
          collectionSnapshot.docs.toList()
            ..sort((a, b) {
              int lengthA = (a['assets'] as List<dynamic>).length;
              int lengthB = (b['assets'] as List<dynamic>).length;
              return lengthB.compareTo(lengthA); // Descending order
            });

      for (var collectionDoc in sortedDocuments) {
        DocumentReference userRef = collectionDoc['userRef'];

        if ((collectionDoc['isPublic'] ?? false)) {
          // Fetch user reference and data
          DocumentSnapshot userSnapshot = await userRef.get();

          if (userSnapshot.exists && userSnapshot.data() != null) {
            Map<String, dynamic> documentMap =
                userSnapshot.data() as Map<String, dynamic>;

            // DocumentReference topicRankBoardRef =
            //     documentMap['topicRankBoardRef'] as DocumentReference;
            // DocumentSnapshot topicRankBoardSnapshot =
            //     await topicRankBoardRef.get();

            Map<String, String> preferredTopics = {};
            // if (topicRankBoardSnapshot.exists) {
            //   Map<String, dynamic> rank = Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);
            //
            //   List<MapEntry<String, int>> sortedTopics = rank.entries
            //       .map((entry) {
            //     int value = entry.value is int ? entry.value : (entry.value as double).toInt();
            //     return MapEntry(entry.key, value);
            //   })
            //       .toList()
            //     ..sort((a, b) => b.value.compareTo(a.value));
            //
            //   for (int i = 0; i < sortedTopics.length && i < 5; i++) {
            //     preferredTopics[(i + 1).toString()] = sortedTopics[i].key;
            //   }
            // }

            documentMap['preferred-topics'] = preferredTopics;
            documentMap['id'] = userRef.id;

            UserModel userData = UserModel.fromMap(documentMap);
            List<PreviewAssetPostModel> assets = [];

            List<dynamic> assetsList = collectionDoc['assets'] as List<dynamic>;

            String? presentationUrl, dominantColor;
            bool isNSFW = false;
            double shotsNumber = 0;
            Timestamp? latestTimestamp;

            for (Map<String, dynamic> assetMap
                in assetsList.map((e) => Map<String, dynamic>.from(e))) {
              PreviewAssetPostModel asset =
                  PreviewAssetPostModel.fromMap(assetMap);
              assets.add(asset);

              DocumentSnapshot postSnapshot =
                  await _postRef.doc(asset.postId).get();
              if (postSnapshot.exists && postSnapshot.data() != null) {
                Map<String, dynamic> postData =
                    postSnapshot.data() as Map<String, dynamic>;

                if (postData.containsKey('timestamp') &&
                    postData['timestamp'] is Timestamp) {
                  Timestamp currentTimestamp =
                      postData['timestamp'] as Timestamp;
                  if (latestTimestamp == null ||
                      currentTimestamp.compareTo(latestTimestamp) > 0) {
                    latestTimestamp = currentTimestamp;

                    if (postData.containsKey('media') &&
                        postData['media'] is Map<String, dynamic>) {
                      Map<String, dynamic> mediaMap =
                          postData['media'] as Map<String, dynamic>;
                      shotsNumber += mediaMap.values.length;

                      Map<String, dynamic> firstMediaMap =
                          mediaMap.values.first as Map<String, dynamic>;
                      if (firstMediaMap['type'] == 'image' &&
                          firstMediaMap['imageUrl'] != null) {
                        presentationUrl = firstMediaMap['imageUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      } else if (firstMediaMap['type'] == 'video' &&
                          firstMediaMap['thumbnailUrl'] != null) {
                        presentationUrl =
                            firstMediaMap['thumbnailUrl'] as String;
                        dominantColor =
                            firstMediaMap['dominantColor'] as String;
                        isNSFW = firstMediaMap['isNSFW'];
                      }
                    }
                  }
                }
              }
            }

            // Tạo CollectionModel và thêm vào danh sách
            CollectionModel collection = CollectionModel(
              collectionId: collectionDoc.id,
              title: collectionDoc['title'],
              assets: assets,
              userData: userData,
              presentationUrl: presentationUrl,
              dominantColor: dominantColor,
              shotsNumber: shotsNumber.toInt(),
              isPublic: collectionDoc['isPublic'],
              isNSFW: isNSFW,
            );

            collections.add(collection);
          }
        }
      }
      return collections;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collections for browsing: $e');
      }
      rethrow;
    }
  }
}

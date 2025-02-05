import 'package:socialapp/utils/import.dart';

abstract class CollectionService {
  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList);

  Future<List<CollectionModel>?>? getCollections();

  Future<List<String>> getCollectionPostsID(String collectionID);

  Future<List<CollectionModel>> getCollectionsFromUser(String uid);

  Future<void> createCollection(String collectionName, bool isPublic);

  Future<void> updateAssetsToCollection(CollectionModel collection);

  Future<void> updateTitleToCollection(String title, CollectionModel collection);

  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid);
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

  // ToDo: Service Functions

  @override
  Future<List<CollectionModel>?>? getCollections() async {
    List<CollectionModel> collections = [];
    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userSnapshot;
    UserModel userData = UserModel.empty();

    try {
      QuerySnapshot collectionSnapshot = await _collectionRef.get();

      if (collectionSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      for (var document in collectionSnapshot.docs) {
        userRef = document['userRef'];
        userSnapshot = userRef.get();

        await userSnapshot.then((value) {
          userData = UserModel.fromMap(value.data() as Map<String, dynamic>);
        });

        List<DocumentReference> postRefs =
            List<DocumentReference>.from(document['postRefs']);
        List<PreviewAssetPostModel> posts = [];

        String? presentationUrl, dominantColor;
        bool isNSFW = false;
        Timestamp? latestTimestamp;
        double shotsNumber = 0;

        for (DocumentReference postRef in postRefs) {
          DocumentSnapshot postSnapshot = await postRef.get();
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
                  shotsNumber += postData['media'].values.length;

                  Map<String, dynamic> firstMediaMap =
                      postData['media'].values.first as Map<String, dynamic>;
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
          collectionId: document.id,
          title: document['name'],
          assets: posts,
          userData: userData,
          presentationUrl: presentationUrl,
          dominantColor: dominantColor,
          shotsNumber: shotsNumber.toInt(), isPublic: document['isPublic'], isNSFW: isNSFW,
        );
        collections.add(collection);

        return collections.isEmpty ? null : collections;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collections: $e');
      }
      rethrow;
    }
    return null;
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromUser(String uid) async {
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
          userSnapshot = await userRef.get();
          Map<String, String> preferredTopics = {};

          Map<String, dynamic> documentMap = userSnapshot.data() as Map<String, dynamic>;

          DocumentReference topicRankBoardRef = documentMap['topicRankBoardRef'] as DocumentReference;
          DocumentSnapshot topicRankBoardSnapshot = await topicRankBoardRef.get();

          if (topicRankBoardSnapshot.exists) {
            Map<String, dynamic> rank = Map<String, dynamic>.from(topicRankBoardSnapshot['rank']);

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

          // Convert to UserModel
          UserModel userData = UserModel.fromMap(documentMap);
          List<PreviewAssetPostModel> assets = [];

          // Fetch post references and data
          // Assuming collectionSnapshot is your Firestore document snapshot
          List<dynamic> assetsList = collectionSnapshot['assets'] as List<dynamic>;

          String? presentationUrl, dominantColor;
          bool isNSFW = false;
          double shotsNumber = 0;
          Timestamp? latestTimestamp;

          for (Map<String, dynamic> assetMap in assetsList.map((e) => Map<String, dynamic>.from(e))) {

            PreviewAssetPostModel asset = PreviewAssetPostModel.fromMap(assetMap);
            assets.add(asset);

            DocumentSnapshot postSnapshot = await _postRef.doc(asset.postId).get();
            if (postSnapshot.exists && postSnapshot.data() != null) {
              Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

              // Check if the post has a timestamp
              if (postData.containsKey('timestamp') && postData['timestamp'] is Timestamp) {
                Timestamp currentTimestamp = postData['timestamp'] as Timestamp;

                // Check if this is the latest timestamp
                if (latestTimestamp == null || currentTimestamp.compareTo(latestTimestamp) > 0) {
                  latestTimestamp = currentTimestamp;

                  // Extract the presentation URL if media is valid
                  if (postData.containsKey('media') &&
                      postData['media'] is Map<String, dynamic>) {
                    Map<String, dynamic> mediaMap = postData['media'] as Map<String, dynamic>;
                    shotsNumber += mediaMap.values.length;

                    // Use the first media item
                    Map<String, dynamic> firstMediaMap = mediaMap.values.first as Map<String, dynamic>;
                    if (firstMediaMap['type'] == 'image' && firstMediaMap['imageUrl'] != null) {
                      presentationUrl = firstMediaMap['imageUrl'] as String;
                      dominantColor = firstMediaMap['dominantColor'] as String;
                      isNSFW = firstMediaMap['isNSFW'];

                    } else if (firstMediaMap['type'] == 'video' && firstMediaMap['thumbnailUrl'] != null) {
                      presentationUrl = firstMediaMap['thumbnailUrl'] as String;
                      dominantColor = firstMediaMap['dominantColor'] as String;
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
            shotsNumber: shotsNumber.toInt(), isPublic: collectionSnapshot['isPublic'],
            isNSFW: isNSFW
          );
          collections.add(collection);
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
      return _usersCollectionsRef(uid).snapshots().asyncMap((
          QuerySnapshot userCollectionsSnapshot) async {
        List<CollectionModel> collections = [];

        if (userCollectionsSnapshot.docs.isEmpty) {
          return collections;
        }

        // Extract collection IDs from the user's 'collections' sub-collection
        List<String> collectionIds = userCollectionsSnapshot.docs.map((
            doc) => doc.id).toList();

        // Loop through the collection IDs to fetch each collection document directly
        for (var collectionId in collectionIds) {
          // Directly reference the collection document using collectionId
          DocumentSnapshot collectionSnapshot = await _collectionRef.doc(
              collectionId).get();

          if (collectionSnapshot.exists && collectionSnapshot.data() != null) {
            // Fetch user reference and data
            DocumentReference userRef = collectionSnapshot['userRef'];
            DocumentSnapshot userSnapshot = await userRef.get();
            Map<String, dynamic> documentMap = userSnapshot.data() as Map<
                String,
                dynamic>;

            // Fetch preferred topics from the topicRankBoard document
            Map<String, String> preferredTopics = {};
            DocumentReference topicRankBoardRef = documentMap['topicRankBoardRef'] as DocumentReference;
            DocumentSnapshot topicRankBoardSnapshot = await topicRankBoardRef
                .get();

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

            UserModel userData = UserModel.fromMap(documentMap);
            List<PreviewAssetPostModel> assets = [];

            List<dynamic> assetsList = collectionSnapshot['assets'] as List<
                dynamic>;

            String? presentationUrl, dominantColor;
            bool isNSFW = false;
            double shotsNumber = assetsList.length.toDouble();
            Timestamp? latestTimestamp;

            for (Map<String, dynamic> assetMap in assetsList.map((e) =>
            Map<
                String,
                dynamic>.from(e))) {
              PreviewAssetPostModel asset = PreviewAssetPostModel.fromMap(
                  assetMap);
              assets.add(asset);

              // Fetch the post document associated with this asset
              DocumentSnapshot postSnapshot = await _postRef.doc(asset.postId)
                  .get();
              if (postSnapshot.exists && postSnapshot.data() != null) {
                Map<String, dynamic> postData = postSnapshot.data() as Map<
                    String,
                    dynamic>;

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
                      Map<String, dynamic> mediaMap = postData['media'] as Map<
                          String,
                          dynamic>;

                      // Use the first media item
                      Map<String, dynamic> firstMediaMap = mediaMap.values
                          .first as Map<String, dynamic>;
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
                isNSFW: isNSFW

            );
            collections.add(collectionModel);
          }
        }

        return collections;
      });
    }catch(error){
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
  Future<void> createCollection(String collectionName, bool isPublic) async {
    try{
      UserModel? userData = await _fetchUserData(currentUser!.uid);

      CollectionModel newCollection = CollectionModel.newCollection(
        title: collectionName,
        userData: userData!,
        isPublic: isPublic,
      );

      DocumentReference docRef = await _collectionRef.add(newCollection.toMap());

      String collectionID = docRef.id;
      _usersRef.doc(currentUser!.uid).collection('collections').doc(collectionID).set({});

    }catch(error){
      if (kDebugMode) {
        print("Error creating collection: $error");
      }
    }
  }

  @override
  Future<void> updateAssetsToCollection(CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;
      List<Map<String,dynamic>> assets = collection.assets.map((asset) => asset.toMap()).toList(); // Get the assets from the collection

      var collectionRef = _collectionRef.doc(collectionId);

      await collectionRef.update({
        'assets': assets,
      });

      var userCollectionRef = _usersRef.doc(currentUser!.uid).collection('collections').doc(collectionRef.id);


      await userCollectionRef.set({'dummy':true});

      await userCollectionRef.set({});

    } catch (error) {
      if (kDebugMode) {
        print("Error adding/updating collection: $error");
      }
    }
  }

  @override
  Future<void> updateTitleToCollection(String title, CollectionModel collection) async {
    try {
      String collectionId = collection.collectionId;

      var collectionRef = _collectionRef.doc(collectionId);

      await collectionRef.update({
        'title': title,
      });

      var userCollectionRef = _usersRef.doc(currentUser!.uid).collection('collections').doc(collectionRef.id);


      await userCollectionRef.set({'dummy':true});

      await userCollectionRef.set({});

    } catch (error) {
      if (kDebugMode) {
        print("Error adding/updating collection: $error");
      }
    }
  }

  // will remove
  @override
  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList) async {
    List<CollectionModel> collections = [];

    try {
      for (String collectionID in collectionIDsList) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _collectionRef
            .doc(collectionID)
            .get() as DocumentSnapshot<Map<String, dynamic>>;

        if (snapshot.exists && snapshot.data() != null) {
          CollectionModel collection =
              CollectionModel.fromMap(snapshot.data()!);
          collections.add(collection); // Add to list of collections
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting collection data: $e");
      }
    }

    return collections;
  }

  //will remove
  @override
  Future<List<String>> getCollectionPostsID(String collectionID) async {
    List<String> postIDs = [];

    QuerySnapshot<Map<String, dynamic>> followingsSnapshot =
        await _collectionPostsRef(collectionID).get()
            as QuerySnapshot<Map<String, dynamic>>;

    for (var doc in followingsSnapshot.docs) {
      postIDs.add(doc.id);
    }

    return postIDs;
  }
}
// List<PreviewAssetPostModel> assets =
// List<PreviewAssetPostModel>.from(collectionSnapshot['assets']);
//
// String? presentationUrl, dominantColor;
// double shotsNumber = 0;
//
// if(assets.isNotEmpty){
//
// }
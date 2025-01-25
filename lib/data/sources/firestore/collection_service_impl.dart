import 'package:socialapp/utils/import.dart';

abstract class CollectionService {
  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList);

  Future<List<CollectionModel>?>? getCollections();

  Future<List<String>> getCollectionPostsID(String collectionID);

  Future<List<CollectionModel>> getCollectionsFromUser(String uid);
}

class CollectionServiceImpl extends CollectionService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

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
                  } else if (firstMediaMap['type'] == 'video' &&
                      firstMediaMap['thumbnailUrl'] != null) {
                    presentationUrl = firstMediaMap['thumbnailUrl'] as String;
                    dominantColor = firstMediaMap['dominantColor'] as String;
                  }
                }
              }
            }
          }
        }

        CollectionModel collection = CollectionModel(
          collectionId: document.id,
          title: document['name'],
          posts: posts,
          userData: userData,
          presentationUrl: presentationUrl,
          dominantColor: dominantColor,
          shotsNumber: shotsNumber.toInt(),
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
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromUser(String uid) async {
    List<CollectionModel> collections = [];
    DocumentReference userRef;
    Future<DocumentSnapshot<Object?>> userSnapshot;
    UserModel userData = UserModel.empty();

    try {
      // Get the user's 'collections' sub-collection
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
          userSnapshot = userRef.get();

          await userSnapshot.then((value) {
            userData = UserModel.fromMap(value.data() as Map<String, dynamic>);
          });

          // Fetch post references and data
          List<DocumentReference> postRefs =
              List<DocumentReference>.from(collectionSnapshot['postRefs']);
          List<PreviewAssetPostModel> posts = [];

          String? presentationUrl, dominantColor;
          double shotsNumber = 0;
          Timestamp? latestTimestamp;

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
                    } else if (firstMediaMap['type'] == 'video' &&
                        firstMediaMap['thumbnailUrl'] != null) {
                      presentationUrl = firstMediaMap['thumbnailUrl'] as String;
                      dominantColor = firstMediaMap['dominantColor'] as String;
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
            posts: posts,
            userData: userData,
            presentationUrl: presentationUrl,
            dominantColor: dominantColor,
            shotsNumber: shotsNumber.toInt(),
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
        print("Error fetching collection data: $e");
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

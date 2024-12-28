import 'package:socialapp/utils/import.dart';

abstract class CollectionService {

  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList);

  Future<List<CollectionModel>?>? getCollections();

  Future<List<String>> getCollectionPostsID(String collectionID);
}

class CollectionServiceImpl extends CollectionService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _collectionRef =>
      _firestoreDB.collection('Collection');

  CollectionReference _collectionPostsRef(String collectionId) {
    return _collectionRef.doc(collectionId).collection('posts');
  }

  // ToDo: Service Functions

  @override
  Future<List<CollectionModel>?>? getCollections() async {
    List<CollectionModel> collections = [];
    try {
      QuerySnapshot collectionSnapshot =
      await _firestoreDB.collection('NewCollection').get();

      if (collectionSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      for (var doc in collectionSnapshot.docs) {
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

    return collections; // Return the list of CollectionModel objects
  }

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
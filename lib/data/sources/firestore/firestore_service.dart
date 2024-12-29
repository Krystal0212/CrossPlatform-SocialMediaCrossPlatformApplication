import 'package:socialapp/utils/import.dart';

abstract class FirestoreService {
  Future<List<TopicModel>> fetchTopicsData();
  Future<List<Map<TopicModel, bool>>>fetchPreferredTopicsData();
// Future<void> addTopicData(AddTopicReq addTopicReq);

// Future<void> updateTopicData(UpdateTopicReq updateTopicReq);
// Future<TopicModel?>? getTopicData(String topicID);

}

class FirestoreServiceImpl extends FirestoreService {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _topicRef => _firestoreDB.collection('Topic');

  // ToDo: Service Functions
  @override
  Future<List<TopicModel>> fetchTopicsData() async {
    List<TopicModel> categories = [];
    try {
      QuerySnapshot topicsSnapshot = await _topicRef.get();

      if (topicsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      categories = topicsSnapshot.docs
          .map((doc) => TopicModel.fromMap(doc.data() as Map<String, dynamic>, doc.id.toString()))
          .toList();



      return categories;
    } catch (e) {
      if (kDebugMode) {
        print("Error get topic list: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<TopicModel, bool>>>fetchPreferredTopicsData() async {
    List<TopicModel> topics = [];
    List<Map<TopicModel,bool>> topicsWithBoolean = [];
    try {
      topics = await fetchTopicsData();
      topicsWithBoolean = topics.map((topic)=>{topic: false}).toList();

      return topicsWithBoolean;
    } catch (e) {
      if (kDebugMode) {
        print("Error get topic list: $e");
      }
      rethrow;
    }
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

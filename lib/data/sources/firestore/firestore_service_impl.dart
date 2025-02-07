import 'package:socialapp/utils/import.dart';

abstract class FirestoreService {
  Future<List<TopicModel>> fetchTopicsData();

  Future<List<Map<TopicModel, bool>>> fetchPreferredTopicsData();

  Future<List<TopicModel>> getRandomTopics();

  Future<List<TopicModel>> fetchTopicsByField(List<TopicModel> selectedTopics,String matchValue);
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
          .map((doc) => TopicModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id.toString()))
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
  Future<List<TopicModel>> getRandomTopics() async {
    List<TopicModel> categories = [];
    Set<int> randomIndices = {}; // To track unique random indices

    try {
      QuerySnapshot topicsSnapshot = await _topicRef.get();
      int totalDocs = topicsSnapshot.docs.length;

      if (totalDocs == 0) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      Random random = Random();

      while (randomIndices.length < 10) {
        int randomIndex = random.nextInt(totalDocs);
        randomIndices.add(randomIndex);
      }

      for (int index in randomIndices) {
        DocumentSnapshot randomTopicDoc = topicsSnapshot.docs[index];
        categories.add(TopicModel.fromMap(
          randomTopicDoc.data() as Map<String, dynamic>,
          randomTopicDoc.id.toString(),
        ));
      }

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching random topics: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<TopicModel>> fetchTopicsByField(
      List<TopicModel> selectedTopics, String matchValue) async {
    List<TopicModel> filteredTopics = [];

    try {
      QuerySnapshot topicsSnapshot = await _topicRef.get();

      if (topicsSnapshot.docs.isEmpty) {
        throw CustomFirestoreException(
          code: 'no-topics',
          message: 'No topics exist in Firestore',
        );
      }

      filteredTopics = topicsSnapshot.docs
          .where((doc) {
            String name = (doc.data() as Map<String, dynamic>)['name'] ?? '';
            return name.toLowerCase() != 'audio record' &&
                name.toLowerCase().contains(matchValue.toLowerCase());
          })
          .map((doc) {
            TopicModel topic = TopicModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id.toString());

            if (selectedTopics.contains(topic)) {
              return null;
            }

            return topic;
          })
          .whereType<TopicModel>()
          .toList();

      return filteredTopics;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching topics: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<TopicModel, bool>>> fetchPreferredTopicsData() async {
    List<TopicModel> topics = [];
    List<Map<TopicModel, bool>> topicsWithBoolean = [];
    try {
      topics = await fetchTopicsData();
      topicsWithBoolean = topics.map((topic) => {topic: false}).toList();

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

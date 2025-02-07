import '../../../utils/import.dart';

class TopicRepositoryImpl extends TopicRepository {
  // @override
  // Future<TopicModel?>? getTopicData(String topicID) async{
  //   return await serviceLocator<FirestoreService>.;
  // }

  @override
  Future<List<TopicModel>> fetchTopicsData() {
    return serviceLocator<FirestoreService>().fetchTopicsData();
  }

  @override
  Future<List<Map<TopicModel, bool>>> fetchPreferredTopicsData() {
    return serviceLocator<FirestoreService>().fetchPreferredTopicsData();
  }

  @override
  Future<List<TopicModel>> getRandomTopics() async {
     return serviceLocator<FirestoreService>().getRandomTopics();
  }

  @override
  Future<List<TopicModel>> fetchTopicsByField(List<TopicModel> selectedTopics, String matchValue) {
    return serviceLocator<FirestoreService>().fetchTopicsByField(selectedTopics, matchValue);
  }
}

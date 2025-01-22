import 'package:socialapp/domain/entities/topic.dart';

abstract class TopicRepository {
  // Future<TopicModel?>? getTopicData(String topicID);

  Future<List<TopicModel>> fetchTopicsData();

  Future<List<Map<TopicModel, bool>>> fetchPreferredTopicsData();

  Future<List<TopicModel>> getRandomTopics();

  Future<List<TopicModel>> fetchTopicsByField(List<TopicModel> selectedTopics, String matchValue);

// Future<void> addTopicData(AddTopicReq addTopicReq);

// Future<void> updateTopicData(UpdateTopicReq updateTopicReq);
}

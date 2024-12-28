import 'package:socialapp/domain/entities/topic.dart';

abstract class TopicRepository {
  // Future<TopicModel?>? getTopicData(String topicID);

  Future<List<TopicModel>> fetchTopicsData();

  Future<List<Map<TopicModel, bool>>> fetchPreferredTopicsData();

// Future<void> addTopicData(AddTopicReq addTopicReq);

// Future<void> updateTopicData(UpdateTopicReq updateTopicReq);
}

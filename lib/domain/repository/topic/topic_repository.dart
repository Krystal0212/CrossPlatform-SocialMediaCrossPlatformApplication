import 'package:socialapp/domain/entities/topic.dart';

abstract class TopicRepository {
  Future<TopicModel?>? getTopicData(String topicID);

  Future<List<TopicModel>?>? getTopicsData();

  // Future<void> addTopicData(AddTopicReq addTopicReq);

  // Future<void> updateTopicData(UpdateTopicReq updateTopicReq);
}
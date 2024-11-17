import 'package:socialapp/data/sources/firestore/firestore_service.dart';
import 'package:socialapp/domain/entities/topic.dart';
import 'package:socialapp/domain/repository/topic/topic_repository.dart';
import 'package:socialapp/service_locator.dart';

class TopicRepositoryImpl extends TopicRepository {
  @override
  Future<TopicModel?>? getTopicData(String topicID) {
    return null;
  }

  @override
  Future<List<TopicModel>?>? getTopicsData() {
    // return null;
    return serviceLocator<FirestoreService>().getTopicsData();
  }
}


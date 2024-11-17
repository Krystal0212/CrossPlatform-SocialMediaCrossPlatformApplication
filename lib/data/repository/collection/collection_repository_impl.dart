import 'package:socialapp/data/sources/firestore/firestore_service.dart';
import 'package:socialapp/domain/entities/collection.dart';
import 'package:socialapp/domain/repository/collection/collection_repository.dart';

import 'package:socialapp/service_locator.dart';


class CollectionRepositoryImpl extends CollectionRepository {
  @override
  Future<List<CollectionModel>?>? getCollections() {
    return serviceLocator.get<FirestoreService>().getCollections();
  }

  @override
  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList) {
    return serviceLocator<FirestoreService>()
        .getCollectionsData(collectionIDsList);
  }

  @override
  Future<List<String>> getCollectionPostsID(String collectionID){
    return serviceLocator<FirestoreService>().getCollectionPostsID(collectionID);
  }
}

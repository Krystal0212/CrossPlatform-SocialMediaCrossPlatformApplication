import 'package:socialapp/data/sources/firestore/collection_service_impl.dart';
import 'package:socialapp/domain/entities/collection.dart';
import 'package:socialapp/domain/repository/collection/collection_repository.dart';

import 'package:socialapp/service_locator.dart';

class CollectionRepositoryImpl extends CollectionRepository {
  @override
  Future<List<CollectionModel>?>? getCollections() {
    return serviceLocator.get<CollectionService>().getCollections();
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromOtherUser(String uid) {
    return serviceLocator<CollectionService>().getCollectionsFromOtherUser(uid);
  }

  @override
  Future<void> createCollection(String collectionName, bool isPublic) {
    return serviceLocator<CollectionService>()
        .createCollection(collectionName, isPublic);
  }

  @override
  Future<void> updateAssetsToCollection(CollectionModel collection) {
    return serviceLocator<CollectionService>()
        .updateAssetsToCollection(collection);
  }

  @override
  Future<void> updateTitleToCollection(
      String title, CollectionModel collection) {
    return serviceLocator<CollectionService>()
        .updateTitleToCollection(title, collection);
  }

  @override
  Future<void> removeOtherUserCollectionFromCurrentUser(
      CollectionModel collection) {
    return serviceLocator<CollectionService>()
        .removeOtherUserCollectionFromCurrentUser(collection);
  }

  @override
  Future<void> removeCurrentUserCollectionFromCurrentUser(
      CollectionModel collection) {
    return serviceLocator<CollectionService>()
        .removeCurrentUserCollectionFromCurrentUser(collection);
  }

  @override
  Future<List<CollectionModel>> getCollectionsFromCurrentUser(String uid) {
    return serviceLocator<CollectionService>()
        .getCollectionsFromCurrentUser(uid);
  }

  @override
  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid) {
    return serviceLocator<CollectionService>()
        .getCollectionsFromUserRealtime(uid);
  }
}

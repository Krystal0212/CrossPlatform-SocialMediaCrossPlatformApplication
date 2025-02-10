import 'package:socialapp/domain/entities/collection.dart';

abstract class CollectionRepository {

  Future<List<CollectionModel>> getCollectionsFromOtherUser(String uid);

  Future<void> createCollection(String collectionName, bool isPublic);

  Future<void> updateAssetsToCollection(CollectionModel collection);

  Future<void> updateTitleToCollection(
      String title, CollectionModel collection);

  Future<void> removeOtherUserCollectionFromCurrentUser(CollectionModel collection);

  Future<void> removeCurrentUserCollectionFromCurrentUser(CollectionModel collection);

  Future<List<CollectionModel>> getCollectionsFromCurrentUser(String uid);

  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid);

  Future<List<CollectionModel>> getCollectionsFromQuery(String query);

  Future<List<CollectionModel>> getCollectionsOrderByAssets();
}

import 'package:socialapp/domain/entities/collection.dart';

abstract class CollectionRepository {
  Future<List<CollectionModel>?>? getCollections();

  Future<List<String>> getCollectionPostsID(String collectionID);


  Future<List<CollectionModel>> getCollectionsFromUser(String uid);

  Future<void> createCollection(String collectionName, bool isPublic);

  Future<void> updateAssetsToCollection(CollectionModel collection);

  Future<void> updateTitleToCollection(String title, CollectionModel collection);

  Stream<List<CollectionModel>> getCollectionsFromUserRealtime(String uid);
}

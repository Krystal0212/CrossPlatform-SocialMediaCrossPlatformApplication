import 'package:socialapp/domain/entities/collection.dart';

abstract class CollectionRepository {
  Future<List<CollectionModel>?>? getCollections();

  // Future<void> createCollection(String name, String description);
  // Future<void> deleteCollection(String id);
  // Future<void> updateCollection(String id, String name, String description);
  // Future<void> addPostToCollection(String collectionId, String postId);
  // Future<void> removePostFromCollection(String collectionId

  Future<List<CollectionModel>> getCollectionsData(
      List<String> collectionIDsList);

  Future<List<String>> getCollectionPostsID(String collectionID);
}

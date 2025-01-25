import 'package:socialapp/utils/import.dart';
import 'collection_state.dart';

class CollectionPostCubit extends Cubit<CollectionPostState> {
  bool isCurrentUser = false;

  CollectionPostCubit(String uid) : super(CollectionPostInitial()) {
    _initialize(uid);
  }

  void _initialize(String uid) async {
    final User? currentUser =
        await serviceLocator<AuthRepository>().getCurrentUser();
    if (currentUser?.uid == uid) {
      isCurrentUser = true;
    }
    getCollectionsOfUser(uid);
  }

  Future<void> getCollectionsOfUser(String uid) async {
    try {
      List<CollectionModel> collections =
          await serviceLocator<CollectionRepository>()
              .getCollectionsFromUser(uid);

      emit(CollectionPostLoaded(collections));
    } catch (error) {
      debugPrint('Error fetching collections: $error');
    }
  }

// Future<void> fetchAllCollectionImages(List<CollectionModel> collections) async {
//   try {
//     final User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();
//     Map<String, List<String?>> collectionImagesMap = {};
//
//     for (var collection in collections) {
//       List<String?> collectionPostImages = await _getImagesOfCollection(collection.collectionId);
//       collectionImagesMap[collection.collectionId] = collectionPostImages;
//     }
//   } catch (error) {
//     debugPrint('Error fetching collection images: $error');
//   }
// }
//
// Future<List<String?>> _getImagesOfCollection(String collectionID) async {
//   List<String?> collectionPostImages = [];
//   List<String> collectionPostsID =
//       await serviceLocator<CollectionRepository>()
//           .getCollectionPostsID(collectionID);
//   for (String postId in collectionPostsID) {
//     String? imageUrls =
//         await serviceLocator<PostRepository>().getPostImageById(postId);
//     collectionPostImages.add(imageUrls);
//   }
//   return collectionPostImages;
// }
}

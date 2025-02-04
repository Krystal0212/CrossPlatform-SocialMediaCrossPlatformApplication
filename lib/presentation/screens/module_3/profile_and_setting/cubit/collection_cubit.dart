import 'package:socialapp/utils/import.dart';
import 'collection_state.dart';

class CollectionPostCubit extends Cubit<CollectionPostState> {
  bool isCurrentUser = false;
  final String userId;

  CollectionPostCubit({required this.userId}) : super(CollectionPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    final User? currentUser =
        await serviceLocator<AuthRepository>().getCurrentUser();
    if (currentUser?.uid == userId) {
      isCurrentUser = true;
    }
    getCollectionsOfUser();
  }

  Future<void> getCollectionsOfUser() async {
    try {
      List<CollectionModel> collections =
          await serviceLocator<CollectionRepository>()
              .getCollectionsFromUser(userId);

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

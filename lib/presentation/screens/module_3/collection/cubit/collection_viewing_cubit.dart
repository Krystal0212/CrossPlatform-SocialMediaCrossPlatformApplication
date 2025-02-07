import 'package:socialapp/utils/import.dart';
import 'collection_viewing_state.dart';

class CollectionViewingCubit extends Cubit<CollectionViewingState> {
  bool isCurrentUser = false;
  final String userId;
  final CollectionModel collection;

  CollectionViewingCubit({required this.userId, required this.collection})
      : super(CollectionViewingInitial()) {
    _initialize();
  }

  void _initialize() async {
    final UserModel? currentUser =
        await serviceLocator<UserRepository>().getCurrentUserData();
    if (currentUser?.id == userId) {
      isCurrentUser = true;
    }

    List<PreviewAssetPostModel> imagePreviews = collection.assets;

    emit(CollectionViewingLoaded(imagePreviews, isCurrentUser));
  }

  void updateCollectionName(String title) async {
    await serviceLocator<CollectionRepository>()
        .updateTitleToCollection(title, collection);
  }

  void updateCollectionData(List<PreviewAssetPostModel> imagePreviews) async {
    collection.assets = imagePreviews;

    await serviceLocator<CollectionRepository>()
        .updateAssetsToCollection(collection);
  }

  void removeOtherUserCollectionFormCurrentUser() async {
    await serviceLocator<CollectionRepository>().removeOtherUserCollectionFromCurrentUser(collection);
  }

  void removeCurrentUserCollectionFromCurrentUser() async {
    await serviceLocator<CollectionRepository>()
        .removeCurrentUserCollectionFromCurrentUser(collection);
  }
}

import 'package:socialapp/utils/import.dart';

import 'collection_picker_state.dart';

class CollectionPickerCubit extends Cubit<CollectionPickerState> {
  bool isCurrentUser = false;
  final String userId;

  CollectionPickerCubit({required this.userId}) : super(CollectionPickerPostInitial()) {
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
          .getCollectionsFromCurrentUser(userId);

      emit(CollectionPickerPostLoaded(collections));
    } catch (error) {
      if(error is CustomFirestoreException && error.code=='no-topics'){
        emit(CollectionPickerPostLoaded([]));
      }
      else {
        debugPrint('Error fetching collections: $error');
      }
    }
  }

  Future<void> addToCollection(
      CollectionModel collection,
      String postId,
      final int? selectedAssetOrder,
      Map<String, OnlineMediaItem> medias,  // Key is the media order as String
      ) async {
    try {
      bool isCollectionChanged = false;
      bool isNSFW = false;

      if (selectedAssetOrder != null) {
        OnlineMediaItem? asset = medias[selectedAssetOrder.toString()];  // Use the order as a String key

        if (asset != null) {
          Map<String, dynamic> chosenPreviewAsset = {};
          Map<String, dynamic> chosenAsset = asset.toMap();

          chosenPreviewAsset['postId'] = postId;
          chosenPreviewAsset['mediasOrThumbnailUrl'] = chosenAsset['thumbnailUrl'] ?? chosenAsset['imageUrl'];
          chosenPreviewAsset['mediaOrder'] = selectedAssetOrder;
          chosenPreviewAsset['height'] = chosenAsset['height'];
          chosenPreviewAsset['width'] = chosenAsset['width'];
          chosenPreviewAsset['isVideo'] = chosenAsset['type'] == 'video';
          chosenPreviewAsset['isNSFW'] = chosenAsset['isNSFW'];
          chosenPreviewAsset['dominantColor'] = chosenAsset['dominantColor'];

          PreviewAssetPostModel newAsset = PreviewAssetPostModel.fromMap(chosenPreviewAsset);

          // Check if the asset is not already in the collection before adding
          if (!collection.assets.contains(newAsset)) {
            collection.assets.add(newAsset);
            isCollectionChanged = true;
          }
        }
      } else {
        // Iterate over all the assets in the map
        for (var entry in medias.entries) {
          String key = entry.key;  // This is the media order as String
          OnlineMediaItem asset = entry.value;

          Map<String, dynamic> previewAsset = {};
          Map<String, dynamic> assetData = asset.toMap();

          previewAsset['postId'] = postId;
          previewAsset['mediasOrThumbnailUrl'] = assetData['thumbnailUrl'] ?? assetData['imageUrl'];
          previewAsset['mediaOrder'] = int.parse(key);  // Use the key as mediaOrder
          previewAsset['height'] = assetData['height'];
          previewAsset['width'] = assetData['width'];
          previewAsset['isVideo'] = assetData['type'] == 'video';
          previewAsset['isNSFW'] = assetData['isNSFW'];
          previewAsset['dominantColor'] = assetData['dominantColor'];

          PreviewAssetPostModel newAsset = PreviewAssetPostModel.fromMap(previewAsset);

          if (!collection.assets.contains(newAsset)) {
            collection.assets.add(newAsset);
            isCollectionChanged = true;
          }
        }
      }

      if (isCollectionChanged) {
        await serviceLocator<CollectionRepository>().updateAssetsToCollection(collection);
      }
    } catch (error) {
      debugPrint('Error adding collection: $error');
    }
  }



  Future<void> createCollection(TextEditingController collectionNameController, bool isPublic) async {
    try {
      String collectionName = collectionNameController.text.trim();
      if (collectionName.isEmpty) return;

      await serviceLocator<CollectionRepository>().createCollection(collectionName, isPublic);
    } catch (error){
      debugPrint('Error creating collection: $error');
    }

  }
}

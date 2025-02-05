import 'package:socialapp/utils/import.dart';

abstract class CollectionViewingState {
}

class CollectionViewingInitial extends CollectionViewingState {}

class CollectionViewingLoading extends CollectionViewingState {}

class CollectionViewingLoaded extends CollectionViewingState {
  final List<PreviewAssetPostModel> imagePreviews;
  final bool isOwner;

  CollectionViewingLoaded(this.imagePreviews, this.isOwner);
}

class CollectionViewingError extends CollectionViewingState {}
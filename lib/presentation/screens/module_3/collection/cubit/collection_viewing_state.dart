import 'package:socialapp/utils/import.dart';

abstract class CollectionViewingState {
}

class CollectionViewingInitial extends CollectionViewingState {}

class CollectionViewingLoading extends CollectionViewingState {}

class CollectionViewingLoaded extends CollectionViewingState {
  final List<PreviewAssetPostModel> imagePreviews;
  final bool isOwner;
  final bool isNSFWTurnOn;

  CollectionViewingLoaded(this.imagePreviews, this.isOwner, this.isNSFWTurnOn);
}

class CollectionViewingError extends CollectionViewingState {}
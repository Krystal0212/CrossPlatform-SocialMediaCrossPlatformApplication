import '../../../../../utils/import.dart';

abstract class MediaPostState {}

class MediaPostInitial extends MediaPostState {}

class MediaPostLoading extends MediaPostState {}

class MediaPostLoaded extends MediaPostState {
  final List<PreviewAssetPostModel> imageUrls;

  MediaPostLoaded(this.imageUrls);
}

class MediaPostError extends MediaPostState {}

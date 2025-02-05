import '../../../../../utils/import.dart';

abstract class  ShotViewingPostState {}

class  ShotViewingPostInitial extends  ShotViewingPostState {}

class  ShotViewingPostLoading extends  ShotViewingPostState {}

class  ShotViewingPostLoaded extends  ShotViewingPostState {
  final List<PreviewAssetPostModel> posts;

  ShotViewingPostLoaded(this.posts);
}

class  ShotViewingPostError extends  ShotViewingPostState {}

import '../../../../../utils/import.dart';

abstract class  ShotPostState {}

class  ShotPostInitial extends  ShotPostState {}

class  ShotPostLoading extends  ShotPostState {}

class  ShotPostLoaded extends  ShotPostState {
  final Stream<List<PreviewAssetPostModel>?> postStreams;

   ShotPostLoaded(this.postStreams);
}

class  ShotPostError extends  ShotPostState {}

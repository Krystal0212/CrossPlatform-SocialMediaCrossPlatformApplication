import '../../../../../utils/import.dart';

abstract class  ShotPostState {}

class  ShotPostInitial extends  ShotPostState {}

class  ShotPostLoading extends  ShotPostState {}

class  ShotPostLoaded extends  ShotPostState {
  final Stream<List<PreviewAssetPostModel>?> postStreams;
  final UserModel? currentUser;

   ShotPostLoaded(this.postStreams, this.currentUser);
}

class  ShotPostError extends  ShotPostState {}

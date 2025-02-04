import 'package:socialapp/utils/import.dart';

abstract class ViewingState {}

class ViewingInitial extends ViewingState {}

class ViewingLoading extends ViewingState {}

class ViewingLoaded extends ViewingState {
  final UserModel userModel;
  final List<String> userFollowers;
  final List<String> userFollowings;
  final int mediasNumber;
  final int collectionsNumber;
  final int recordsNumber;
  final bool isFollowed;

  ViewingLoaded(
      this.userModel,
      this.userFollowers,
      this.userFollowings,
      this.mediasNumber,
      this.collectionsNumber,
      this.recordsNumber,
      this.isFollowed);
}

class ViewingError extends ViewingState {}

import 'package:socialapp/utils/import.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdated extends ProfileState{
  final UserModel userModel;
  final List<String> userFollowers;
  final List<String> userFollowings;
  final int mediasNumber;
  final int collectionsNumber;

  ProfileUpdated(this.userModel, this.userFollowers, this.userFollowings, this.mediasNumber, this.collectionsNumber);
}

class ProfileLoaded extends ProfileState {
  final Stream<UserModel?> userDataStream;
  final List<String> userFollowers;
  final List<String> userFollowings;
  final int mediasNumber;
  final int collectionsNumber;
  final int recordsNumber;

  ProfileLoaded(this.userDataStream, this.userFollowers, this.userFollowings, this.mediasNumber, this.collectionsNumber, this.recordsNumber);
}

class ProfileLoggedOut extends ProfileState{}

class ProfileEmailChanged extends ProfileState{}

class ProfileError extends ProfileState {
}



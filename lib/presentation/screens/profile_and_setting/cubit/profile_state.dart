import 'package:socialapp/domain/entities/collection.dart';

import '../../../../domain/entities/user.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdated extends ProfileState{
  final UserModel userModel;
  final List<String> userFollowers;
  final List<String> userFollowings;
  final List<CollectionModel> collections;

  ProfileUpdated(this.userModel, this.userFollowers, this.userFollowings, this.collections);
}

class ProfileLoaded extends ProfileState {
  final UserModel userModel;
  final List<String> userFollowers;
  final List<String> userFollowings;
  final List<CollectionModel> collections;

  ProfileLoaded(this.userModel, this.userFollowers, this.userFollowings, this.collections);
}

class ProfileLoggedOut extends ProfileState{}

class ProfileEmailChanged extends ProfileState{}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}



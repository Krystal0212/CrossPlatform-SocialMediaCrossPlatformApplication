import 'package:socialapp/utils/import.dart';

abstract class PostDataLoadedState {}

class PostDataLoadedInitial extends PostDataLoadedState {}

class PostDataLoaded extends PostDataLoadedState {
  final OnlinePostModel post;

  PostDataLoaded(this.post);
}

class PostDataLoadedError extends PostDataLoadedState {
  final String error;

  PostDataLoadedError(this.error);
}

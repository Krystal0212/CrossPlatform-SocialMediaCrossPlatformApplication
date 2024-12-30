

import 'package:socialapp/utils/import.dart';

enum ViewMode { popular, trending, fol }


class HomeLoading extends HomeState{}

class HomeLoadedPostsSuccess extends HomeState {
  final List<PostModel> posts; // Example data, replace with your actual model

  HomeLoadedPostsSuccess(this.posts);
}


abstract class HomeState {}

class HomeViewModeInitial extends HomeState {
  final ViewMode viewMode;

  HomeViewModeInitial(this.viewMode);
}

class HomeViewModeChanged extends HomeState {
  final ViewMode viewMode;

  HomeViewModeChanged(this.viewMode);
}

class HomeFailure extends HomeState{
  final String errorMessage;

  HomeFailure(this.errorMessage);
}
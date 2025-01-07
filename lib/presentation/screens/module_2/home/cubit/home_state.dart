

import 'package:socialapp/utils/import.dart';

enum ViewMode { explore, trending, following }


class HomeLoading extends HomeState{}

class HomeLoadedPostsSuccess extends HomeState {
  final List<List<PostModel>> postLists; // Example data, replace with your actual model

  HomeLoadedPostsSuccess(this.postLists);
}


abstract class HomeState {}

class HomeViewModeInitial extends HomeState {
}

class HomeFailure extends HomeState{
  final String errorMessage;

  HomeFailure(this.errorMessage);
}

class HomeConnectivityChanged extends HomeState {
  final ConnectivityResult connectivityResult;

  HomeConnectivityChanged(this.connectivityResult);
}
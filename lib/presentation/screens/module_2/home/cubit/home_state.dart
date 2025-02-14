

import 'package:socialapp/utils/import.dart';

enum ViewMode { explore, trending, following }


class HomeLoading extends HomeState{}

class HomeLoadedPostsSuccess extends HomeState {
  final List<List<OnlinePostModel>> postLists; // Example data, replace with your actual model

  HomeLoadedPostsSuccess(this.postLists);
}

class HomeOffline extends HomeState{}

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
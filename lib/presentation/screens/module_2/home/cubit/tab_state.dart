import 'package:socialapp/utils/import.dart';

class TabState {}

class TabLoading extends TabState {}

class TabLoaded extends TabState {
  final List<OnlinePostModel> posts;

  TabLoaded(this.posts);
}

class TabOffline extends TabState {}

class TabError extends TabState {
  final String error;

  TabError(this.error);
}

class TabNotSignIn extends TabState {
}


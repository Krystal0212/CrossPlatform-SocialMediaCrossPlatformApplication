import 'package:socialapp/domain/entities/post.dart';

abstract class SearchState{}

class SearchInitial extends SearchState{}

class SearchFinding extends SearchState{}

class SearchLoaded extends SearchState{
  final List<OnlinePostModel> posts;

  SearchLoaded(this.posts);
}
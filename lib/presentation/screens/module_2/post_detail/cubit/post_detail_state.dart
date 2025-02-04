
abstract class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailCommentLoaded extends PostDetailState{}

class PostDetailError extends PostDetailState{
  final String error;
  PostDetailError(this.error);
}
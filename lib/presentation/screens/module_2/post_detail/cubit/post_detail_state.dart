
abstract class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailCommentLoaded extends PostDetailState{}

class PostDetailChangeContentLoading extends PostDetailState{}

class PostDetailChangeContentSuccess extends PostDetailState{}

class PostDetailDeleteSuccess extends PostDetailState{}

class PostDetailError extends PostDetailState{
  final String error;
  PostDetailError(this.error);
}
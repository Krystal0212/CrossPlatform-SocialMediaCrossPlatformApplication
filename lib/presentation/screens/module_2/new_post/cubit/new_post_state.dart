
abstract class NewPostState {}

class PostInitial extends NewPostState {}

class PostError extends NewPostState{
  final String error;
  PostError(this.error);
}
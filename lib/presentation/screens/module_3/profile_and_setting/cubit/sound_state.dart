abstract class SoundPostState {}

class SoundPostInitial extends SoundPostState {}

class SoundPostLoading extends SoundPostState {}

class SoundPostLoaded extends SoundPostState {
  final List<String> imageUrls;

  SoundPostLoaded(this.imageUrls);
}

class SoundPostError extends SoundPostState {}

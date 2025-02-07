import 'package:socialapp/domain/entities/sound.dart';

abstract class SoundPostState {}

class SoundPostInitial extends SoundPostState {}

class SoundPostLoading extends SoundPostState {}

class SoundPostLoaded extends SoundPostState {
  final Stream<List<PreviewSoundPostModel>?> postStreams;

  SoundPostLoaded(this.postStreams);
}

class SoundPostError extends SoundPostState {}

import 'package:socialapp/domain/entities/sound.dart';

abstract class SoundViewingTabState {}

class SoundViewingTabInitial extends SoundViewingTabState {}

class SoundViewingTabLoading extends SoundViewingTabState {}

class SoundViewingTabLoaded extends SoundViewingTabState {
  final List<PreviewSoundPostModel> soundPosts;

  SoundViewingTabLoaded(this.soundPosts);
}

class SoundViewingTabError extends SoundViewingTabState {}

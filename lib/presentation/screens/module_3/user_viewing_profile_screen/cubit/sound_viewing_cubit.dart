import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';
import 'sound_viewing_state.dart';

class SoundViewingTabCubit extends Cubit<SoundViewingTabState> {
  final String userId;

  SoundViewingTabCubit({required this.userId})
      : super(SoundViewingTabInitial()) {
    _initialize();
  }

  void _initialize() async {
    getSoundForUserPosts();
  }

  Future<void> getSoundForUserPosts() async {
    emit(SoundViewingTabLoading());

    try {
      List<PreviewSoundPostModel> soundPosts =
          await serviceLocator<PostRepository>().getSoundPostsByUserId(userId);

      emit(SoundViewingTabLoaded(soundPosts));
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(SoundViewingTabError());
    }
  }
}

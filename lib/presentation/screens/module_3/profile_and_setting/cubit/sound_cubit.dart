import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';
import 'sound_state.dart';

class SoundPostCubit extends Cubit<SoundPostState> {
  SoundPostCubit() : super(SoundPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getSoundForUserPostsStream();
  }

  Future<void> getSoundForUserPostsStream() async {
    emit(SoundPostLoading());
    final User? user = await serviceLocator<AuthRepository>().getCurrentUser();

    try {
      if (user != null) {
        Stream<List<PreviewSoundPostModel>?> postStreams =
            serviceLocator<PostRepository>()
                .getSoundPostsByUserIdRealTime(user.uid);

        emit(SoundPostLoaded(postStreams));
      } else {
        if (kDebugMode) {
          print('Error fetching user data for shot tab: User is null');
        }
        emit(SoundPostError());
      }
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(SoundPostError());
    }
  }
}

import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';
import 'sound_state.dart';

class SoundPostCubit extends Cubit<SoundPostState> {
  final String userId;

  SoundPostCubit({required this.userId}) : super(SoundPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getSoundForUserPostsStream();

  }

  Future<void> getSoundForUserPostsStream() async {
    emit(SoundPostLoading());

    try {

      Stream<List<PreviewSoundPostModel>?> postStreams = serviceLocator<PostRepository>()
          .getSoundPostsByUserIdRealTime(userId);


      emit(SoundPostLoaded(postStreams));
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(SoundPostError());
    }
  }
}

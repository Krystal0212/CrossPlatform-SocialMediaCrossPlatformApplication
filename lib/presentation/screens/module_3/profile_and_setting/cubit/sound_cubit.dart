import 'package:socialapp/utils/import.dart';
import 'profile_state.dart';
import 'sound_state.dart';

class SoundPostCubit extends Cubit<SoundPostState> {
  SoundPostCubit() : super(SoundPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    // await getImageUrlsForUserPosts();

  }
}

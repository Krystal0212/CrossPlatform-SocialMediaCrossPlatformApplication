import 'package:socialapp/presentation/screens/module_3/profile_and_setting/cubit/shot_state.dart';
import 'package:socialapp/utils/import.dart';

class ShotPostCubit extends Cubit<ShotPostState> {
  ShotPostCubit() : super(ShotPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getImageUrlsForUserPostsStream();
  }

  Future<void> getImageUrlsForUserPostsStream() async {
    emit(ShotPostLoading());
    final User? user = await serviceLocator<AuthRepository>().getCurrentUser();

    try {
      if (user != null) {
        Stream<List<PreviewAssetPostModel>?> postStreams =
            serviceLocator<PostRepository>()
                .getAssetPostsByUserIdRealTime(user.uid);

        UserModel? currentUser =
            await serviceLocator<UserRepository>().getCurrentUserData();

        emit(ShotPostLoaded(postStreams, currentUser));
      }
      else{
        if (kDebugMode) {
          print('Error fetching user data for shot tab: User is null');
        }
        emit(ShotPostError());
      }
    } catch (error) {
      debugPrint("Error fetching image URLs: $error");
      emit(ShotPostError());
    }
  }
}

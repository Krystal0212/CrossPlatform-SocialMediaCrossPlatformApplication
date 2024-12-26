
import 'package:socialapp/utils/import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  AuthRepository authRepository = AuthRepositoryImpl();
  UserRepository userRepository = UserRepositoryImpl();
  CollectionRepository collectionRepository = CollectionRepositoryImpl();
  PostRepository postRepository = PostRepositoryImpl();

  ProfileCubit() : super(ProfileLoading());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final User? currentUser = await authRepository.getCurrentUser();
      final UserModel? userModel = await userRepository.getCurrentUserData();

      final userFollowers =
          await userRepository.getUserFollowers(currentUser!.uid);
      final userFollowings =
          await userRepository.getUserFollowings(currentUser.uid);
      final userCollectionIDs =
          await userRepository.getUserCollectionIDs(currentUser.uid);
      final List<CollectionModel> collections =
          await collectionRepository.getCollectionsData(userCollectionIDs);

      if (userModel != null) {
        emit(ProfileLoaded(
            userModel, userFollowers, userFollowings, collections));
      } else {
        emit(ProfileError("User data not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      await userRepository.updateCurrentUserData(updatedUser);
      fetchProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfileWithEmail(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      updatedUser.resetState();
      await userRepository.updateCurrentUserData(updatedUser);

      emit(ProfileEmailChanged());
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(ProfileError(e.toString()));
      } else {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError('Logout failed: $e'));
    }
  }
}

import 'package:socialapp/utils/import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final User? currentUser =
          await serviceLocator<AuthRepository>().getCurrentUser();
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getCurrentUserData();

      if (currentUser != null) {
        final userFollowers = await serviceLocator<UserRepository>()
            .getUserRelatedData(currentUser.uid, 'followers');
        final userFollowings = await serviceLocator<UserRepository>()
            .getUserRelatedData(currentUser.uid, 'followings');
        final userCollectionIDs = await serviceLocator<UserRepository>()
            .getUserRelatedData(currentUser.uid, 'collections');
        final List<CollectionModel> collections =
            await serviceLocator<CollectionRepository>()
                .getCollectionsData(userCollectionIDs);

        if (userModel != null) {
          emit(ProfileLoaded(
              userModel, userFollowers, userFollowings, collections));
        } else {
          emit(ProfileError("User data not found"));
        }
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      await serviceLocator<UserRepository>().updateCurrentUserData(updatedUser);
      fetchProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfileWithEmail(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      updatedUser.resetState();
      await serviceLocator<UserRepository>().updateCurrentUserData(updatedUser);

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
      await serviceLocator<AuthRepository>().signOut();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError('Logout failed: $e'));
    }
  }
}

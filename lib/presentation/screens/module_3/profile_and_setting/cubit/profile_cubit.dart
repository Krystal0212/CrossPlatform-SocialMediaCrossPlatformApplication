import 'package:socialapp/utils/import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial()) {
    _initialize();
  }

  void _initialize() async {
    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final User? currentUser =
          await serviceLocator<AuthRepository>().getCurrentUser();
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getCurrentUserData();

      if (currentUser != null) {
        Map<String, dynamic> userRelatedMap =
            await serviceLocator<UserRepository>()
                .getUserRelatedData(currentUser.uid);

        final List<String> userFollowers = List<String>.from(userRelatedMap['followers'] ?? []);
        final List<String> userFollowings = List<String>.from(userRelatedMap['followings'] ?? []);
        final int collectionNumber =
            (userRelatedMap['collectionsNumber'] as int);
        final int mediaNumber = (userRelatedMap['mediasNumber'] as int);
        final int recordNumber = (userRelatedMap['recordsNumber'] as int);

        if (userModel != null) {
          emit(ProfileLoaded(userModel, userFollowers, userFollowings,
              mediaNumber, collectionNumber, recordNumber));
        } else {
          throw "User data not found";
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
    }
  }

  Future<List<PreviewAssetPostModel>> getImageUrlsForUserPosts(String userId) async {
    List<OnlinePostModel>? posts =
        await serviceLocator<PostRepository>().getPostsByUserId(userId);
    List<PreviewAssetPostModel> imageUrls = [];

    if (posts != null) {
      for (OnlinePostModel post in posts) {
        List<PreviewAssetPostModel> imageUrlsForPost = await serviceLocator<PostRepository>()
            .getPostImagesByPostId(post.postId);
        if (imageUrlsForPost.isNotEmpty) {
          imageUrls.addAll(imageUrlsForPost);
        }
      }
    }

    return imageUrls;
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      await serviceLocator<UserRepository>().updateCurrentUserData(updatedUser);
      fetchProfile();
    } catch (e) {
      emit(ProfileError());

      debugPrint('Failed to update profile: $e');
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
        debugPrint('Failed to update profile\'s email: $e');

        emit(ProfileError());
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
      debugPrint('Logout failed: $e');
      emit(ProfileError());
    }
  }
}

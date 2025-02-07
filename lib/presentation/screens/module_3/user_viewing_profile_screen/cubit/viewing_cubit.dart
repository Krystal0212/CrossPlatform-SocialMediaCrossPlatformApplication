import 'package:socialapp/utils/import.dart';
import 'Viewing_state.dart';

class ViewingCubit extends Cubit<ViewingState> {
  final String userId;
  Timer? _syncTimer;
  bool? followingStatus;


  ViewingCubit({required this.userId}) : super(ViewingInitial()) {
    _startPeriodicSync();
    _initialize();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await serviceLocator<UserRepository>().followOrUnfollowUser(userId, followingStatus);
    });
  }

  void addFollowing() {
    followingStatus = true;
  }

  // Remove like status for a post
  void removeFollowing() {
    followingStatus = false;
  }

  void _initialize() async {
    await fetchViewing();
  }

  Future<void> fetchViewing() async {
    emit(ViewingLoading());
    try {
      final User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getUserData(userId);

      Map<String, dynamic> userRelatedMap =
          await serviceLocator<UserRepository>()
              .getUserRelatedData(userId);

      final List<String> userFollowers =
          List<String>.from(userRelatedMap['followers'] ?? []);
      final List<String> userFollowings =
          List<String>.from(userRelatedMap['followings'] ?? []);
      final int collectionNumber = (userRelatedMap['collectionsNumber'] as int);
      final int mediaNumber = (userRelatedMap['mediasNumber'] as int);
      final int recordNumber = (userRelatedMap['recordsNumber'] as int);
      final bool isFollowed = userFollowers.contains(currentUser?.uid);

      if (userModel != null) {
        emit(ViewingLoaded(userModel, userFollowers, userFollowings,
            mediaNumber, collectionNumber, recordNumber, isFollowed));
      } else {
        throw "User data not found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching Viewing: $e");
      }
    }
  }

  Future<List<PreviewAssetPostModel>> getImageUrlsForUserPosts(
      String userId) async {
    List<OnlinePostModel>? posts =
        await serviceLocator<PostRepository>().getAssetPostsByUserId(userId);
    List<PreviewAssetPostModel> imageUrls = [];

    if (posts != null) {
      for (OnlinePostModel post in posts) {
        List<PreviewAssetPostModel> imageUrlsForPost =
            await serviceLocator<PostRepository>()
                .getPostImagesByPostId(post.postId);
        if (imageUrlsForPost.isNotEmpty) {
          imageUrls.addAll(imageUrlsForPost);
        }
      }
    }

    return imageUrls;
  }

  @override
  Future<void> close() async {
    await serviceLocator<UserRepository>().followOrUnfollowUser(userId, followingStatus);
    _syncTimer?.cancel();
    super.close();
  }

}

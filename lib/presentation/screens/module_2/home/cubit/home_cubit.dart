import 'package:socialapp/utils/import.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final Map<String, bool> likedPostsCache = {};
  final Map<String, bool> viewedPostsCache = {};

  final BuildContext homeContext;
  bool isBackgroundFetchComplete = false;

  Timer? _syncTimer;
  UserModel? currentUser;

  HomeCubit({required this.homeContext}) : super(HomeViewModeInitial()) {
    _checkIsUserVerified(homeContext);

    _startPeriodicSync();
  }

  bool checkCurrentUserSignedIn() {
    return serviceLocator<AuthRepository>().isSignedIn();
  }

  Future<bool> checkCurrentUser() async {
    try {
      final user = await serviceLocator<UserRepository>().getCurrentUserData();
      if (user == null) {
        return false;
      } else {
        currentUser = user;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Check user data: $e");
      }
      return false;
    }
  }

  Future<bool> checkOnline() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      bool isOnline = await checkOnline();
      if (isOnline) {
        await serviceLocator<PostRepository>()
            .syncLikesToFirestore(likedPostsCache);
        await serviceLocator<PostRepository>().syncViewsToFirestore(viewedPostsCache);

      }
    });
  }

  void triggerSync() async {
    bool isOnline = await checkOnline();
    if (isOnline) {
      await serviceLocator<PostRepository>()
          .syncLikesToFirestore(likedPostsCache);
      await serviceLocator<PostRepository>().syncViewsToFirestore(viewedPostsCache);

    }
  }

  Future<void> addViewCount(String postId) async {
    viewedPostsCache.putIfAbsent(postId, () => true);
  }

  void addPostLike(String postId) {
    likedPostsCache.putIfAbsent(postId, () => true);
    likedPostsCache[postId] = true;
  }

  // Remove like status for a post
  void removePostLike(String postId) {
    likedPostsCache.putIfAbsent(postId, () => false);
    likedPostsCache[postId] = false;
  }

  Future<void> _checkIsUserVerified(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isSignedInNotVerified = prefs.getBool('signed-in-not-verified') ?? false;

    if(isSignedInNotVerified) {
      if (!context.mounted) return;
      context.go('/verify',
          extra: {"isFromSignIn": true});
    }

  }

  Future<void> logout() async {
    if (isClosed) return;
    try {
      triggerSync();
      emit(HomeLoading());
      await serviceLocator<AuthRepository>().signOut();
      currentUser = null;
      if (!isClosed) {
        emit(HomeViewModeInitial());
      }
    } catch (e) {
      emit(HomeFailure('Logout failed: ${e.toString()}'));
    }
  }

  void setBackgroundFetchComplete(bool isComplete) {
    isBackgroundFetchComplete = isComplete;
  }

  UserModel? getCurrentUser() {
    return currentUser;
  }

  Future<void> showLessSimilarPosts(String postId) async {
    try {
      await serviceLocator<PostRepository>()
          .reduceTopicRanksOfPostForCurrentUser(postId);
    } catch (error) {
      if (kDebugMode) {
        print('Error update less similar posts for user: $error');
      }
    }
  }

  @override
  Future<void> close() {
    triggerSync();
    _syncTimer?.cancel();
    return super.close();
  }
}

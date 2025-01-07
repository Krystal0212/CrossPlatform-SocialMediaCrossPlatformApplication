import 'package:socialapp/utils/import.dart';
import 'home_state.dart';
import 'dart:async';

class HomeCubit extends Cubit<HomeState> {
  final Connectivity connectivity = Connectivity();
  final Map<String, Map<String, bool>> likedPostsCache = {};
  Timer? _syncTimer;

  List<PostModel> explorePosts = [];
  List<PostModel> trendingPosts = [];
  List<PostModel> followingPosts = [];
  bool isExploreFetched = false, isTrendingFetched = false, isFollowingFetched = false;
  UserModel? currentUser;

  bool isBackgroundFetchComplete = false;
  StreamSubscription? _connectivitySubscription;

  HomeCubit()
      :super(HomeViewModeInitial()) {
    _startPeriodicSync();
    if (kIsWeb) {
      _loadData(false);
    } else {
      _listenToConnectivity();
      // _setupBackgroundFetch();
    }
  }

  bool checkCurrentUserSignedIn(){
   return serviceLocator<AuthRepository>().isSignedIn();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        final connectivityResult = connectivityList.isNotEmpty
            ? connectivityList.first
            : ConnectivityResult.none;

        // Trigger _loadData whenever connectivity changes
        if (connectivityResult != ConnectivityResult.none) {
          isExploreFetched = false;
          _loadData(false);
        } else {
          _loadData(true);
        }
      },
    );
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await serviceLocator<PostService>().syncLikesToFirestore(likedPostsCache);
    });
  }

  void addPostLike(String postId, String userId) {
    likedPostsCache.putIfAbsent(postId, () => {});
    likedPostsCache[postId]?[userId] = true;
    if (kDebugMode) {
      print('Added like: Post $postId -> User $userId');
    }
  }

  void removePostLike(String postId, String userId) {
    likedPostsCache.putIfAbsent(postId, () => {});
    likedPostsCache[postId]?[userId] = false;

    if (kDebugMode) {
      print('Removed like: Post $postId -> User $userId');
    }
  }

  void _setupBackgroundFetch() {
    Workmanager().registerPeriodicTask(
      "Firestore services",
      "fetchFirestoreData",
      frequency: const Duration(minutes: 15), // Adjust as needed
      inputData: {'isOffline': false}, // Fetch online data
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    setBackgroundFetchComplete(false);
    return super.close();
  }

  Future<bool> checkCurrentUser() async {
    try {
      final UserModel? user =
          await serviceLocator<UserRepository>().getCurrentUserData();
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

  void setBackgroundFetchComplete(bool isComplete) {
    isBackgroundFetchComplete = isComplete;
  }

  UserModel? getCurrentUser() {
    return currentUser;
  }


  ///////////////////////////////////
  /////////////////////////////////
  ///////////////////////////////

  void reset(ViewMode viewMode) {
    // emit(HomeViewModeInitial(viewMode));
    // _loadData(viewMode);
  }

  void _loadData( bool isOffline) async {
    emit(HomeLoading());

    bool isSignedIn = serviceLocator<AuthRepository>().isSignedIn();

    if (!isBackgroundFetchComplete && !isExploreFetched) {
      explorePosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
    }

    if (!isBackgroundFetchComplete && !isTrendingFetched) {
      trendingPosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
      isTrendingFetched = true;
    }

    if (!isBackgroundFetchComplete && !isFollowingFetched && isSignedIn) {
      followingPosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
      isFollowingFetched = true;
    }

    try {
      List<List<PostModel>> postList = [explorePosts, trendingPosts, explorePosts];

      if (!isClosed) {
        emit(HomeLoadedPostsSuccess(postList));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeFailure('Failed to load data'));
      }
    }
  }

  Future<void> logout() async {
    if (isClosed) return;
    try {
      emit(HomeLoading());

      await serviceLocator<AuthRepository>().signOut();

      currentUser = null;
      isExploreFetched = false;


      if (!isClosed) {
        emit(HomeViewModeInitial());
      }
    } catch (e) {
      emit(HomeFailure('Logout failed: ${e.toString()}'));
    }
  }
}

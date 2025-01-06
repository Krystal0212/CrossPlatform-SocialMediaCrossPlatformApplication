import 'package:socialapp/utils/import.dart';
import 'home_state.dart';
import 'dart:async';

class HomeCubit extends Cubit<HomeState> {
  final Connectivity connectivity = Connectivity(); // Connectivity instance

  ViewMode _currentViewMode;
  List<PostModel> explorePosts = [];
  List<PostModel> trendingPosts = [];
  List<PostModel> followingPosts = [];
  bool isFetched = false;
  UserModel? currentUser;

  bool isBackgroundFetchComplete = false;
  StreamSubscription? _connectivitySubscription;

  HomeCubit()
      : _currentViewMode = ViewMode.explore,
        super(HomeViewModeInitial(ViewMode.explore)) {
    if (kIsWeb) {
      _loadData(_currentViewMode, false);
    } else {
      _listenToConnectivity();
      _setupBackgroundFetch();
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        final connectivityResult = connectivityList.isNotEmpty
            ? connectivityList.first
            : ConnectivityResult.none;

        // Trigger _loadData whenever connectivity changes
        if (connectivityResult != ConnectivityResult.none) {
          isFetched = false;
          _loadData(_currentViewMode, false);
        } else {
          _loadData(_currentViewMode, true);
        }
      },
    );
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

  void reset(ViewMode viewMode) {
    // emit(HomeViewModeInitial(viewMode));
    // _loadData(viewMode);
  }

  void _loadData(ViewMode viewMode, bool isOffline) async {
    _currentViewMode = viewMode;

    emit(HomeLoading());

    if (!isBackgroundFetchComplete && !isFetched) {
      explorePosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
      trendingPosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
      followingPosts = await serviceLocator<PostRepository>()
          .getPostsData(isOffline: isOffline);
      isFetched = true;
    }

    try {
      List<PostModel> posts;

      switch (viewMode) {
        case ViewMode.explore:
          posts = explorePosts;
          break;
        case ViewMode.trending:
          posts = trendingPosts;
          break;
        case ViewMode.following:
          posts = followingPosts;
          break;
        default:
          posts = explorePosts;
          break;
      }

      if (!isClosed) {
        emit(HomeLoadedPostsSuccess(posts));
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
      isFetched = false;

      if (!isClosed) {
        emit(HomeViewModeInitial(ViewMode.explore));
      }
    } catch (e) {
      emit(HomeFailure('Logout failed: ${e.toString()}'));
    }
  }
}

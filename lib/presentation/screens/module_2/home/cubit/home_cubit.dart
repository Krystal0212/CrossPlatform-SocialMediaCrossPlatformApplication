import 'package:socialapp/utils/import.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  StreamSubscription? _connectivitySubscription;

  HomeCubit()
      : _currentViewMode = ViewMode.explore,
        super(HomeViewModeInitial(ViewMode.explore)) {
    if (kIsWeb) {
      loadData(_currentViewMode, false);
    } else {
      listenToConnectivity();
    }
  }

  void listenToConnectivity() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        final connectivityResult = connectivityList.isNotEmpty
            ? connectivityList.first
            : ConnectivityResult.none;

        // Trigger _loadData whenever connectivity changes
        if (connectivityResult != ConnectivityResult.none) {
          isFetched = false;
          loadData(_currentViewMode, false); // Reload data when connected
        } else {
          loadData(_currentViewMode, true); // Show failure state if no connection
        }
      },
    );
  }

  Future<void> cancelConnectivityListener() {
    _connectivitySubscription?.cancel();
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

  UserModel? getCurrentUser() {
    return currentUser;
  }

  void reset(ViewMode viewMode) {
    // emit(HomeViewModeInitial(viewMode));
    // _loadData(viewMode);
  }

  void loadData(ViewMode viewMode, bool isOffline) async {
    _currentViewMode = viewMode;

    emit(HomeLoading());

    if (!isFetched) {
      explorePosts =
          await serviceLocator<PostRepository>().getPostsData(isOffline);
      trendingPosts =
          await serviceLocator<PostRepository>().getPostsData(isOffline);
      followingPosts =
          await serviceLocator<PostRepository>().getPostsData(isOffline);
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

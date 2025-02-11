import 'package:socialapp/utils/import.dart';
import 'home_state.dart';


//   bool isExploreFetched = false, isTrendingFetched = false, isFollowingFetched = false;
//   UserModel? currentUser;
//
//   bool isBackgroundFetchComplete = false;
//   StreamSubscription? _connectivitySubscription;
//
//   HomeCubit()
//       :super(HomeViewModeInitial()) {
//     _startPeriodicSync();
//     if (kIsWeb) {
//       _loadData(false);
//     } else {
//       _listenToConnectivity();
//       // _setupBackgroundFetch();
//     }
//   }
//
//   bool checkCurrentUserSignedIn(){
//    return serviceLocator<AuthRepository>().isSignedIn();
//   }
//
//   void _listenToConnectivity() {
//     _connectivitySubscription = connectivity.onConnectivityChanged.listen(
//       (connectivityList) {
//         final connectivityResult = connectivityList.isNotEmpty
//             ? connectivityList.first
//             : ConnectivityResult.none;
//
//         // Trigger _loadData whenever connectivity changes
//         if (connectivityResult != ConnectivityResult.none) {
//           isExploreFetched = false;
//           _loadData(false);
//         } else {
//           _loadData(true);
//         }
//       },
//     );
//   }
//
//   void _startPeriodicSync() {
//     _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
//       await serviceLocator<PostService>().syncLikesToFirestore(likedPostsCache);
//     });
//   }
//
//   void addPostLike(String postId, String userId) {
//     likedPostsCache.putIfAbsent(postId, () => {});
//     likedPostsCache[postId]?[userId] = true;
//     if (kDebugMode) {
//       print('Added like: Post $postId -> User $userId');
//     }
//   }
//
//   void removePostLike(String postId, String userId) {
//     likedPostsCache.putIfAbsent(postId, () => {});
//     likedPostsCache[postId]?[userId] = false;
//
//     if (kDebugMode) {
//       print('Removed like: Post $postId -> User $userId');
//     }
//   }
//
//   void _setupBackgroundFetch() {
//     Workmanager().registerPeriodicTask(
//       "Firestore services",
//       "fetchFirestoreData",
//       frequency: const Duration(minutes: 15), // Adjust as needed
//       inputData: {'isOffline': false}, // Fetch online data
//     );
//   }
//
//   @override
//   Future<void> close() {
//     _connectivitySubscription?.cancel();
//     _syncTimer?.cancel();
//     setBackgroundFetchComplete(false);
//     return super.close();
//   }
//
//   Future<bool> checkCurrentUser() async {
//     try {
//       final UserModel? user =
//           await serviceLocator<UserRepository>().getCurrentUserData();
//       if (user == null) {
//         return false;
//       } else {
//         currentUser = user;
//       }
//       return true;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Check user data: $e");
//       }
//       return false;
//     }
//   }
//
//   void setBackgroundFetchComplete(bool isComplete) {
//     isBackgroundFetchComplete = isComplete;
//   }
//
//   UserModel? getCurrentUser() {
//     return currentUser;
//   }
//
//
//   void _loadData( bool isOffline) async {
//     emit(HomeLoading());
//
//     bool isSignedIn = serviceLocator<AuthRepository>().isSignedIn();
//
//     if (!isBackgroundFetchComplete && !isExploreFetched) {
//       explorePosts = await serviceLocator<PostRepository>()
//           .getPostsData(isOffline: isOffline);
//     }
//
//     if (!isBackgroundFetchComplete && !isTrendingFetched) {
//       trendingPosts = await serviceLocator<PostRepository>()
//           .getPostsData(isOffline: isOffline);
//       isTrendingFetched = true;
//     }
//
//     if (!isBackgroundFetchComplete && !isFollowingFetched && isSignedIn) {
//       followingPosts = await serviceLocator<PostRepository>()
//           .getPostsData(isOffline: isOffline);
//       isFollowingFetched = true;
//     }
//
//     try {
//       List<List<PostModel>> postList = [explorePosts, trendingPosts, explorePosts];
//
//       if (!isClosed) {
//         emit(HomeLoadedPostsSuccess(postList));
//       }
//     } catch (e) {
//       if (!isClosed) {
//         emit(HomeFailure('Failed to load data'));
//       }
//     }
//   }
//
//   Future<void> logout() async {
//     if (isClosed) return;
//     try {
//       emit(HomeLoading());
//
//       await serviceLocator<AuthRepository>().signOut();
//
//       currentUser = null;
//       isExploreFetched = false;
//
//
//       if (!isClosed) {
//         emit(HomeViewModeInitial());
//       }
//     } catch (e) {
//       emit(HomeFailure('Logout failed: ${e.toString()}'));
//     }
//   }
// }
//
//
// void reset(ViewMode viewMode) {
//   // emit(HomeViewModeInitial(viewMode));
//   // _loadData(viewMode);
// }

class HomeCubit extends Cubit<HomeState> {
  final Connectivity connectivity = Connectivity();
  final Map<String, bool> likedPostsCache = {};
  bool isBackgroundFetchComplete = false;

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  UserModel? currentUser;

  HomeCubit() : super(HomeViewModeInitial()) {
    _startPeriodicSync();
    _listenToConnectivity();
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

  void _setupBackgroundFetch() {
    Workmanager().registerPeriodicTask(
      "Firestore services",
      "fetchFirestoreData",
      frequency: const Duration(minutes: 15), // Adjust as needed
      inputData: {'isOffline': false}, // Fetch online data
    );
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
      }
    });
  }

  void triggerSync() async {
    bool isOnline = await checkOnline();
    if (isOnline) {
      await serviceLocator<PostRepository>()
          .syncLikesToFirestore(likedPostsCache);
    }
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

  void _listenToConnectivity() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        final connectivityResult = connectivityList.isNotEmpty
            ? connectivityList.first
            : ConnectivityResult.none;

        if (connectivityResult != ConnectivityResult.none) {}
      },
    );
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
      await serviceLocator<PostRepository>().reduceTopicRanksOfPostForCurrentUser( postId);
    } catch (error) {
      if (kDebugMode) {
        print('Error update less similar posts for user: $error');
      }
    }
  }

  @override
  Future<void> close() {
    triggerSync();
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    return super.close();
  }
}

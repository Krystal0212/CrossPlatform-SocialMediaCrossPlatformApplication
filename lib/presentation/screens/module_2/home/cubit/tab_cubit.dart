import 'package:socialapp/presentation/screens/module_2/home/cubit/home_state.dart';
import 'package:socialapp/utils/import.dart';

import '../../mobile_navigator/providers/mobile_navigator_provider.dart';
import 'home_cubit.dart';
import 'tab_state.dart';

abstract class TabCubit extends Cubit<TabState> {
  final PostRepository postRepository;
  final HomeCubit homeCubit;
  final ViewMode viewMode;

  TabCubit(this.postRepository, this.homeCubit, this.viewMode)
      : super(TabLoading()) {
    if (!isSignedIn() && viewMode == ViewMode.following) {
      emit(TabNotSignIn());
      return;
    }
  }

  bool isSignedIn() {
    try {
      return serviceLocator<AuthRepository>().isSignedIn();
    } catch (e) {
      if (kDebugMode) {
        print("Check user data: $e");
      }
      return false;
    }
  }

  Future<List<OnlinePostModel>> loadMorePosts();

  Future<void> refresh() async {
    await initialLoadPosts(isOffline: false);
  }

  Future<void> initialLoadPosts({required bool isOffline}) async {}
}

class ExploreCubit extends TabCubit {
  bool noMorePosts = false;
  List<OnlinePostModel>? lastFetchedModels;

  ExploreCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts =
          await postRepository.getExplorePostsData(isOffline: isOffline);
      lastFetchedModels = posts;
      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-more') {
        noMorePosts = true;
      }
      if (isClosed) return;
      if (kDebugMode) {
        print("Error during initial load for explore: $e");
      }
      emit(TabError('Failed to load posts for explore: $e'));
    }
  }

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      if (!noMorePosts) {
        final List<OnlinePostModel> posts = await postRepository
            .getExplorePostsData(lastFetchedModels: lastFetchedModels!);
        lastFetchedModels?.addAll(posts);
        return posts;
      }
      return [];
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-more') {
        noMorePosts = true;
      }
      if (kDebugMode) {
        print("Error loading more posts for explore: $e");
      }
      return [];
    }
  }
}

class TrendingCubit extends TabCubit {
  List<OnlinePostModel>? lastFetchedModels;
  bool noMorePosts = false;

  TrendingCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts =
          await postRepository.getTrendyPostsData(isOffline: isOffline);
      lastFetchedModels = posts;

      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (isClosed) return;
      if (kDebugMode) {
        print("Error during initial load for trending: $e");
      }
      emit(TabError('Failed initial load for trending: $e'));
    }
  }

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      if (!noMorePosts) {
        final List<OnlinePostModel> posts = await postRepository
            .getTrendyPostsData(lastFetchedModels: lastFetchedModels!);
        lastFetchedModels = posts;
        return posts;
      }
      return [];
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-more') {
        noMorePosts = true;
      }
      if (kDebugMode) {
        print("Error loading more posts for trending: $e");
      }
      return [];
    }
  }
}

class FollowingCubit extends TabCubit {
  OnlinePostModel? lastFetchedPost;
  bool noMorePosts = false;

  FollowingCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final List<OnlinePostModel> posts =
          await postRepository.getFollowingPostsData();
      lastFetchedPost = posts.last;
      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-more') {
        noMorePosts = true;
      }

      if (isClosed) return;
      if (kDebugMode) {
        print('Error during initial load for following: $e');
      }
      emit(TabError('Failed initial load for following: $e'));
    }
  }

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      if (!noMorePosts) {
        final List<OnlinePostModel> posts = await postRepository
            .getFollowingPostsData(lastFetchedPost: lastFetchedPost);
        lastFetchedPost = posts.last;
        return posts;
      }
      return [];
    } catch (e) {
      if (e is CustomFirestoreException && e.code == 'no-more') {
        noMorePosts = true;
      }
      if (kDebugMode) {
        print('Error during loading more posts for following: $e');
      }
      return [];
    }
  }
}

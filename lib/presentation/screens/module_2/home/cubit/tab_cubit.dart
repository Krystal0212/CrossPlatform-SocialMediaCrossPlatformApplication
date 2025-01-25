import 'package:socialapp/presentation/screens/module_2/home/cubit/home_state.dart';
import 'package:socialapp/utils/import.dart';

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

  Future<void> refresh() async{
    await initialLoadPosts(isOffline: false);
  }

  Future<void> initialLoadPosts({required bool isOffline}) async {}
}

class ExploreCubit extends TabCubit {
  ExploreCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      final List<OnlinePostModel> posts = await postRepository.loadMorePostsData();
      return posts;
    } catch (e) {
      debugPrint("Error loading more posts: $e");
      return [];
    }
  }

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts = await postRepository.getExplorePostsData(isOffline: isOffline);
      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (isClosed) return;
      emit(TabError('Failed to load posts: $e'));
    }
  }
}

class TrendingCubit extends TabCubit {
  TrendingCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      final List<OnlinePostModel> posts = await postRepository.loadMorePostsData();
      return posts;
    } catch (e) {
      debugPrint("Error loading more posts: $e");
      return [];
    }
  }

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts = await postRepository.getPostsData(isOffline: isOffline);
      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (isClosed) return;
      emit(TabError('Failed to load posts: $e'));
    }
  }
}

class FollowingCubit extends TabCubit {
  FollowingCubit(super.postRepository, super.homeCubit, super.viewMode);

  @override
  Future<List<OnlinePostModel>> loadMorePosts() async {
    try {
      final List<OnlinePostModel> posts = await postRepository.loadMorePostsData();
      return posts;
    } catch (e) {
      debugPrint("Error loading more posts: $e");
      return [];
    }
  }

  @override
  Future<void> initialLoadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts = await postRepository.getPostsData(isOffline: isOffline);
      if (isClosed) return;
      emit(TabLoaded(posts));
    } catch (e) {
      if (isClosed) return;
      emit(TabError('Failed to load posts: $e'));
    }
  }
}

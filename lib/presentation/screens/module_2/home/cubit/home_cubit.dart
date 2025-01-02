import 'package:bloc/bloc.dart';
import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/domain/repository/post/post_repository.dart';
import 'package:socialapp/service_locator.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  ViewMode _currentViewMode;
  List<PostModel> explorePosts = [];
  List<PostModel> trendingPosts =[];
  List<PostModel> followingPosts =[];
  bool isFetched = false;

  HomeCubit()
      : _currentViewMode = ViewMode.explore,
        super(HomeViewModeInitial(ViewMode.explore)) {


    _loadData(ViewMode.explore);
  }

  Future<void> fetchPosts() async {
    explorePosts = await serviceLocator<PostRepository>().getPostsData();
    trendingPosts = await serviceLocator<PostRepository>().getPostsData();
    followingPosts = await serviceLocator<PostRepository>().getPostsData();
  }

  void reset(ViewMode viewMode) {
    emit(HomeViewModeInitial(viewMode));
    _loadData(viewMode);
  }

  void setViewMode(ViewMode mode) {
    if (_currentViewMode != mode) {
      emit(HomeViewModeChanged(mode));
      _loadData(mode);
    }
  }

  void _loadData(ViewMode viewMode) async {
    _currentViewMode = viewMode;

    emit(HomeLoading());

    if(!isFetched){
      await fetchPosts();
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

      emit(HomeLoadedPostsSuccess(posts));
    } catch (e) {
      emit(HomeFailure('Failed to load data'));
    }
  }
}

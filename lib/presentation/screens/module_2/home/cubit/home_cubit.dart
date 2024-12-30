import 'package:bloc/bloc.dart';
import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/domain/repository/post/post_repository.dart';
import 'package:socialapp/service_locator.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  ViewMode _currentViewMode;

  HomeCubit()
      : _currentViewMode = ViewMode.popular,
        super(HomeViewModeInitial(ViewMode.popular)) {
    // Trigger initial data loading for the default view mode
    _loadData(ViewMode.popular);
  }

  void reset(ViewMode viewMode) {
    emit(HomeViewModeInitial(viewMode));
    _loadData(viewMode);
  }

  void setViewMode(ViewMode mode) {
    // Only load data if the view mode is different from the current one
    if (_currentViewMode != mode) {
      emit(HomeViewModeChanged(mode));
      _loadData(mode);
    }
  }

  void _loadFetchedData(ViewMode viewMode) async {
    // Set the current view mode
    _currentViewMode = viewMode;

    try {
      List<String> posts;
      switch (viewMode) {
        case ViewMode.popular:
          posts = List.generate(10, (index) => 'Popular Post $index');
          break;
        case ViewMode.trending:
          posts = List.generate(10, (index) => 'Trending Post $index');
          break;
        case ViewMode.fol:
          posts = List.generate(10, (index) => 'Following Post $index');
          break;
      }

      // emit(HomeLoadedPostsSuccess(posts));
    } catch (e) {
      emit(HomeFailure('Failed to load data'));
    }
  }

  // Simulate data loading based on the selected view mode
  void _loadData(ViewMode viewMode) async {
    // Set the current view mode
    _currentViewMode = viewMode;

    emit(HomeLoading());

    try {
      List<PostModel> posts = await serviceLocator<PostRepository>().getPostsData();

      switch (viewMode) {
        case ViewMode.popular:
          posts = posts;
          break;
        case ViewMode.trending:
          posts = posts;
          break;
        case ViewMode.fol:
          posts = posts;
          break;
      }

      emit(HomeLoadedPostsSuccess(posts));
    } catch (e) {
      print(e);
      emit(HomeFailure('Failed to load data'));
    }
  }
}

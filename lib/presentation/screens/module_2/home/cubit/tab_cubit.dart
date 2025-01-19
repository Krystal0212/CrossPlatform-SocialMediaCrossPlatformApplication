import 'package:socialapp/presentation/screens/module_2/home/cubit/home_state.dart';
import 'package:socialapp/utils/import.dart';

import 'home_cubit.dart';
import 'tab_state.dart';

class TabCubit extends Cubit<TabState> {
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

  Future<void> loadPosts({required bool isOffline}) async {
    emit(TabLoading());
    try {
      final posts = await postRepository.getPostsData(isOffline: isOffline);
      emit(TabLoaded(posts));
    } catch (e) {
      emit(TabError('Failed to load posts: $e'));
    }
  }
}

class ExploreCubit extends TabCubit {
  ExploreCubit(super.postRepository, super.homeCubit, super.viewMode);
}

class TrendingCubit extends TabCubit {
  TrendingCubit(super.postRepository, super.homeCubit, super.viewMode);
}

class FollowingCubit extends TabCubit {
  FollowingCubit(super.postRepository, super.homeCubit, super.viewMode);
}

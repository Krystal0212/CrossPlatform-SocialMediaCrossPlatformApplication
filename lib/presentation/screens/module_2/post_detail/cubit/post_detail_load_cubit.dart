import 'package:socialapp/utils/import.dart';

import 'post_detail_load_state.dart';

class PostDataLoadCubit extends Cubit<PostDataLoadedState> {
  final String postId;

  PostDataLoadCubit(this.postId) : super(PostDataLoadedInitial()) {
    loadPostData();
  }

  void loadPostData() async {
    try {
      final post = await serviceLocator<PostRepository>().getDataFromPostId(postId);
      emit(PostDataLoaded(post));
    } catch (error) {
      emit(PostDataLoadedError(error.toString()));
  }
}
}
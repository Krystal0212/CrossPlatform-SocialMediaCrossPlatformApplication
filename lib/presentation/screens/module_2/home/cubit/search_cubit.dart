import 'package:socialapp/utils/import.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  Future<void> searchPosts(String query) async {
    emit(SearchFinding());

    List<OnlinePostModel> posts = [];

    posts = await serviceLocator.get<PostRepository>().searchPost(query);

    emit(SearchLoaded(posts));

  }
}
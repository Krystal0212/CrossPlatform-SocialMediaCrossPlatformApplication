import 'package:socialapp/utils/import.dart';
import 'collection_state.dart';

class CollectionPostCubit extends Cubit<CollectionPostState> {
  CollectionPostCubit() : super(CollectionPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    getCollectionsOfUser();
  }

  Future<void> getCollectionsOfUser() async {
    try {
      final User? user =
          await serviceLocator<AuthRepository>().getCurrentUser();

      if (user != null) {
        Stream<List<CollectionModel>> collections =
            serviceLocator<CollectionRepository>()
                .getCollectionsFromUserRealtime(user.uid);
        emit(CollectionPostLoaded(collections));
      } else {
        if (kDebugMode) {
          print('Error fetching user data for shot tab: User is null');
        }
        emit(CollectionPostError());
      }
    } catch (error) {
      debugPrint('Error fetching collections: $error');
      emit(CollectionPostError());
    }
  }
}

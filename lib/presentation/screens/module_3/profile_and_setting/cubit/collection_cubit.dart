import 'package:socialapp/utils/import.dart';
import 'collection_state.dart';

class CollectionPostCubit extends Cubit<CollectionPostState> {
  bool isCurrentUser = false;
  final String userId;

  CollectionPostCubit({required this.userId}) : super(CollectionPostInitial()) {
    _initialize();
  }

  void _initialize() async {
    final User? currentUser =
        await serviceLocator<AuthRepository>().getCurrentUser();
    if (currentUser?.uid == userId) {
      isCurrentUser = true;
    }
    getCollectionsOfUser();
  }

  Future<void> getCollectionsOfUser() async {
    try {
      Stream<List<CollectionModel>> collections =
           serviceLocator<CollectionRepository>().getCollectionsFromUserRealtime(userId);
      emit(CollectionPostLoaded(collections));
    } catch (error) {
      debugPrint('Error fetching collections: $error');
    }
  }
}

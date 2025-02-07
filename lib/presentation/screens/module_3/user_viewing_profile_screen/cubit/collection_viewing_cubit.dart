import 'package:socialapp/utils/import.dart';

import 'collection_viewing_state.dart';

class CollectionViewingPostCubit extends Cubit<CollectionViewingPostState> {
  bool isCurrentUser = false;
  final String userId;

  CollectionViewingPostCubit({required this.userId}) : super(CollectionViewingPostInitial()) {
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
      List<CollectionModel> collections = await
      serviceLocator<CollectionRepository>().getCollectionsFromOtherUser(userId);
      emit(CollectionViewingPostLoaded(collections));
    } catch (error) {
      debugPrint('Error fetching collections: $error');
    }
  }
}

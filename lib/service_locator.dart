
import 'package:socialapp/utils/import.dart';

import 'data/repository/storage/storate_repository_impl.dart';
import 'domain/repository/storage/storage_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {

  serviceLocator.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  serviceLocator.registerSingleton<UserService>(UserServiceImpl());
  serviceLocator.registerSingleton<UserRepository>(UserRepositoryImpl());

  serviceLocator.registerSingleton<FirestoreService>(FirestoreServiceImpl());
  serviceLocator.registerSingleton<TopicRepository>(TopicRepositoryImpl());

  serviceLocator.registerSingleton<DeepLinkService>(DeepLinkServiceImpl());
  serviceLocator.registerSingleton<DeepLinkRepository>(DeepLinkRepositoryImpl());

  serviceLocator.registerSingleton<CollectionService>(CollectionServiceImpl());
  serviceLocator.registerSingleton<CollectionRepository>(CollectionRepositoryImpl());

  serviceLocator.registerSingleton<PostService>(PostServiceImpl());
  serviceLocator.registerSingleton<PostRepository>(PostRepositoryImpl());
}
